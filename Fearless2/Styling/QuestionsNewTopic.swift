//
//  QuestionsNewTopic.swift
//  Fearless2
//
//  Created by Yue Deng-Wu on 10/7/24.
//

import Foundation



struct QuestionsNewTopic: Identifiable, Codable {
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

extension QuestionsNewTopic {
    
    static var questions: [QuestionsNewTopic] {
        [
            .init(id: 0, content: "Which area of life is on your mind?", questionType: .multiSelect, options: TopicCategoryItem.allCases.map {$0.getFullName()}),
            .init(id: 1, content: "What's on your mind", questionType: .open)
        ]
    }
}

