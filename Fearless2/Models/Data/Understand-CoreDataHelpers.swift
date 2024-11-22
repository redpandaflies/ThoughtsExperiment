//
//  Understand-CoreDataHelpers.swift
//  Fearless2
//
//  Created by Yue Deng-Wu on 11/20/24.
//

import Foundation

extension Understand {
    
    var understandId: UUID {
        get { id ?? UUID()}
        set { id = newValue}
    }
    
    var understandCreatedAt: String {
        get { createdAt ?? "" }
        set { createdAt = newValue }
    }
    
    var understandQuestion: String {
        get { question ?? "" }
        set { question = newValue }
    }
    
    var understandAnswer: String {
        get { answer ?? "" }
        set { answer = newValue }
    }
    
    
}
