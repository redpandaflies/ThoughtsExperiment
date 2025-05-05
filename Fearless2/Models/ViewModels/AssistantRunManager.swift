//
//  AssistantRunManager.swift
//  Fearless2
//
//  Created by Yue Deng-Wu on 10/2/24.
//

import Foundation
import OSLog

final class AssistantRunManager {
    
    private var openAISwiftService: OpenAISwiftService
    private var dataController: DataController
    let loggerOpenAI = Logger.openAIEvents
    let loggerCoreData = Logger.coreDataEvents
    
    init(openAISwiftService: OpenAISwiftService, dataController: DataController) {
        self.openAISwiftService = openAISwiftService
        self.dataController = dataController
    }
    
    func runAssistant (
        selectedAssistant: AssistantItem,
        category: Category? = nil,
        goal: Goal? = nil,
        sequence: Sequence? = nil,
        topicId: UUID? = nil,
        focusArea: FocusArea? = nil,
        topic: Topic? = nil
    ) async throws -> String {
        
        //create new thread
        guard let threadId = try await createThread() else {
            loggerOpenAI.error("Failed to create thread")
            throw OpenAIError.missingRequiredField("Thread ID not created")
        }
        
        //get context to send to OpenAI
        try await sendFirstMessage(selectedAssistant: selectedAssistant, threadId: threadId, category: category, goal: goal, sequence: sequence, topicId: topicId, focusArea: focusArea, topic: topic)
        
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
        
        
       return messageText ?? ""
        
    }
    
    
    private func createThread() async throws -> String? {
        do {
            
            let newthreadId = try await openAISwiftService.createThread()
            
            guard let threadId = newthreadId else {
                loggerOpenAI.error("No thread ID received from OpenAI")
                
                return nil
            }
            
            return threadId
            
        } catch {
            loggerOpenAI.error("Failed to create thread: \(error.localizedDescription)")
            throw OpenAIError.requestFailed(error, "Failed to create thread")
        }
        
    }
    
    // for sending first message and gathering context to send to AI
    private func sendFirstMessage(
        selectedAssistant: AssistantItem,
        threadId: String,
        category: Category? = nil,
        goal: Goal? = nil,
        sequence: Sequence? = nil,
        topicId: UUID? = nil,
        focusArea: FocusArea? = nil,
        topic: Topic? = nil
    ) async throws {
        
        let userContext = try await gatherUserContext(
            selectedAssistant: selectedAssistant,
            category: category,
            goal: goal,
            sequence: sequence,
            topicId: topicId,
            focusArea: focusArea,
            topic: topic
        )
        
        try await sendMessageWithContext(threadId: threadId, userContext: userContext)
    }
    
    private func gatherUserContext(
        selectedAssistant: AssistantItem,
        category: Category? = nil,
        goal: Goal? = nil,
        sequence: Sequence? = nil,
        topicId: UUID? = nil,
        focusArea: FocusArea? = nil,
        topic: Topic? = nil
    ) async throws -> String {
        
        //topic suggestion assistant only
        switch selectedAssistant {
        case .newCategory, .planSuggestion, .sequenceSummary:
            guard let currentCategory = category else {
                loggerCoreData.error("Failed to get current category")
                throw ContextError.missingRequiredField("Category")
            }
            
            guard let currentGoal = goal else {
                loggerCoreData.error("Failed to get current goal")
                throw ContextError.missingRequiredField("Goal")
            }
            
            guard let gatheredContext = await ContextGatherer.gatherContext(dataController: dataController, loggerCoreData: loggerCoreData, selectedAssistant: selectedAssistant, category: currentCategory, goal: currentGoal, sequence: sequence) else {
                loggerCoreData.error("Failed to get context")
                throw ContextError.noContextFound("Context")
            }
            return gatheredContext
        
        case .topic, .topicOverview, .topicBreak:
            guard let currentTopic = topic else {
                loggerCoreData.error("Failed to get new topic")
                throw ContextError.missingRequiredField("Topic")
            }
         
            
            guard let gatheredContext = await ContextGatherer.gatherContextTopic(dataController: dataController, loggerCoreData: loggerCoreData, topic: currentTopic) else {
                loggerCoreData.error("Failed to get context ")
                throw ContextError.noContextFound("Context")
            }
            
            return gatheredContext
        
        default:
            return ""
            
        }
        
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
}
