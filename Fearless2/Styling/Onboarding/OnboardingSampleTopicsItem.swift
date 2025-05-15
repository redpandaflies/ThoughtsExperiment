//
//  OnboardingSampleTopicsItem.swift
//  Fearless2
//
//  Created by Yue Deng-Wu on 5/7/25.
//
import Foundation

struct OnboardingSampleTopicsItem: Identifiable {
    let id: Int
    let heading: String
    let title: String
    
    init (id: Int, heading: String, title: String) {
        self.id = id
        self.heading = heading
        self.title = title
    }
}


extension OnboardingSampleTopicsItem {
    
    static let sample: [OnboardingSampleTopicsItem] = [
        OnboardingSampleTopicsItem(id: 0, heading: GoalTypeItem.decision.getNameShort(), title: "Should I switch jobs?"),
        OnboardingSampleTopicsItem(id: 1, heading: GoalTypeItem.problem.getNameShort(), title: "Deal with coworker conflict"),
        OnboardingSampleTopicsItem(id: 2, heading: GoalTypeItem.clarity.getNameShort(), title: "Not sure where I want to live"),
        OnboardingSampleTopicsItem(id: 3, heading: GoalTypeItem.decision.getNameShort(), title: "Break up or try to make it work?"),
        OnboardingSampleTopicsItem(id: 4, heading: GoalTypeItem.problem.getNameShort(), title: "I think I’m burning out"),
        OnboardingSampleTopicsItem(id: 5, heading: GoalTypeItem.clarity.getNameShort(), title: "What do I want from my career?"),
        OnboardingSampleTopicsItem(id: 6, heading: GoalTypeItem.decision.getNameShort(), title: "Grad school or startup?"),
        OnboardingSampleTopicsItem(id: 7, heading: GoalTypeItem.problem.getNameShort(), title: "Feeling dissatisfied with work"),
        OnboardingSampleTopicsItem(id: 8, heading: GoalTypeItem.clarity.getNameShort(), title: "Do I want a kid in my late 30s?")
    ]

}
