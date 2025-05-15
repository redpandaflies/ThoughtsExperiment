//
//  TopicReview-CoreDataHelpers.swift
//  Fearless2
//
//  Created by Yue Deng-Wu on 10/1/24.
//

import Foundation

extension TopicReview {
    
    var reviewId: UUID {
        get { id ?? UUID()}
        set { id = newValue}
    }
    
    var reviewCreatedAt: String {
        get { createdAt ?? "" }
        set { createdAt = newValue }
    }
    
    var reviewOverview: String {
        get { overview ?? "" }
        set { overview = newValue }
    }
    
    var reviewSummary: String {
        get { summary ?? "" }
        set { summary = newValue }
    }
    
}
