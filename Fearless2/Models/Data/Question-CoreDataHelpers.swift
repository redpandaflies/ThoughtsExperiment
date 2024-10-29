//
//  Question-CoreDataHelpers.swift
//  Fearless2
//
//  Created by Yue Deng-Wu on 10/2/24.
//

import Foundation

extension Question {
    
    var questionId: UUID {
        get { id ?? UUID()}
        set { id = newValue}
    }
    
    var questionContent: String {
        get { content ?? "" }
        set { content = newValue }
    }
    
    var questionEmoji: String {
        get { emoji ?? "" }
        set { emoji = newValue }
    }
    
    var questionType: String {
        get { type ?? "" }
        set { type = newValue }
    }
    
    var questionMinLabel: String {
        get { minLabel ?? "" }
        set { minLabel = newValue }
    }
    
    var questionMaxLabel: String {
        get { maxLabel ?? "" }
        set { maxLabel = newValue }
    }
    
    var questionMultiSelectOptions: String {
        get { multiSelectOptions ?? "" }
        set { multiSelectOptions = newValue }
    }
    
    var questionAnswerOpen: String {
        get { answerOpen ?? "" }
        set { answerOpen = newValue }
    }
    
    var questionAnswerMultiSelect: String {
        get { answerMultiSelect ?? "" }
        set { answerMultiSelect = newValue }
    }
    
}
