//
//  Category-CoreDataHelpers.swift
//  Fearless2
//

import Foundation

extension Category {
    
    var categoryId: UUID {
        get { id ?? UUID() }
        set { id = newValue }
    }
    
    var categoryName: String {
        get { name ?? "" }
        set { name = newValue }
    }
    
    var categoryCreatedAt: String {
        get { createdAt ?? "" }
        set { createdAt = newValue }
    }
    
    var categoryLifeArea: String {
        get { lifeArea ?? "" }
        set { lifeArea = newValue }
    }
    
    var categoryDiscovered: String {
        get { discovered ?? "" }
        set { discovered = newValue }
    }
    
    var categoryUndiscovered: String {
        get { undiscovered ?? "" }
        set { undiscovered = newValue }
    }
    
    var categoryTopics: [Topic] {
        let result = topics?.allObjects as? [Topic] ?? []
        return result
    }
}

