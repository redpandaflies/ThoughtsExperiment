//
//  NewCategoryEligibilityChecker.swift
//  Fearless2
//
//  Created by Yue Deng-Wu on 3/7/25.
//
import SwiftUI

struct NewCategoryEligibilityChecker {
    // Required topic counts for each realm
    private let requiredTopicsforNewCategory = [2, 5, 10, 18, 31, 53]
    
    
    /// Checks both eligibility for a new realm and whether user already has that realm
    /// - Parameters:
    ///   - category: The current category with topics
    ///   - totalCategories: Total number of categories the user currently has
    /// - Returns: Boolean indicating if user is eligible for a new realm they don't already have
    func checkEligibility(topics: FetchedResults<Topic>, totalCategories: Int) -> Bool {
        // Count completed topics
        let completedTopicsCount = topics.filter { $0.completed }.count
        
        // Check if completed count matches a requirement
        if let realmIndex = requiredTopicsforNewCategory.firstIndex(of: completedTopicsCount) {
            // Expected number of realms at this point (realmIndex + 2 because we start at realm 2)
            let expectedRealms = realmIndex + 2
            
            // User is eligible for a new realm AND doesn't already have it
            return totalCategories < expectedRealms
        }
        
        // Not eligible for a new realm
        return false
    }
}
