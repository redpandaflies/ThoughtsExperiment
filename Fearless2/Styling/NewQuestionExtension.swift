//
//  NewQuestionExtension.swift
//  Fearless2
//
//  Created by Yue Deng-Wu on 4/16/25.
//

import Foundation

extension NewQuestion {
    static let questionsNextSequence: [NewQuestion] = [
        NewQuestion(
            content: "What do you feel you have more clarity on?",
            questionNumber: 0,
            questionType: .multiSelect,
            options: [
                Option(text: "What still energizes you, and what left you drained"),
                Option(text: "What truly drives you now"),
                Option(text: "How your definition of success has changed"),
                Option(text: "Something else")
            ]
        ),
        NewQuestion(
            content: "How do you feel about this topic now?",
            questionNumber: 1,
            questionType: .multiSelect,
            options: [
                Option(text: "I feel more clear"),
                Option(text: "I feel less anxious"),
                Option(text: "I gained a new perspective"),
                Option(text: "I feel more content"),
                Option(text: "I don't feel any better about it")
            ]
        ),
        NewQuestion(
            content: "Does this topic feel resolved?",
            questionNumber: 2,
            questionType: .singleSelect,
            options: [
                Option(text: "Keep exploring"),
                Option(text: "Resolve topic")
            ]
        ),
        NewQuestion(
            content: "We'll come up with a new plan. What would be most helpful for you to explore next?",
            questionNumber: 3,
            questionType: .open,
            options: []
        )
    ]
    
    static let questionsDailyTopic: [NewQuestion] = [
        NewQuestion(
            content: "Was this topic useful?",
            questionNumber: 0,
            questionType: .singleSelect,
            options: [
                Option(text: "Yes, definitely"),
                Option(text: "Somewhat"),
                Option(text: "Not really")
            ]
        ),
        NewQuestion(
            content: "What kind of spark do you want for tomorrow?",
            questionNumber: 1,
            questionType: .singleSelect,
            options: [
                Option(text: "Same theme as today"),
                Option(text: "Something different"),
                Option(text: "I have something specific in mind")
            ]
        ),
        NewQuestion(
            content: "What should we tackle?",
            questionNumber: 2,
            questionType: .singleSelect,
            options: []
        ),
        NewQuestion(
            content: "How in-depth should we go?",
            questionNumber: 3,
            questionType: .singleSelect,
            options: [
                Option(text: "Light (2-3 steps)"),
                Option(text: "Standard (4-5 steps)"),
                Option(text: "Deep (6-7 steps)")
            ]
        ),
        NewQuestion(
            content: "Working on it.\n\nIn the meantime, what kind of spark do you want for tomorrow?",
            questionNumber: 4,
            questionType: .singleSelect,
            options: [
                Option(text: "Same theme as today"),
                Option(text: "Something different"),
                Option(text: "I have something specific in mind")
            ]
        )
    ]
    
}
