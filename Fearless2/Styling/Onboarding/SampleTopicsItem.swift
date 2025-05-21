//
//  SampleGoalsItem.swift
//  Fearless2
//
//  Created by Yue Deng-Wu on 5/7/25.
//
import Foundation

struct SampleGoalsItem: Identifiable {
    let id: Int
    let heading: String      // short name
    let title: String
    let nameLong: String
    let symbol: String       // SF Symbol name

    init(
        id: Int,
        heading: String,
        title: String,
        nameLong: String,
        symbol: String
    ) {
        self.id = id
        self.heading = heading
        self.title = title
        self.nameLong = nameLong
        self.symbol = symbol
    }
}

extension SampleGoalsItem {
    static let sample: [SampleGoalsItem] = [
        .init(
            id: 0,
            heading: GoalTypeItem.decision.getNameShort(),
            title: "Should I switch jobs?",
            nameLong: GoalTypeItem.decision.getNameLong(),
            symbol: GoalTypeItem.decision.getSymbol()
        ),
        .init(
            id: 1,
            heading: GoalTypeItem.problem.getNameShort(),
            title: "Deal with coworker conflict",
            nameLong: GoalTypeItem.problem.getNameLong(),
            symbol: GoalTypeItem.problem.getSymbol()
        ),
        .init(
            id: 2,
            heading: GoalTypeItem.clarity.getNameShort(),
            title: "Not sure where I want to live",
            nameLong: GoalTypeItem.clarity.getNameLong(),
            symbol: GoalTypeItem.clarity.getSymbol()
        ),
        .init(
            id: 3,
            heading: GoalTypeItem.decision.getNameShort(),
            title: "Break up or try to make it work?",
            nameLong: GoalTypeItem.decision.getNameLong(),
            symbol: GoalTypeItem.decision.getSymbol()
        ),
        .init(
            id: 4,
            heading: GoalTypeItem.problem.getNameShort(),
            title: "I think I’m burning out",
            nameLong: GoalTypeItem.problem.getNameLong(),
            symbol: GoalTypeItem.problem.getSymbol()
        ),
        .init(
            id: 5,
            heading: GoalTypeItem.clarity.getNameShort(),
            title: "What do I want from my career?",
            nameLong: GoalTypeItem.clarity.getNameLong(),
            symbol: GoalTypeItem.clarity.getSymbol()
        ),
        .init(
            id: 6,
            heading: GoalTypeItem.decision.getNameShort(),
            title: "Grad school or startup?",
            nameLong: GoalTypeItem.decision.getNameLong(),
            symbol: GoalTypeItem.decision.getSymbol()
        ),
        .init(
            id: 7,
            heading: GoalTypeItem.problem.getNameShort(),
            title: "Feeling dissatisfied with work",
            nameLong: GoalTypeItem.problem.getNameLong(),
            symbol: GoalTypeItem.problem.getSymbol()
        ),
        .init(
            id: 8,
            heading: GoalTypeItem.clarity.getNameShort(),
            title: "Do I want a kid in my late 30s?",
            nameLong: GoalTypeItem.clarity.getNameLong(),
            symbol: GoalTypeItem.clarity.getSymbol()
        )
    ]
}
