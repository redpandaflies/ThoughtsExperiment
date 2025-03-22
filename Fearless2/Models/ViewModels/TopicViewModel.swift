//
//  TopicViewModel.swift
//  Fearless2
//
//  Created by Yue Deng-Wu on 10/2/24.
//
import Combine
import Foundation
import OSLog

final class TopicViewModel: ObservableObject {
    
    @Published var topicUpdated: Bool = false
    @Published var topicSuggestions: [NewTopicSuggestion]  = []
    @Published var createTopicOverview: TopicOverviewState = .ready
    @Published var showPlaceholder: Bool = false
    @Published var generatingImage: Bool = false
    @Published var updatedEntry: Entry? = nil
    @Published var updatingfocusArea: Bool = false
    @Published var focusAreaUpdated: Bool = false
    @Published var focusAreaCreationFailed: Bool = false
    @Published var createFocusAreaSummary: FocusAreaSummaryState = .ready
    @Published var createFocusAreaSuggestions: FocusAreaSuggestionsState = .ready
    @Published var sectionSummaryCreated: Bool = false
    @Published var scrollToAddTopic: Bool = false
    
    private var openAISwiftService: OpenAISwiftService
    private var dataController: DataController
    private let transcriptionViewModel: TranscriptionViewModel
    private var stabilityService = StabilityService.instance
    
    private var cancellables = Set<AnyCancellable>()
    
    var threadId: String? = nil //needed for cancelling runs
    
    let loggerOpenAI = Logger.openAIEvents
    let loggerCoreData = Logger.coreDataEvents
    let loggerStability = Logger.stabilityEvents
    
    init(openAISwiftService: OpenAISwiftService, dataController: DataController, transcriptionViewModel: TranscriptionViewModel) {
        self.openAISwiftService = openAISwiftService
        self.dataController = dataController
        self.transcriptionViewModel = transcriptionViewModel
        
        Task { @MainActor in
            self.setupTranscriptionReadySubscription()
        }
    }
    
    enum TopicOverviewState {
        case ready
        case loading
        case retry
    }
    
    enum FocusAreaSummaryState {
        case ready
        case loading
        case retry
    }
    
    enum FocusAreaSuggestionsState {
        case ready
        case loading
        case retry
    }
    
    @MainActor
    private func setupTranscriptionReadySubscription() {
        transcriptionViewModel.transcriptionReadySubject
            .receive(on: DispatchQueue.main) // Ensure Combine pipeline runs on the main thread
            .sink { [weak self] (currentTopicId, entryId, receivedTranscript) in
                guard let self = self else { return } // Prevent retain cycles
                
                Task { @MainActor in // Ensure this runs on the main actor
                    try await self.manageRun(selectedAssistant: .entry, topicId: currentTopicId, entryId: entryId, transcript: receivedTranscript)
                }
            }
            .store(in: &cancellables)
    }
    
    //MARK: create new topic
    //note: send the full name of category to GPT as context, save the short name to CoreData
    //note: kept the optionals for userInput and question for now, in case we want to add back in the follow-up questions and summary
    func manageRun(selectedAssistant: AssistantItem, userInput: [String]? = nil, topicId: UUID? = nil, entryId: UUID? = nil, transcript: String? = nil, focusArea: FocusArea? = nil, section: Section? = nil, question: String? = nil, review: TopicReview? = nil, category: Category? = nil) async throws {
        
        do {
            //reset published vars
            await MainActor.run {
                self.threadId = nil
                self.topicUpdated = false
                self.topicSuggestions = []
                self.showPlaceholder = false
                self.generatingImage = false
                if selectedAssistant != .focusArea {
                    self.updatingfocusArea = false
                }
                self.focusAreaUpdated = false
                self.focusAreaCreationFailed = false
                if selectedAssistant == .focusAreaSummary {
                    self.createFocusAreaSummary = .loading
                } else {
                    self.createFocusAreaSummary = .ready
                }
                if selectedAssistant == .focusAreaSuggestions {
                    self.createFocusAreaSuggestions = .loading
                } else {
                    self.createFocusAreaSuggestions = .ready
                }
                if selectedAssistant == .topicOverview {
                    self.createTopicOverview = .loading
                }
                self.sectionSummaryCreated = false
                self.updatedEntry = nil
                
            }
            
            try await manageRunWithStreaming(selectedAssistant: selectedAssistant, userInput: userInput, topicId: topicId, entryId: entryId, transcript: transcript, focusArea: focusArea, section: section, question: question, review: review,  category: category)
            
        } catch {
            loggerOpenAI.error("Failed to complete OpenAI run: \(error.localizedDescription), \(error)")
            await MainActor.run {
                self.updatingfocusArea = false
            }
            throw OpenAIError.runIncomplete(error)
            
        }
        
    }
    
