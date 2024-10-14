//
//  QuestionsNewDecision.swift
//  Fearless2
//
//  Created by Yue Deng-Wu on 10/7/24.
//

import Foundation

enum QuestionType: String, Codable {
    case open
    case multiSelect
    case scale
}

struct QuestionsNewDecision: Identifiable, Codable {
    let id: Int
    var question: String
    var questionType: QuestionType
    var minLabel: String?
    var maxLabel: String?
    var options: [String]?
    
    init(id: Int, question: String, questionType: QuestionType, minLabel: String? = nil, maxLabel: String? = nil, options: [String]? = nil) {
        self.id = id
        self.question = question
        self.questionType = questionType
        self.minLabel = minLabel
        self.maxLabel = maxLabel
        self.options = options
    }
}

extension QuestionsNewDecision {
    
    static var questions: [QuestionsNewDecision] {
        [
            .init(id: 0, question: "What do you need to decide on?", questionType: .open),
            .init(id: 1, question: "What’s the importance of this decision in your life?", questionType: .scale, minLabel: "Very low", maxLabel: "Very high"),
            .init(id: 2, question: "What’s your risk tolerance for this decision?", questionType: .scale, minLabel: "Risk adverse", maxLabel: "Risk taker"),
            .init(id: 3, question: "How anxious are you about making this decision?", questionType: .scale, minLabel: "Not at all", maxLabel: "Very"),
            .init(id: 4, question: "Which areas of your life does this decision impact?", questionType: .multiSelect, options: ["Career", "Finances", "Mental Wellness", "Personal Growth", "Health", "Relationships"]),
            .init(id: 5, question: "How close are you to being able to confidently make the decision?", questionType: .scale, minLabel: "Not at all", maxLabel: "Very"),
            .init(id: 6, question: "When do you need to make this decision?", questionType: .multiSelect, options: ["Today", "This week", "Next week", "Next month", "2-3 months", "3-6 months", "6+ months"]),
        ]
    }
}
