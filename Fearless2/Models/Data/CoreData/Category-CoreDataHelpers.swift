//
//  Category-CoreDataHelpers.swift
//  Fearless2
//

import Foundation

extension Category: CategoryProtocol {
    
    var categoryId: UUID {
        get { id ?? UUID() }
        set { id = newValue }
    }
    
    var categoryEmoji: String {
        get { emoji ?? "" }
        set { emoji = newValue }
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
    
    var categoryFocusAreas: [FocusArea] {
        let result = focusAreas?.allObjects as? [FocusArea] ?? []
        return result
    }
    
    var categorySections: [Section] {
        let result = sections?.allObjects as? [Section] ?? []
        return result
    }
    
    var categoryQuestions: [Question] {
        let result = questions?.allObjects as? [Question] ?? []
        return result
    }
}

