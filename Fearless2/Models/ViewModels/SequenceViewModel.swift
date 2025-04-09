//
//  SequenceViewModel.swift
//  Fearless2
//
//  Created by Yue Deng-Wu on 10/2/24.
//

import Foundation
import OSLog

final class SequenceViewModel: ObservableObject {
    
    private var dataController: DataController
    private var openAISwiftService: OpenAISwiftService
    private var assistantRunManager: AssistantRunManager
    
    let loggerOpenAI = Logger.openAIEvents
    let loggerCoreData = Logger.coreDataEvents
    
    init(dataController: DataController, openAISwiftService: OpenAISwiftService, assistantRunManager: AssistantRunManager) {
        self.dataController = dataController
        self.openAISwiftService = openAISwiftService
        self.assistantRunManager = assistantRunManager
    }
    
    func manageRun(selectedAssistant: AssistantItem, question: String) async throws {
    
        //reset published vars
//        await MainActor.run {
//
//        }
        
        do {
            let messageText = try await assistantRunManager.runAssistant(
                selectedAssistant: selectedAssistant
            )

            switch selectedAssistant {
                
                default:
                let newAnswer = await openAISwiftService.processUnderstandAnswer(messageText: messageText, question: question)
                    
                    loggerOpenAI.log("Received response for question")
                
                    await MainActor.run {
                       //update published var
                      
                    }
                }
                
         
        } catch {
            loggerOpenAI.error("Failed to get OpenAI streamed response: \(error.localizedDescription)")
            throw ProcessingError.processingFailed(error)
        }
        
    }
    
    
}
