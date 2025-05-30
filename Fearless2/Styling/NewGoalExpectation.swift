//
//  NewGoalExpectation.swift
//  Fearless2
//
//  Created by Yue Deng-Wu on 10/7/24.
//

import Foundation


struct NewGoalExpectation: Identifiable, Codable, Hashable {
    let id: Int
    let content: String

    static let expectations: [NewGoalExpectation] = [
        NewGoalExpectation(
            id: 0,
            content: "I’ll come up with two possible paths (directions) for your topic.\n\nChoose the one that resonates the most."
        ),
        NewGoalExpectation(
            id: 1,
            content: "Your path will include a few steps. Each looks at the topic from a new angle."
        ),
        NewGoalExpectation(
            id: 2,
            content: "Most people go through one step each day.\n\nCould be the most insightful 10 minutes of your day."
        ),
        NewGoalExpectation(
            id: 3,
            content: "At the end, you decide whether to go deeper on the current topic or mark it resolved."
        ),
        NewGoalExpectation(
            id: 4,
            content: "You can explore more than one topic at a time.\n\nI’ll even suggest new ones as they become relevant."
        )
    ]
}

