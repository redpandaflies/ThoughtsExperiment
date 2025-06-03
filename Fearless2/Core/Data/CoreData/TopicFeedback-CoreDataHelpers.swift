//
// TopicFeedback-CoreDataHelpers.swift
//  Fearless2
//
//  Created by Yue Deng-Wu on 3/10/25.
//

import Foundation

extension TopicFeedback {
    
    var feedbackId: UUID {
        get { id ?? UUID() }
        set { id = newValue }
    }
    
    var feedbackContent: String {
        get { content ?? "" }
        set { content = newValue }
    }
}
