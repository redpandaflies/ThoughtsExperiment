//
//  SequenceViewModel.swift
//  Fearless2
//
//  Created by Yue Deng-Wu on 10/2/24.
//

import Foundation
import OSLog

final class SequenceViewModel: ObservableObject {
    @Published var newPlanSuggestions: [NewPlan] = []
    @Published var createPlanSuggestions: PlanSuggestionsState = .ready
    @Published var createSequenceSummary: SequenceSummaryState = .ready
    
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
    
    
    enum PlanSuggestionsState {
        case ready
        case loading
        case retry
    }
    
    enum SequenceSummaryState {
        case ready
        case loading
        case retry
    }
    
    
    func manageRun(selectedAssistant: AssistantItem, category: Category?, goal: Goal?, sequence: Sequence? = nil) async throws {
    
        //reset published vars
        await MainActor.run {
            self.newPlanSuggestions = []
            if selectedAssistant == .planSuggestion {
                createPlanSuggestions = .loading
            } else {
                createPlanSuggestions = .ready
            }
            if selectedAssistant == .sequenceSummary {
                createSequenceSummary = .loading
            } else {
                createSequenceSummary = .ready
            }
        }
        
        do {
            let messageText = try await assistantRunManager.runAssistant(
                selectedAssistant: selectedAssistant,
                category: category,
                goal: goal,
                sequence: sequence
            )

            switch selectedAssistant {
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
            case .sequenceSummary:
                
                try await openAISwiftService.processSequenceSummary(messageText: messageText, sequence: sequence)
                
                await MainActor.run {
                    createSequenceSummary = .ready
                    self.loggerOpenAI.log("New sequence summary ready")
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
