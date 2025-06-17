//
//  NewGoalViewModel.swift
//  Fearless2
//
//  Created by Yue Deng-Wu on 10/2/24.
//

import Combine
import Foundation
import OSLog
import UIKit

final class NewGoalViewModel: ObservableObject, PlanSuggestionsObservable {
    
    @Published var newCategorySummary: NewCreateCategorySummary? = nil
    @Published var newPlanSuggestions: [NewPlan] = []
    @Published var createNewCategorySummary: LoadingStatePrimary = .ready
    @Published var createPlanSuggestions: LoadingStatePrimary = .ready
    @Published var completedLoadingAnimationSummary: Bool = false
    @Published var completedLoadingAnimationPlan: Bool = false
    
    var createPlanSuggestionsPublisher: Published<LoadingStatePrimary>.Publisher { $createPlanSuggestions }
    var completedLoadingAnimationPlanPublisher: Published<Bool>.Publisher { $completedLoadingAnimationPlan }
    
    var currentCategory: Category? = nil
    var currentGoal: Goal? = nil
    
    private var dataController: DataController
    private var goalProcessor: GoalProcessor
    private var assistantRunManager: AssistantRunManager
    
    private var backgroundTaskID: UIBackgroundTaskIdentifier = .invalid
    
    let loggerOpenAI = Logger.openAIEvents
    let loggerCoreData = Logger.coreDataEvents
    
    init(dataController: DataController,
         goalProcessor: GoalProcessor,
         assistantRunManager: AssistantRunManager) {
        self.dataController = dataController
        self.goalProcessor = goalProcessor
        self.assistantRunManager = assistantRunManager
    }
    
    func manageRun(
        selectedAssistant: AssistantItem,
        category: Category,
        goal: Goal,
        sequence: Sequence? = nil
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
        
        //reset published vars
        await MainActor.run {
            
            if selectedAssistant == .planSuggestion {
                self.newPlanSuggestions = []
                createPlanSuggestions = .loading
            } else {
                createPlanSuggestions = .ready
            }
            
            if selectedAssistant == .newGoal {
                self.newCategorySummary = nil
                createNewCategorySummary = .loading
            } else {
                createNewCategorySummary = .ready
            }
            currentCategory = category
            currentGoal = goal
        }
        
        do {
            let messageText = try await assistantRunManager.runAssistant(
                selectedAssistant: selectedAssistant,
                category: category,
                goal: goal,
                sequence: sequence
            )

            switch selectedAssistant {
                case .newGoal:
                guard let newSummary = try await goalProcessor.processCreateCategorySummary(messageText: messageText, goal: goal) else {
                    
                    loggerOpenAI.error("Failed to process new category flow summary")
                    throw ProcessingError.processingFailed()
                    
                }
                
                await MainActor.run {
                    self.newCategorySummary = newSummary
                    self.createNewCategorySummary = .ready
                    self.loggerOpenAI.log("New category summary ready: \(self.newCategorySummary?.summary ?? "")")
                }
                
                case .planSuggestion:
                    guard let newSuggestions = try await goalProcessor.processPlanSuggestions(messageText: messageText) else {
                        
                        loggerOpenAI.error("Failed to process new plan suggestions")
                        throw ProcessingError.processingFailed()
                        
                    }
                    
                    await MainActor.run {
                        self.newPlanSuggestions = newSuggestions.plans
                        createPlanSuggestions = .ready
                        self.loggerOpenAI.log("New plan suggestions ready")
                    }
                
                default:
                break
                }
                
         
        } catch {
            loggerOpenAI.error("Failed to get OpenAI streamed response: \(error.localizedDescription)")
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
    
}
