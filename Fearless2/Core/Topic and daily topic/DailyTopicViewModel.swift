//
//  DailyTopicViewModel.swift
//  Fearless2
//
//  Created by Yue Deng-Wu on 6/5/25.
//

import Foundation
import OSLog
import UIKit

final class DailyTopicViewModel: ObservableObject, TopicRecapObservable {
    
    // manage API calls states
    @Published var createTopicRecap: LoadingStatePrimary = .ready
    @Published var createTopic: LoadingStatePrimary = .ready
    @Published var createTopicQuestions: LoadingStatePrimary = .ready
    
    var createTopicRecapPublisher: Published<LoadingStatePrimary>.Publisher { $createTopicRecap }
    var completedLoadingAnimationSummaryPublisher: Published<Bool>.Publisher { $completedLoadingAnimationSummary }
    
    // manage UI updates
    /// triggers update of progress bar for sequence (plan)
    @Published var completedNewTopic: Bool = false
    @Published var completedLoadingAnimationSummary: Bool = false
    
    // save new topic so it can be used to generate questions
    var currentTopic: TopicDaily? = nil
    
    private var dataController: DataController
    private var topicProcessor: TopicProcessor
    private var assistantRunManager: AssistantRunManager
    
    private var backgroundTaskID: UIBackgroundTaskIdentifier = .invalid
    
    let loggerOpenAI = Logger.openAIEvents
    let loggerCoreData = Logger.coreDataEvents
    
    init(
        dataController: DataController,
        topicProcessor: TopicProcessor,
        assistantRunManager: AssistantRunManager
    ) {
        self.dataController = dataController
        self.topicProcessor = topicProcessor
        self.assistantRunManager = assistantRunManager
    }
    
    func manageRun(
        selectedAssistant: AssistantItem,
        topic: TopicDaily? = nil
    ) async throws {
        
        // Start a background task to give iOS extra time when you go background
        await MainActor.run {
            // capture the task ID in a local constant
            self.backgroundTaskID = UIApplication.shared.beginBackgroundTask (withName: "Finish Network Tasks") {
                // End the task if time expires.
                UIApplication.shared.endBackgroundTask(self.backgroundTaskID)
                    self.backgroundTaskID = UIBackgroundTaskIdentifier.invalid
                }
        }

        defer {
          Task { @MainActor in
            UIApplication.shared.endBackgroundTask(backgroundTaskID)
              self.backgroundTaskID = UIBackgroundTaskIdentifier.invalid
          }
        }
        
        do {
            //reset published vars
            await MainActor.run {
               
                if selectedAssistant == .topicDailyRecap {
                    self.createTopicRecap = .loading
                }
                
                
                if selectedAssistant == .topicDaily {
                    if self.createTopic != .loading {
                        self.createTopic = .loading
                    }
                } else {
                    self.createTopic = .ready
                }
                
                if selectedAssistant == .topicDailyQuestions {
                    self.createTopicQuestions = .loading
                }
                
            }
            
            try await manageRunWithStreaming(
                selectedAssistant: selectedAssistant,
                topic: topic
            )
            
        } catch {
            loggerOpenAI.error("Failed to complete OpenAI run: \(error.localizedDescription), \(error)")
            throw OpenAIError.runIncomplete(error)
            
        }
        
    }
    
    func manageRunWithStreaming(
        selectedAssistant: AssistantItem,
        topic: TopicDaily?
    ) async throws {
        
        do {
            let messageText = try await assistantRunManager.runAssistant(
                selectedAssistant: selectedAssistant,
                topicDaily: topic
            )
            
            switch selectedAssistant {
                
            case .topicDaily:
                
               let newTopic = try await topicProcessor.processNewDailyTopic(messageText: messageText)
                
                await MainActor.run {
                    self.currentTopic = newTopic
                    self.createTopic = .ready
                    
                }
            
            case .topicDailyQuestions:
                
                guard let currentTopic = topic else {
                    loggerCoreData.log("Cannot process new questions, no topic found.")
                    
                    return
                }
                
                try await topicProcessor.processNewDailyTopicQuestions(messageText: messageText, topic: currentTopic)
                
                await MainActor.run {
                    self.createTopicQuestions = .ready
                }
                
            case .topicDailyRecap:
                
                guard let topic = topic else {
                    loggerCoreData.error("Failed to get topic")
                    return
                }
                
                try await topicProcessor.processTopicOverview(messageText: messageText, topic: topic)
                
                await MainActor.run {
                    self.createTopicRecap = .ready
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
        do {
            try await assistantRunManager.cancelCurrentRun()
        } catch {
            throw OpenAIError.missingRequiredField("No thread ID found")
        }
    }
    
    func markCompleteLoadingAnimationSummary() {
        completedLoadingAnimationSummary = true
    }
    
    
    // MARK: - Save data to coredata
    
    // save answer to topic question
    @MainActor
    func saveAnswer(
        questionType: QuestionType,
        topic: TopicRepresentable?,
        questionContent: String? = nil,
        questionId: UUID? = nil,
        userAnswer: Any,
        customItems: [String]? = nil
    ) async {
        do {
            try await topicProcessor.saveAnswer(
                questionType: questionType,
                topic: topic,
                questionContent: questionContent,
                questionId: questionId,
                userAnswer: userAnswer,
                customItems: customItems
            )
           
        } catch {
            loggerCoreData.error("\(error.localizedDescription)")
        }
    }
    
    //mark topic complete
    @MainActor
    func completeTopic(topic: TopicRepresentable) async {
        do {
            try await topicProcessor.completeTopic(topic: topic)
        } catch {
            loggerCoreData.error("\(error.localizedDescription)")
        }
    }
}

