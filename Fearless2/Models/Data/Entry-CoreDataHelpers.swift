//
//  Entry-CoreDataHelpers.swift
//  Fearless2
//
//  Created by Yue Deng-Wu on 10/28/24.
//

import Foundation

extension Entry {
    var entryId: UUID {
        get { id ?? UUID()}
        set { id = newValue}
    }
    
    var entryCreatedAt: String {
        get { createdAt ?? "" }
        set { createdAt = newValue }
    }
    
    var entrySummary: String {
        get { summary ?? "" }
        set { summary = newValue }
    }
    
    var entryFeedback: String {
        get { feedback ?? "" }
        set { feedback = newValue }
    }
    
    var entryInsights: [Insight] {
        let result = insights?.allObjects as? [Insight] ?? []
        return result
    }
    
}
