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
    func manageRun(selectedAssistant: AssistantItem, category: CategoryItem, userInput: String, topicId: UUID? = nil, question: String? = nil) async {
    
        //reset published vars
        await MainActor.run {
            self.threadId = nil
            self.topicUpdated = false
            
        }

        await manageRunWithStreaming(selectedAssistant: selectedAssistant, category: category, userInput: userInput, topicId: topicId, question: question, retryCount: 1)
        
    }
    
    func manageRunWithStreaming(selectedAssistant: AssistantItem, category: CategoryItem, userInput: String, topicId: UUID? = nil, question: String? = nil, retryCount: Int) async {
        
        guard let threadId = await createThread(selectedAssistant: selectedAssistant) else {
            return
        }
        
        await sendFirstMessage(selectedAssistant: selectedAssistant, threadId: threadId, category: category.getFullName(), userInput: userInput, topicId: topicId, question: question)
        
        
        do {
            try await openAISwiftService.createRunAndStreamMessage(threadId: threadId, selectedAssistant: selectedAssistant)
                
                switch selectedAssistant {
                default:
                    if !openAISwiftService.functionContent.isEmpty {
                        
                        await openAISwiftService.processTopic(category: category.getShortName(), topicId: topicId)
                           
                        loggerOpenAI.log("Processed new topic with ID: \(topicId?.uuidString ?? "")")
                            
                            
                            await MainActor.run {
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
    
    private func sendFirstMessage(selectedAssistant: AssistantItem, threadId: String, category: String, userInput: String, topicId: UUID? = nil, question: String? = nil) async {
            
        do {
            var userContext: String = ""
            
            switch selectedAssistant {
                default:
                
                userContext += "The user is looking to: \(category).\n\n Here is their message: \(userInput)"
                
                guard let selectedQuestion = question else { break }
                
                userContext += "Here is the question that the user is answering: \(selectedQuestion)\n\n"
            }
            
            //gather context
            
            if let existingTopicId = topicId {
                guard let gatheredContext = await ContextGatherer.gatherContext(dataController: dataController, loggerCoreData: loggerCoreData, topicId: existingTopicId) else {
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
