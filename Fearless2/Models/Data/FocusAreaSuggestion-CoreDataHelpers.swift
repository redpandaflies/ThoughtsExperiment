//
//  FocusAreaSuggestion-CoreDataHelpers.swift
//  Fearless2
//
//  Created by Yue Deng-Wu on 11/23/24.
//

import Foundation

extension FocusAreaSuggestion {
    var suggestionId: UUID {
        get { id ?? UUID()}
        set { id = newValue}
    }
    
    var suggestionContent: String {
        get { content ?? "" }
        set { content = newValue }
    }
    
    var suggestionReasoning: String {
        get { reasoning ?? "" }
        set { reasoning = newValue }
    }
    
    var suggestionEmoji: String {
        get { emoji ?? "" }
        set { emoji = newValue }
    }
    
}