    func manageRunWithStreaming(selectedAssistant: AssistantItem, userInput: [String]? = nil, topicId: UUID? = nil, entryId: UUID? = nil, transcript: String? = nil, focusArea: FocusArea? = nil, section: Section? = nil, question: String? = nil, review: TopicReview? = nil, category: Category? = nil) async throws {
        
        let threadId: String
                
        do {
            guard let newThreadId = try await createThread(selectedAssistant: selectedAssistant) else {
                throw OpenAIError.missingRequiredField("Thread ID not created")
            }
            threadId = newThreadId
            
        } catch {
            throw OpenAIError.requestFailed(error, "Failed to create thread")
        }
        
        try await sendFirstMessage(selectedAssistant: selectedAssistant, threadId: threadId, topicId: topicId, transcript: transcript, focusArea: focusArea, category: category)
        
        
        var messageText: String?
        
        do {
            // Fetch the streamed message
            messageText = try await openAISwiftService.createRunAndStreamMessage(threadId: threadId, selectedAssistant: selectedAssistant)
            
            guard let unwrappedMessageText = messageText else {
                loggerOpenAI.error("No content received from OpenAI.")
                throw OpenAIError.missingRequiredField("Response JSON from OpenAI")
            }
            
            messageText = unwrappedMessageText
        } catch {
            loggerOpenAI.error("Failed to get OpenAI streamed response: \(error.localizedDescription), \(error)")
            throw OpenAIError.runIncomplete(error)
        }
        
        
        do {
            guard let messageText = messageText else {
                loggerOpenAI.error("Message text is nil despite successful API call.")
                throw OpenAIError.missingRequiredField("Response JSON from OpenAI")
            }
            
            
            switch selectedAssistant {
                
            case .topicSuggestions:
                guard let newSuggestions = try await openAISwiftService.processTopicSuggestions(messageText: messageText) else {
                    loggerOpenAI.error("Failed to process topic suggestions")
                    throw ProcessingError.processingFailed()
                }
                
                await MainActor.run {
                    self.topicSuggestions = newSuggestions.suggestions
                }
                
            case .topicOverview:
                
                guard let currentTopicId = topicId else {
                    loggerCoreData.error("Failed to get new topic ID")
                    throw OpenAIError.missingRequiredField("Topic ID")
                }
                
                try await openAISwiftService.processTopicOverview(messageText: messageText, topicId: currentTopicId)
                
                await MainActor.run {
                    self.createTopicOverview = .ready
                }
                
            case .focusAreaSuggestions:
                
                guard let currentTopic = topicId else {
                    loggerCoreData.error("Failed to get topic ID")
                    throw OpenAIError.missingRequiredField("Topic ID")
                }
                
                try await openAISwiftService.processFocusAreaSuggestions(messageText: messageText, topicId: currentTopic)
                
                await MainActor.run {
                    self.createFocusAreaSuggestions = .ready
                }
                
                
            case .focusArea:
                
                guard let currentFocusArea = focusArea else {
                    loggerCoreData.error("Failed to get new focus area")
                    throw OpenAIError.missingRequiredField("Focus area")
                }
                
                try await openAISwiftService.processFocusArea(messageText: messageText, focusArea: currentFocusArea)
                
                loggerOpenAI.log("Added new focus area to topic")
                
                await MainActor.run {
                    self.updatingfocusArea = false
                    self.focusAreaUpdated = true
                }
                
            case .focusAreaSummary:
                
                guard let currentFocusArea = focusArea else {
                    loggerCoreData.error("Failed to get focus area")
                    throw OpenAIError.missingRequiredField("Focus area")
                }
                
                try await openAISwiftService.processFocusAreaSummary(messageText: messageText, focusArea: currentFocusArea)
                
                await MainActor.run {
                    self.createFocusAreaSummary = .ready
                }
                
                //                case .entry:
                //
                //                    guard let currentEntryId = entryId else {
                //                        loggerCoreData.error("Failed to get new topic ID")
                //                        return
                //                    }
                //
                //                    if let updatedEntry = await openAISwiftService.processEntry(entryId: currentEntryId) {
                //                        loggerOpenAI.log("Updated new entry with insights and summary")
                //                        await MainActor.run {
                //                            self.updatedEntry = updatedEntry
                //                        }
                //                    }
                //
                //                case .sectionSummary:
                //                    guard let currentSection = section else {
                //                            loggerCoreData.error("No current section found")
                //                            return
                //                        }
                //                    await openAISwiftService.processSectionSummary(section: currentSection)
                //
                //                    loggerOpenAI.log("Updated section with summary")
                //
                //                    await MainActor.run {
                //                        self.sectionSummaryCreated = true
                //                    }
                
                
            default:
                break
            }
            
        } catch {
            loggerOpenAI.error("Failed to decode OpenAI streamed response: \(error.localizedDescription), \(error)")
            
            throw ProcessingError.processingFailed(error)
            
        }
        
    }
    
    
    
    private func createThread(selectedAssistant: AssistantItem) async throws -> String? {
        do {
            
            let newthreadId = try await openAISwiftService.createThread()
            
            guard let threadId = newthreadId else {
                loggerOpenAI.error("No thread ID received from OpenAI")
                
                return nil
            }
            
            //only needed to cancel a run, which happens when users dismiss loading views
            await MainActor.run {
                self.threadId = threadId
            }
            
            return threadId
            
        } catch {
            loggerOpenAI.error("Failed to create thread: \(error.localizedDescription)")
            throw OpenAIError.requestFailed(error, "Failed to create thread")
        }
        
    }
    
