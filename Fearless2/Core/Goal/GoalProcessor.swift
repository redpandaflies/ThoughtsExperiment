//
//  GoalProcessor.swift
//  Fearless2
//
//  Created by Yue Deng-Wu on 6/5/25.
//

import Foundation
import CoreData
import OSLog

final class GoalProcessor {
    private let context: NSManagedObjectContext
    private let loggerCoreData = Logger.coreDataEvents
    private let loggerOpenAI = Logger.openAIEvents
    
    init(context: NSManagedObjectContext) {
        self.context = context
    }
    
    // MARK: - process JSON
    // MARK: New Category summary
    func processCreateCategorySummary(messageText: String, goal: Goal) async throws -> NewCreateCategorySummary? {
        
        // Decode the arguments to get the category summary
        guard let categorySummary = JSONHelper.decode(messageText, as: NewCreateCategorySummary.self) else {
            loggerOpenAI.error("Couldn't decode arguments for category summary.")
            throw ProcessingError.decodingError("category summary")
        }
        
        //add goal attributes
        try await context.perform {
            goal.goalProblemLong = categorySummary.summary
            goal.goalTitle = categorySummary.goal.title
            goal.goalProblem = categorySummary.goal.problem
            goal.goalResolution = categorySummary.goal.resolution
            
            try self.context.save()
        }
        
        return categorySummary
    }
    
    // MARK: Plan suggestions
    func processPlanSuggestions(messageText: String) async throws -> NewPlanSuggestions? {
        
        // Decode the arguments to get the plan suggestions
        guard let planSuggestions = JSONHelper.decode(messageText, as: NewPlanSuggestions.self) else {
            loggerOpenAI.error("Couldn't decode arguments for plan suggestions.")
            throw ProcessingError.decodingError("plan suggestions")
        }
        
        return planSuggestions
    }
    
}

