//
//  QuestionsNewDecision.swift
//  Fearless2
//
//  Created by Yue Deng-Wu on 10/7/24.
//

import Foundation



struct QuestionsNewDecision: Identifiable, Codable {
    let id: Int
    var content: String
    var questionType: QuestionType
    var minLabel: String?
    var maxLabel: String?
    var options: [String]?
    
    init(id: Int, content: String, questionType: QuestionType, minLabel: String? = nil, maxLabel: String? = nil, options: [String]? = nil) {
        self.id = id
        self.content = content
        self.questionType = questionType
        self.minLabel = minLabel
        self.maxLabel = maxLabel
        self.options = options
    }
}

extension QuestionsNewDecision {
    
    static var questions: [QuestionsNewDecision] {
        [
            .init(id: 0, content: "What do you need to decide on?", questionType: .open),
            .init(id: 1, content: "What’s the importance of this decision in your life?", questionType: .scale, minLabel: "Very low", maxLabel: "Very high"),
            .init(id: 2, content: "What’s your risk tolerance for this decision?", questionType: .scale, minLabel: "Risk adverse", maxLabel: "Risk taker"),
            .init(id: 3, content: "How anxious are you about making this decision?", questionType: .scale, minLabel: "Not at all", maxLabel: "Very"),
            .init(id: 4, content: "Which areas of your life does this decision impact?", questionType: .multiSelect, options: ["Career", "Finances", "Mental Wellness", "Personal Growth", "Health", "Relationships"]),
            .init(id: 5, content: "How close are you to being able to confidently make the decision?", questionType: .scale, minLabel: "Not at all", maxLabel: "Very"),
            .init(id: 6, content: "When do you need to make this decision?", questionType: .multiSelect, options: ["Today", "This week", "Next week", "Next month", "2-3 months", "3-6 months", "6+ months"]),
        ]
    }
}
