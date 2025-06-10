//
//  GoalRepository.swift
//  Fearless2
//
//  Created by Yue Deng-Wu on 6/5/25.
//

import CoreData
import Foundation
import OSLog

final class GoalRepository {
    private let context: NSManagedObjectContext
    private let logger = Logger.coreDataEvents
    
    init(context: NSManagedObjectContext) {
        self.context = context
    }
    
    // get goals
    func fetchAllGoals() async -> [Goal] {
        let request: NSFetchRequest<Goal> = Goal.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: "createdAt", ascending: true)]
        
        var goals: [Goal] = []
        
        await context.perform {
            
            do {
                goals = try self.context.fetch(request)
            } catch {
                self.logger.log("Error fetching goals: \(error)")
            }
        }
        
        return goals
    }

}
