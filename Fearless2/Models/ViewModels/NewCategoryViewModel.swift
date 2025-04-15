//
//  NewCategoryViewModel.swift
//  Fearless2
//
//  Created by Yue Deng-Wu on 10/2/24.
//

import Foundation
import OSLog

final class NewCategoryViewModel: ObservableObject {
    @Published var newCategorySummary: NewCreateCategorySummary? = nil
    @Published var newPlanSuggestions: [NewPlan] = []
    @Published var createNewCategorySummary: NewCategorySummary = .ready
    @Published var createPlanSuggestions: PlanSuggestionsState = .ready
    var currentCategory: Category? = nil
    var currentGoal: Goal? = nil
    
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
    
    func manageRun(selectedAssistant: AssistantItem, category: Category, goal: Goal) async throws {
    
        //reset published vars
        await MainActor.run {
            self.newCategorySummary = nil
            self.newPlanSuggestions = []
            if selectedAssistant == .planSuggestion {
                createPlanSuggestions = .loading
            } else {
                createPlanSuggestions = .ready
            }
            if selectedAssistant == .newCategory {
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
                goal: goal
            )

            switch selectedAssistant {
                case .newCategory:
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
    
    
}
