//
//  StaticTopicTitles.swift
//  Fearless2
//
//  Created by Yue Deng-Wu on 4/25/25.
//

import Foundation

extension NewTopic1 {
    static let samples: [NewTopic1] = [
        NewTopic1(
            questNumber: 0,
            title: "What to Expect",
            objective: "Outline what you hope to learn or achieve in this topic",
            emoji: "",
            questType: QuestTypeItem.expectations.rawValue
        ),
        NewTopic1(
            questNumber: 1,
            title: "Break",
            objective: "A break to zoom out and reflect",
            emoji: "",
            questType: QuestTypeItem.break1.rawValue
        ),
        NewTopic1(
            questNumber: 2,
            title: "Retrospective",
            objective: "Reflect on what you’ve experienced so far",
            emoji: "",
            questType: QuestTypeItem.retro.rawValue
        )
    ]
}
