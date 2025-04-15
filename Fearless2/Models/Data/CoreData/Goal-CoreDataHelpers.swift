//
// Goal-CoreDataHelpers.swift
//  Fearless2
//
//  Created by Yue Deng-Wu on 3/10/25.
//

import Foundation

extension Goal {
    
    var goalId: UUID {
        get { id ?? UUID() }
        set { id = newValue }
    }
    
    var goalTitle: String {
        get { title ?? "" }
        set { title = newValue }
    }
    
    var goalProblemType: String {
        get { problemType ?? "" }
        set { problemType = newValue }
    }
    
    var goalCreatedAt: String {
        get { createdAt ?? "" }
        set { createdAt = newValue }
    }
    
    var goalCompletedAt: String {
        get { completedAt ?? "" }
        set { completedAt = newValue }
    }
    
    var goalProblem: String {
        get { problem ?? "" }
        set { problem = newValue }
    }
    
    var goalResolution: String {
        get { resolution ?? "" }
        set { resolution = newValue }
    }
    
    var goalSequences: [Sequence] {
        let result = sequences?.allObjects as? [Sequence] ?? []
        return result
    }
    
    var goalQuestions: [Question] {
        let result = questions?.allObjects as? [Question] ?? []
        return result
    }
    
}
