//
//  QuestionScripted.swift
//  Fearless2
//
//  Created by Yue Deng-Wu on 4/16/25.
//

import Foundation

struct QuestionScripted: Identifiable, Codable, QuestionProtocol {
    let id: Int
    var content: String
    var questionType: QuestionType
    var options: [String]?
    
    init(id: Int, content: String, questionType: QuestionType, options: [String]? = nil) {
        self.id = id
        self.content = content
        self.questionType = questionType
        self.options = options
    }
}


extension QuestionScripted {
    static let questions: [QuestionScripted] = [
        QuestionScripted(
            id: 0,
            content: "What do you feel you have more clarity on?",
            questionType: .multiSelect,
            options: [
                "What still energizes you, and what left you drained",
                "What truly drives you now",
                "How your definition of success has changed",
                "Something else"
            ]
        ),
        QuestionScripted(
            id: 1,
            content: "How do you feel about this topic now?",
            questionType: .multiSelect,
            options: [
                "I feel more clear",
                "I feel less anxious",
                "I gained a new perspective",
                "I feel more content",
                "I don’t feel any better about it"
            ]
        ),
        QuestionScripted(
            id: 2,
            content: "Does this topic feel resolved?",
            questionType: .singleSelect,
            options: [
                "Keep exploring",
                "Resolve topic"
            ]
        ),
        QuestionScripted(
            id: 3,
            content: "We’ll come up with a new plan. What would be most helpful for you to explore next?",
            questionType: .open
        )
    ]
}
