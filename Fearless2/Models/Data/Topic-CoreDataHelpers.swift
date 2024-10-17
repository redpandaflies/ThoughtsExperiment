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
    
    var topicTitle: String {
        get { title ?? "" }
        set { title = newValue }
    }
    
    var topicUserDescription: String {
        get { userDescription ?? "" }
        set { userDescription = newValue }  
    }
    
    var topicFeedback: String {
        get { feedback ?? "" }
        set { feedback = newValue }
    }
    
    var topicSummary: String {
        get { summary ?? "" }
        set { summary = newValue }
    }
    
    var topicOptions: String {
        get { options ?? "" }
        set { options = newValue }
    }
    
    var topicCriteria: String {
        get { criteria ?? "" }
        set { criteria = newValue }
    }
    
    var topicPeople: String {
        get { people ?? "" }
        set { people = newValue }
    }
    
    var topicEmotions: String {
        get { emotions ?? "" }
        set { emotions = newValue }
    }
    
    var topicQuestions: [Question] {
        let result = questions?.allObjects as? [Question] ?? []
        return result
    }
    
    
    var topicSections: [Section] {
        let result = sections?.allObjects as? [Section] ?? []
        return result
    }
}
