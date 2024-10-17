//
//  TopicViewModel.swift
//  Fearless2
//
//  Created by Yue Deng-Wu on 10/2/24.
//

import Foundation
import OSLog

final class TopicViewModel: ObservableObject {
    
    @Published var topicUpdated: Bool = false
    
    private var openAISwiftService: OpenAISwiftService
    private var dataController: DataController
    
    var threadId: String? = nil //needed for cancelling runs
    
    let loggerOpenAI = Logger.openAIEvents
    let loggerCoreData = Logger.coreDataEvents
    
    init(openAISwiftService: OpenAISwiftService, dataController: DataController) {
        self.openAISwiftService = openAISwiftService
        self.dataController = dataController
    }
    
    //MARK: create new topic
    //note: send the full name of category to GPT as context, save the short name to CoreData
    //note: kept the optionals for userInput and question for now, in case we want to add back in the follow-up questions and summary
    func manageRun(selectedAssistant: AssistantItem, category: TopicCategoryItem, userInput: String? = nil, topicId: UUID? = nil, sectionId: UUID? = nil, question: String? = nil) async {
    
        //reset published vars
        await MainActor.run {
            self.threadId = nil
            self.topicUpdated = false
        }

        await manageRunWithStreaming(selectedAssistant: selectedAssistant, category: category, userInput: userInput, topicId: topicId, sectionId: sectionId, question: question, retryCount: 1)
        
    }
    
    func manageRunWithStreaming(selectedAssistant: AssistantItem, category: TopicCategoryItem, userInput: String? = nil, topicId: UUID? = nil, sectionId: UUID? = nil, question: String? = nil, retryCount: Int) async {
        
        guard let threadId = await createThread(selectedAssistant: selectedAssistant) else {
            return
        }
        
        guard let newTopicId = topicId else {
            loggerCoreData.error("Failed to get new topic ID")
            return
        }
        
        await sendFirstMessage(selectedAssistant: selectedAssistant, threadId: threadId, category: category.getFullName(), topicId: newTopicId, sectionId: sectionId)
        
        
        do {
            try await openAISwiftService.createRunAndStreamMessage(threadId: threadId, selectedAssistant: selectedAssistant)
                
            if !openAISwiftService.functionContent.isEmpty {
                
                switch selectedAssistant {
                case .context:
                    await openAISwiftService.processSections(category: category.getShortName(), topicId: newTopicId)
                case .topic:
                    await openAISwiftService.processTopic(category: category.getShortName(), topicId: newTopicId)
                }
                loggerOpenAI.log("Processed new topic with ID: \(topicId?.uuidString ?? "")")
                    
                    
                    await MainActor.run {
                        self.topicUpdated = true
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
    private func sendFirstMessage(selectedAssistant: AssistantItem, threadId: String, category: String, topicId: UUID, sectionId: UUID? = nil) async {
            
        do {
            var userContext: String = ""
            
            switch selectedAssistant {
            case .context:
                guard let gatheredContext = await ContextGatherer.gatherContextNewTopic(dataController: dataController, loggerCoreData: loggerCoreData, topicId: topicId) else {
                    loggerCoreData.error("Failed to get user context")
                    return
                }
                
                userContext += gatheredContext
                
            case .topic:
                guard let gatheredContext = await ContextGatherer.gatherContextUpdateTopic(dataController: dataController, loggerCoreData: loggerCoreData, topicId: topicId, sectionId: sectionId) else {
                    loggerCoreData.error("Failed to get user context")
                    return
                }
                
                userContext += gatheredContext
            }
            
            
                
            if let newMessage = try await openAISwiftService.createMessage(threadId: threadId, content: userContext) {
               
                loggerOpenAI.info("First message sent: \(newMessage.content)")
                
            }
                
            } catch {
                loggerOpenAI.error("Error sending user message to OpenAI: \(error.localizedDescription)")
            }
        }
}
