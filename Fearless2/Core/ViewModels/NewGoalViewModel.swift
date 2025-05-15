//
//  NewGoalViewModel.swift
//  Fearless2
//
//  Created by Yue Deng-Wu on 10/2/24.
//

import Foundation
import OSLog
import UIKit

final class NewGoalViewModel: ObservableObject {
    @Published var newCategorySummary: NewCreateCategorySummary? = nil
    @Published var newPlanSuggestions: [NewPlan] = []
    @Published var createNewCategorySummary: NewCategorySummary = .ready
    @Published var createPlanSuggestions: PlanSuggestionsState = .ready
    var currentCategory: Category? = nil
    var currentGoal: Goal? = nil
    
    private var dataController: DataController
    private var openAISwiftService: OpenAISwiftService
    private var assistantRunManager: AssistantRunManager
    
    private var backgroundTaskID: UIBackgroundTaskIdentifier = .invalid
    
    let loggerOpenAI = Logger.openAIEvents
    let loggerCoreData = Logger.coreDataEvents
    
    init(dataController: DataController, openAISwiftService: OpenAISwiftService, assistantRunManager: AssistantRunManager) {
        self.dataController = dataController
        self.openAISwiftService = openAISwiftService
        self.assistantRunManager = assistantRunManager
    }
    
    enum NewCategorySummary {
        case ready
        case loading
        case retry
    }
    
    enum PlanSuggestionsState {
        case ready
        case loading
        case retry
    }
    
    func manageRun(selectedAssistant: AssistantItem, category: Category, goal: Goal, sequence: Sequence? = nil) async throws {
    
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
            self.newCategorySummary = nil
            self.newPlanSuggestions = []
            if selectedAssistant == .planSuggestion {
                createPlanSuggestions = .loading
            } else {
                createPlanSuggestions = .ready
            }
            if selectedAssistant == .newGoal {
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
                guard let newSummary = try await openAISwiftService.processCreateCategorySummary(messageText: messageText, goal: goal) else {
                    
                    loggerOpenAI.error("Failed to process new category flow summary")
                    throw ProcessingError.processingFailed()
                    
                }
                
                await MainActor.run {
                    self.newCategorySummary = newSummary
                    self.createNewCategorySummary = .ready
                    self.loggerOpenAI.log("New category summary ready")
                }
                
                case .planSuggestion:
                guard let newSuggestions = try await openAISwiftService.processPlanSuggestions(messageText: messageText) else {
                    
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
    
    func cancelCurrentRun() async {
        let threadId = openAISwiftService.threadId
        if !threadId.isEmpty {
            do {
                try await openAISwiftService.cancelRun()
            } catch {
                loggerOpenAI.error("Failed to cancel current run: \(error.localizedDescription)")
            }
        }
    }
}
