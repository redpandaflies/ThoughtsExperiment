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
    @Published var updatedEntry: Entry? = nil
    @Published var sectionSuggestions: [String] = []
    
    private var openAISwiftService: OpenAISwiftService
    private var dataController: DataController
    private let transcriptionViewModel: TranscriptionViewModel
    private var cancellables = Set<AnyCancellable>()
    
    var threadId: String? = nil //needed for cancelling runs
    
    let loggerOpenAI = Logger.openAIEvents
    let loggerCoreData = Logger.coreDataEvents
    
    init(openAISwiftService: OpenAISwiftService, dataController: DataController, transcriptionViewModel: TranscriptionViewModel) {
        self.openAISwiftService = openAISwiftService
        self.dataController = dataController
        self.transcriptionViewModel = transcriptionViewModel
        
        Task { @MainActor in
                self.setupTranscriptionReadySubscription()
        }
    }
    
    @MainActor
    private func setupTranscriptionReadySubscription() {
        transcriptionViewModel.transcriptionReadySubject
            .receive(on: DispatchQueue.main) // Ensure Combine pipeline runs on the main thread
            .sink { [weak self] (currentTopicId, entryId, receivedTranscript) in
                guard let self = self else { return } // Prevent retain cycles

                Task { @MainActor in // Ensure this runs on the main actor
                    await self.manageRun(selectedAssistant: .entry, topicId: currentTopicId, entryId: entryId, transcript: receivedTranscript)
                }
            }
            .store(in: &cancellables)
    }
    
    //MARK: create new topic
    //note: send the full name of category to GPT as context, save the short name to CoreData
    //note: kept the optionals for userInput and question for now, in case we want to add back in the follow-up questions and summary
    func manageRun(selectedAssistant: AssistantItem, userInput: [String]? = nil, topicId: UUID? = nil, entryId: UUID? = nil, transcript: String? = nil, section: Section? = nil, question: String? = nil) async {
    
        //reset published vars
        await MainActor.run {
            self.threadId = nil
            self.topicUpdated = false
            self.updatedEntry = nil
            self.sectionSuggestions = []
        }

        await manageRunWithStreaming(selectedAssistant: selectedAssistant, userInput: userInput, topicId: topicId, entryId: entryId, transcript: transcript, section: section, question: question, retryCount: 1)
        
    }
    
    func manageRunWithStreaming(selectedAssistant: AssistantItem, userInput: [String]? = nil, topicId: UUID? = nil, entryId: UUID? = nil, transcript: String? = nil, section: Section? = nil, question: String? = nil, retryCount: Int) async {
        
        guard let threadId = await createThread(selectedAssistant: selectedAssistant) else {
            return
        }
        
        await sendFirstMessage(selectedAssistant: selectedAssistant, threadId: threadId, topicId: topicId, transcript: transcript, section: section, userInput: userInput)
        
        
        do {
            try await openAISwiftService.createRunAndStreamMessage(threadId: threadId, selectedAssistant: selectedAssistant)
                
            if !openAISwiftService.messageText.isEmpty {
                
                switch selectedAssistant {
                  
                case .sectionSummary:
                    guard let currentSection = section else {
                            loggerCoreData.error("No current section found")
                            return
                        }
                    await openAISwiftService.processSectionSummary(section: currentSection)
                        
                    loggerOpenAI.log("Updated section with summary")
                    
                    case .sectionSuggestions:
                        
                        if let newSectionSuggestions = await openAISwiftService.processSectionSuggestions() {
                            loggerOpenAI.log("Processed section suggestions")
                            await MainActor.run {
                                self.sectionSuggestions = newSectionSuggestions
                            }
                        }
                    
                    case .entry:
                    
                        guard let currentEntryId = entryId else {
                            loggerCoreData.error("Failed to get new topic ID")
                            return
                        }
                    
                    if let updatedEntry = await openAISwiftService.processEntry(entryId: currentEntryId) {
                        loggerOpenAI.log("Updated new entry with insights and summary")
                        await MainActor.run {
                            self.updatedEntry = updatedEntry
                        }
                    }
                    
                    default:
                        
                        guard let currentTopicId = topicId else {
                            loggerCoreData.error("Failed to get new topic ID")
                            return
                        }
                        await openAISwiftService.processNewTopic(topicId: currentTopicId)
                        
                        loggerOpenAI.log("Added new sections to topic")
                    }
                
                    await MainActor.run {
                        if selectedAssistant != .entry {
                            self.topicUpdated = true
                        }
                    }
                }
                
                
         
        } catch {
            loggerOpenAI.error("Failed to get OpenAI streamed response: \(error.localizedDescription)")
           
        }
           
    }
    
    
    
    private func createThread(selectedAssistant: AssistantItem) async -> String? {
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
            return nil
        }
        
    }
    
    //for creating a set of questions to gather context on a topic
    private func sendFirstMessage(selectedAssistant: AssistantItem, threadId: String, topicId: UUID? = nil, transcript: String? = nil, section: Section? = nil, userInput: [String]? = nil) async {
            
        do {
            var userContext: String = ""
            
            switch selectedAssistant {
                case .section, .focusArea:
                    guard let currentTopic = topicId else {
                        loggerCoreData.error("Failed to get new topic ID")
                        return
                    }
                    
                    guard let gatheredContext = await ContextGatherer.gatherContextGeneral(dataController: dataController, loggerCoreData: loggerCoreData, topicId: currentTopic, userInput: userInput) else {
                        loggerCoreData.error("Failed to get user context")
                        return
                    }
                    userContext += gatheredContext
                   
                case .sectionSummary:
                    guard let currentSection = section else {
                        loggerCoreData.error("No current section found")
                        return
                    }
                    
                    guard let gatheredContext = await ContextGatherer.gatherContextUpdateTopic(dataController: dataController, loggerCoreData: loggerCoreData, section: currentSection) else {
                        loggerCoreData.error("Failed to get user context")
                        return
                    }
                    userContext += gatheredContext
                    
                    
                case .sectionSuggestions:
                    guard let currentTopic = topicId else {
                        loggerCoreData.error("Failed to get new topic ID")
                        return
                    }
                    
                    guard let gatheredContext = await ContextGatherer.gatherContextGeneral(dataController: dataController, loggerCoreData: loggerCoreData, topicId: currentTopic) else {
                        loggerCoreData.error("Failed to get user context")
                        return
                    }
                    userContext += gatheredContext
                
                case .entry:
                    guard let currentTopic = topicId else {
                       loggerCoreData.error("Failed to get new topic ID")
                       return
                   }

                   guard let newTranscript = transcript else {
                       loggerCoreData.error("Failed to get transcript")
                       return
                   }
                    
                    guard let gatheredContext = await ContextGatherer.gatherContextGeneral(dataController: dataController, loggerCoreData: loggerCoreData, topicId: currentTopic, transcript: newTranscript) else {
                        loggerCoreData.error("Failed to get user context")
                        return
                    }
                    userContext += gatheredContext
                
                default:
                    break

            }
            
            
            
            if let newMessage = try await openAISwiftService.createMessage(threadId: threadId, content: userContext) {
               
                loggerOpenAI.info("First message sent: \(newMessage.content)")
                
            }
                
            } catch {
                loggerOpenAI.error("Error sending user message to OpenAI: \(error.localizedDescription)")
            }
        }
}
