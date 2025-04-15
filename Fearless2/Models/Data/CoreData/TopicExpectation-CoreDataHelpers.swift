//
// TopicExpectation-CoreDataHelpers.swift
//  Fearless2
//
//  Created by Yue Deng-Wu on 3/10/25.
//

import Foundation

extension TopicExpectation {
    
    var expectationId: UUID {
        get { id ?? UUID() }
        set { id = newValue }
    }
    
    var expectationContent: String {
        get { content ?? "" }
        set { content = newValue }
    }
}
