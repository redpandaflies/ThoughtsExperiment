////
////  UnderstandViewModel.swift
////  Fearless2
////
////  Created by Yue Deng-Wu on 10/2/24.
////
//
//import Foundation
//import OSLog
//
//final class UnderstandViewModel: ObservableObject {
//    
//    @Published var updatedAnswer: Understand? = nil
//    
//    private var openAISwiftService: OpenAISwiftService
//    private var dataController: DataController
//   
//    
//    var threadId: String? = nil //needed for cancelling runs
//    
//    let loggerOpenAI = Logger.openAIEvents
//    let loggerCoreData = Logger.coreDataEvents
//    
//    init(openAISwiftService: OpenAISwiftService, dataController: DataController) {
//        self.openAISwiftService = openAISwiftService
//        self.dataController = dataController
//    }
//    
//    func manageRun(selectedAssistant: AssistantItem, question: String) async {
//    
//        //reset published vars
//        await MainActor.run {
//            self.threadId = nil
//            self.updatedAnswer = nil
//        }
//
//        await manageRunWithStreaming(selectedAssistant: selectedAssistant, question: question, retryCount: 1)
//        
//    }
//    
//    func manageRunWithStreaming(selectedAssistant: AssistantItem, question: String, retryCount: Int) async {
//        
//        guard let threadId = await createThread(selectedAssistant: selectedAssistant) else {
//            return
//        }
//        
//        await sendFirstMessage(selectedAssistant: selectedAssistant, threadId: threadId, question: question)
//        
//        
//        do {
//            guard let messageText = try await openAISwiftService.createRunAndStreamMessage(threadId: threadId, selectedAssistant: selectedAssistant) else {
//                loggerOpenAI.error("No content received from OpenAI.")
//                return
//            }
//                
//           
//                
//            switch selectedAssistant {
//                
//                default:
//                let newAnswer = await openAISwiftService.processUnderstandAnswer(messageText: messageText, question: question)
//                    
//                    loggerOpenAI.log("Received response for question")
//                
//                    await MainActor.run {
//                        self.updatedAnswer = newAnswer
//                      
//                    }
//                }
//                
//         
//        } catch {
//            loggerOpenAI.error("Failed to get OpenAI streamed response: \(error.localizedDescription)")
//           
//        }
//           
//    }
//    
//    
//    
//    private func createThread(selectedAssistant: AssistantItem) async -> String? {
//        do {
//            
//            let newthreadId = try await openAISwiftService.createThread()
//            
//            guard let threadId = newthreadId else {
//                loggerOpenAI.error("No thread ID received from OpenAI")
//                
//                return nil
//            }
//            
//            //only needed to cancel a run, which happens when users dismiss loading views
//            await MainActor.run {
//                self.threadId = threadId
//            }
//            
//            return threadId
//            
//        } catch {
//            loggerOpenAI.error("Failed to create thread: \(error.localizedDescription)")
//            return nil
//        }
//        
//    }
//    
//    //for creating a set of questions to gather context on a topic
//    private func sendFirstMessage(selectedAssistant: AssistantItem, threadId: String, question: String) async {
//            
//        do {
//            var userContext: String = ""
//            
//            switch selectedAssistant {
//                default :
//                guard let gatheredContext = await ContextGatherer.gatherContextUnderstand(dataController: dataController, loggerCoreData: loggerCoreData, question: question) else {
//                        loggerCoreData.error("Failed to get user context")
//                        return
//                    }
//                    userContext += gatheredContext
//
//            }
//            
//            if let newMessage = try await openAISwiftService.createMessage(threadId: threadId, content: userContext) {
//               
//                loggerOpenAI.info("First message sent: \(newMessage.content)")
//                
//            }
//                
//            } catch {
//                loggerOpenAI.error("Error sending user message to OpenAI: \(error.localizedDescription)")
//            }
//        }
//}
