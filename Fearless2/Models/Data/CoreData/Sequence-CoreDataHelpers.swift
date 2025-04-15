//
// Sequence-CoreDataHelpers.swift
//  Fearless2
//
//  Created by Yue Deng-Wu on 3/10/25.
//

import Foundation

extension Sequence {
    
    var sequenceId: UUID {
        get { id ?? UUID() }
        set { id = newValue }
    }
    
    var sequenceTitle: String {
        get { title ?? "" }
        set { title = newValue }
    }
    
    var sequenceCreatedAt: String {
        get { createdAt ?? "" }
        set { createdAt = newValue }
    }
    
    var sequenceCompletedAt: String {
        get { completedAt ?? "" }
        set { completedAt = newValue }
    }
    
    var sequenceStatus: String {
        get { status ?? "" }
        set { status = newValue }
    }
    
    var sequenceIntent: String {
        get { intent ?? "" }
        set { intent = newValue }
    }
    
    var sequenceObjectives: String {
        get { objectives ?? "" }
        set { objectives = newValue }
    }
    
    var sequenceTopics: [Topic] {
        let result = topics?.allObjects as? [Topic] ?? []
        return result
    }
    
}
