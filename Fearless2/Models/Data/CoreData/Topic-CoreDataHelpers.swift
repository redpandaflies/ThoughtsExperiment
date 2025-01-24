//
//  Topic-CoreDataHelpers.swift
//  Fearless2
//
//  Created by Yue Deng-Wu on 10/1/24.
//

import Foundation

extension Topic {
    
    var topicId: UUID {
        get { id ?? UUID()}
        set { id = newValue}
    }
    
    var topicCreatedAt: String {
        get { createdAt ?? "" }
        set { createdAt = newValue }
    }
    
    var topicCategory: String {
        get { category ?? "" }
        set { category = newValue }
    }
    
    var topicStatus: String {
        get { status ?? "" }
        set { status = newValue }
    }
    
    var topicTitle: String {
        get { title ?? "" }
        set { title = newValue }
    }
    
    var topicDefinition: String {
        get { definition ?? "" }
        set { definition = newValue }
    }
    
    var topicSummary: String {
        get { summary ?? "" }
        set { summary = newValue }
    }
    
    var topicMainImage: String {
        get { mainImage ?? "" }
        set { mainImage = newValue }
    }
    
    var topicQuestions: [Question] {
        let result = questions?.allObjects as? [Question] ?? []
        return result
    }
    
    
    var topicSections: [Section] {
        let result = sections?.allObjects as? [Section] ?? []
        return result
    }
    
    var topicFocusAreas: [FocusArea] {
        let result = focusAreas?.allObjects as? [FocusArea] ?? []
        return result
    }
    
    var topicEntries: [Entry] {
        let result = entries?.allObjects as? [Entry] ?? []
        return result
    }
    
    var topicInsights: [Insight] {
        let result = insights?.allObjects as? [Insight] ?? []
        return result
    }
    
    var topicSuggestions: [FocusAreaSuggestion] {
        let result = suggestions?.allObjects as? [FocusAreaSuggestion] ?? []
        return result
    }
    
    func assignReview(_ review: TopicReview) {
        self.review = review
        review.topic = self
    }
}
