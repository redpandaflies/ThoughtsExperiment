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
    @Published var createTopicOverview: TopicOverviewState = .ready
    @Published var showPlaceholder: Bool = false
    @Published var generatingImage: Bool = false
    @Published var updatedEntry: Entry? = nil
    // create sections for focus area
    @Published var createNewFocusArea: NewFocusAreaState = .ready
    @Published var focusAreaCreationFailed: Bool = false //when run fails
    @Published var createFocusAreaSummary: FocusAreaSummaryState = .ready
    @Published var createTopicQuestions: NewTopicQuestionsState = .ready
   
    @Published var sectionSummaryCreated: Bool = false
    @Published var scrollToAddTopic: Bool = false
  
    private var dataController: DataController
    private var openAISwiftService: OpenAISwiftService
    private var assistantRunManager: AssistantRunManager
    private var stabilityService = StabilityService.instance
    
    private var cancellables = Set<AnyCancellable>()
    
    var threadId: String? = nil //needed for cancelling runs
    
    let loggerOpenAI = Logger.openAIEvents
    let loggerCoreData = Logger.coreDataEvents
    let loggerStability = Logger.stabilityEvents
    
    init(dataController: DataController, openAISwiftService: OpenAISwiftService, assistantRunManager: AssistantRunManager) {
        self.dataController = dataController
        self.openAISwiftService = openAISwiftService
        self.assistantRunManager = assistantRunManager
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
    
    enum NewFocusAreaState {
        case ready
        case loading
        case retry
    }
    
    enum NewTopicQuestionsState {
        case ready
        case loading
        case retry
    }
    
    //MARK: create new topic
    //note: send the full name of category to GPT as context, save the short name to CoreData
    //note: kept the optionals for userInput and question for now, in case we want to add back in the follow-up questions and summary
    func manageRun(selectedAssistant: AssistantItem, userInput: [String]? = nil, topicId: UUID? = nil, entryId: UUID? = nil, transcript: String? = nil, topic: Topic? = nil, focusArea: FocusArea? = nil, section: Section? = nil, question: String? = nil, review: TopicReview? = nil, category: Category? = nil) async throws {
        
        do {
            //reset published vars
            await MainActor.run {
                self.threadId = nil
                self.topicUpdated = false
                self.showPlaceholder = false
                self.generatingImage = false
                if selectedAssistant == .focusArea {
                    if self.createNewFocusArea != .loading {
                        self.createNewFocusArea = .loading
                    }
                } else {
                    self.createNewFocusArea = .ready
                }
                if selectedAssistant == .focusAreaSummary {
                    self.createFocusAreaSummary = .loading
                } else {
                    self.createFocusAreaSummary = .ready
                }
                if selectedAssistant == .topicOverview {
                    self.createTopicOverview = .loading
                }
                if selectedAssistant == .topic {
                    if self.createTopicQuestions != .loading {
                        self.createTopicQuestions = .loading
                    }
                } else {
                    self.createTopicQuestions = .ready
                }
                self.sectionSummaryCreated = false
                self.updatedEntry = nil
                
            }
            
            try await manageRunWithStreaming(selectedAssistant: selectedAssistant, userInput: userInput, topicId: topicId, entryId: entryId, transcript: transcript, topic: topic, focusArea: focusArea, section: section, question: question, review: review,  category: category)
            
        } catch {
            loggerOpenAI.error("Failed to complete OpenAI run: \(error.localizedDescription), \(error)")
            throw OpenAIError.runIncomplete(error)
            
        }
        
    }
    
    func manageRunWithStreaming(selectedAssistant: AssistantItem, userInput: [String]? = nil, topicId: UUID? = nil, entryId: UUID? = nil, transcript: String? = nil, topic: Topic? = nil, focusArea: FocusArea? = nil, section: Section? = nil, question: String? = nil, review: TopicReview? = nil, category: Category? = nil) async throws {
        
        do {
            let messageText = try await assistantRunManager.runAssistant(
                selectedAssistant: selectedAssistant,
                category: category,
                topicId: topicId,
                focusArea: focusArea,
                topic: topic
            )
            
            switch selectedAssistant {
                
            case .topic:
                guard let topic = topic else {
                    loggerCoreData.error("Failed to get topic")
                    return
                }
                
                try await openAISwiftService.processNewTopicQuestions(messageText: messageText, topic: topic)
                
                await MainActor.run {
                    self.createTopicQuestions = .ready
                }
                
            case .topicOverview:
                
                guard let topic = topic else {
                    loggerCoreData.error("Failed to get topic")
                    return
                }
                
                try await openAISwiftService.processTopicOverview(messageText: messageText, topic: topic)
                
                await MainActor.run {
                    self.createTopicOverview = .ready
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
                
                
            default:
                break
            }
            
            
        } catch {
            loggerOpenAI.error("Failed to decode OpenAI streamed response: \(error.localizedDescription), \(error)")
            throw ProcessingError.processingFailed(error)
            
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
