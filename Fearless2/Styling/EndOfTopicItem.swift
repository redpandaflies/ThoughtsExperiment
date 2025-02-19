//
//  EndOfTopicItem.swift
//  Fearless2
//
//  Created by Yue Deng-Wu on 2/18/25.
//

import Foundation

struct EndOfTopic: Identifiable {
    let id: UUID
    let title: String
    let reasoning: String
    let sections: [EndOfTopicSection]
    
    init(title: String, reasoning: String, sections: [EndOfTopicSection]) {
        self.id = UUID()
        self.title = title
        self.reasoning = reasoning
        self.sections = sections
    }
}


struct EndOfTopicSection: Identifiable {
    let id: UUID
    let sectionNumber: Int
    let title: String
    
    init(sectionNumber: Int, title: String) {
        self.id = UUID()
        self.sectionNumber = sectionNumber
        self.title = title
    }
}


// Sample data
extension EndOfTopic {
    static let sampleEndOfTopic: EndOfTopic =
        EndOfTopic(
            title: "Quest Complete",
            reasoning: "You've found a lost fragment.\nSee what it says.",
            sections: EndOfTopicSection.sampleSections
        )
}

extension EndOfTopicSection {
    static let sampleSections: [EndOfTopicSection] = [
        EndOfTopicSection(sectionNumber: 1, title: "Restore lost fragment"),
        EndOfTopicSection(sectionNumber: 2, title: "Choose your next quest")
    ]
}
