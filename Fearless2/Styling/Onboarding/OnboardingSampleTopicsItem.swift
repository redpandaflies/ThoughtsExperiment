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
        OnboardingSampleTopicsItem(id: 0, heading: "Make a decision", title: "Should I switch jobs?"),
        OnboardingSampleTopicsItem(id: 1, heading: "Solve a problem", title: "Deal with cofounder conflict"),
        OnboardingSampleTopicsItem(id: 2, heading: "Get clarity", title: "Not sure where I want to live")
    ]

}