    //for creating a set of questions to gather context on a topic
    private func sendFirstMessage(selectedAssistant: AssistantItem, threadId: String, topicId: UUID? = nil, transcript: String? = nil, focusArea: FocusArea? = nil, category: Category? = nil) async throws {
        
        let userContext = try await gatherUserContext(selectedAssistant: selectedAssistant, topicId: topicId, transcript: transcript, focusArea: focusArea, category: category)
        
        try await sendMessageWithContext(threadId: threadId, userContext: userContext)
    }
    
    private func gatherUserContext(selectedAssistant: AssistantItem, topicId: UUID? = nil, transcript: String? = nil, focusArea: FocusArea? = nil, category: Category? = nil) async throws -> String {
        
        //topic suggestion assistant only
        if selectedAssistant == .topicSuggestions {
            guard let currentCategory = category else {
                loggerCoreData.error("Failed to get current category")
                throw ContextError.missingRequiredField("Category")
            }
            
            guard let gatheredContext = await ContextGatherer.gatherContextTopicSuggestions(dataController: dataController, loggerCoreData: loggerCoreData, category: currentCategory) else {
                loggerCoreData.error("Failed to get topic suggestions")
                throw ContextError.noContextFound("topic suggestions")
            }
            return gatheredContext
        }
        
        //for all other assistants
        var userContext: String = ""
        
        guard let currentTopic = topicId else {
            loggerCoreData.error("Failed to get new topic ID")
            throw ContextError.missingRequiredField("Topic ID")
        }
        
        switch selectedAssistant {
            
        case .topicOverview:
            
            guard let gatheredContext = await ContextGatherer.gatherContextGeneral(dataController: dataController, loggerCoreData: loggerCoreData, selectedAssistant: selectedAssistant, topicId: currentTopic) else {
                loggerCoreData.error("Failed to get user context")
                throw ContextError.noContextFound("create topic review")
            }
            
            userContext += gatheredContext
            
        case .focusArea, .focusAreaSummary:
            
            guard let gatheredContext = await ContextGatherer.gatherContextGeneral(dataController: dataController, loggerCoreData: loggerCoreData, selectedAssistant: selectedAssistant, topicId: currentTopic, focusArea: focusArea) else {
                loggerCoreData.error("Failed to get user context")
                throw ContextError.noContextFound("create focus area")
            }
            
            userContext += gatheredContext
            
        case .focusAreaSuggestions:
            
            guard let gatheredContext = await ContextGatherer.gatherContextGeneral(dataController: dataController, loggerCoreData: loggerCoreData, selectedAssistant: selectedAssistant, topicId: currentTopic) else {
                loggerCoreData.error("Failed to get user context")
                throw ContextError.noContextFound("get focus area suggestions")
            }
            userContext += gatheredContext
            
        case .entry:
            
            guard let newTranscript = transcript else {
                loggerCoreData.error("Failed to get transcript")
                throw ContextError.missingRequiredField("Transcript")
            }
            
            guard let gatheredContext = await ContextGatherer.gatherContextGeneral(dataController: dataController, loggerCoreData: loggerCoreData, topicId: currentTopic, transcript: newTranscript) else {
                loggerCoreData.error("Failed to get user context")
                throw ContextError.noContextFound("create new entry")
            }
            
            userContext += gatheredContext
            
        default:
            break
            
        }
        
        return userContext
        
    }
    
    private func sendMessageWithContext(threadId: String, userContext: String) async throws {
        do {
            if let newMessage = try await openAISwiftService.createMessage(threadId: threadId, content: userContext) {
                loggerOpenAI.info("First message sent: \(newMessage.content)")
            }
        } catch {
            loggerOpenAI.error("Error sending user message to OpenAI: \(error.localizedDescription), \(error)")
            throw OpenAIError.requestFailed(error, "Failed to send first message")
        }
    }
    
    func cancelCurrentRun() async throws {
        let threadId = openAISwiftService.threadId
        if !threadId.isEmpty {
                try await openAISwiftService.cancelRun(threadId: threadId)
        } else {
            throw OpenAIError.missingRequiredField("No thread ID found")
        }
    }
    
}

//MARK: generate topic image
extension TopicViewModel {
    
    func getTopicImage(topic: Topic) async {
        
        
        let topicId = await MainActor.run {
            return topic.topicId.uuidString
        }
        
        let newImagePrompt = await MainActor.run {
            return "A beautifully rendered minimalistic 3d illustration of this theme: \(topic.topicTitle). Incorporate subtle cinematic lighting and details that capture the essence of the theme."
        }
        
        loggerStability.log("Creating image for topic: \(topicId)")
        
        //get image from Stability
        if let topicImageURL = await stabilityService.getTopicImage(fromPrompt: newImagePrompt, topicId: topicId) {
            
            await dataController.saveTopicImage(topic: topic, imageURL: topicImageURL.absoluteString)
            
            await MainActor.run {
                self.generatingImage = false
            }
        } else {
            await MainActor.run {
                self.showPlaceholder = true
                self.generatingImage = false
            }
        }
        
    }
    
}
