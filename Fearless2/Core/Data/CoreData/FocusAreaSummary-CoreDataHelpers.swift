//
//  FocusAreaSummary-CoreDataHelpers.swift
//  Fearless2
//
//  Created by Yue Deng-Wu on 11/23/24.
//

import Foundation

extension FocusAreaSummary {
    var summaryId: UUID {
        get { id ?? UUID()}
        set { id = newValue}
    }
    
    var summaryCreatedAt: String {
        get { createdAt ?? "" }
        set { createdAt = newValue }
    }
    
    var summarySummary: String {
        get { summary ?? "" }
        set { summary = newValue }
    }
    
    var summaryFeedback: String {
        get { feedback ?? "" }
        set { feedback = newValue }
    }
    
    var summaryInsights: [Insight] {
        let result = insights?.allObjects as? [Insight] ?? []
        return result
    }
    
}
