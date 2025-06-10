//
//  TopicDaily-CoreDataHelpers.swift
//  Fearless2
//
//  Created by Yue Deng-Wu on 10/1/24.
//

import Foundation

extension TopicDaily: TopicRepresentable {
    
    var topicId: UUID {
        get { id ?? UUID()}
        set { id = newValue}
    }
    
    var topicCreatedAt: String {
        get { createdAt ?? "" }
        set { createdAt = newValue }
    }
    
    var topicStatus: String {
        get { status ?? "" }
        set { status = newValue }
    }
    
    var topicEmoji: String {
        get { emoji ?? "" }
        set { emoji = newValue }
    }
    
    var topicTitle: String {
        get { title ?? "" }
        set { title = newValue }
    }
    
    var topicTheme: String {
        get { theme ?? "" }
        set { theme = newValue }
    }
    
    var topicQuestions: [Question] {
        let result = questions?.allObjects as? [Question] ?? []
        return result
    }
    
    var topicExpectations: [TopicExpectation] {
        let result = expectations?.allObjects as? [TopicExpectation] ?? []
        return result
    }
    
    var topicFeedback: [TopicFeedback] {
        let result = feedback?.allObjects as? [TopicFeedback] ?? []
        return result
    }
    
    func assignReview(_ review: TopicReview) {
        self.review = review
        review.topicDaily = self
    }
}
