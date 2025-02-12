//
//  CategoryItem.swift
//  Fearless2
//
//  Created by Yue Deng-Wu on 10/1/24.
//

import Foundation
import SwiftUI


//Realm is the user-facing name for Category
struct Realm: Identifiable {
    let id: UUID
    let orderIndex: Int
    let emoji: String
    let name: String
    let lifeArea: String
    let undiscoveredDescription: String
    let discoveredDescription: String
    
    init(orderIndex: Int, emoji: String, name: String, lifeArea: String,
         undiscoveredDescription: String, discoveredDescription: String) {
        self.id = UUID()
        self.orderIndex = orderIndex
        self.emoji = emoji
        self.name = name
        self.lifeArea = lifeArea
        self.undiscoveredDescription = undiscoveredDescription
        self.discoveredDescription = discoveredDescription
    }
}

// Sample data
extension Realm {
    static let realmsData: [Realm] = [
        Realm(
            orderIndex: 0,
            emoji: "🏛️",
            name: "Halls of Ambition",
            lifeArea: "Career",
            undiscoveredDescription: "A secret hall where whispers of achievement beckon you to unlock your potential.",
            discoveredDescription: "Set clear goals and take bold actions to drive your career forward."
        ),
        Realm(
            orderIndex: 1,
            emoji: "🤝",
            name: "Valley of Connection",
            lifeArea: "Relationships",
            undiscoveredDescription: "A hidden valley where unexpected bonds await to redefine how you connect.",
            discoveredDescription: "Forge deeper bonds with the people you care about."
        ),
        Realm(
            orderIndex: 2,
            emoji: "💰",
            name: "Vault of Prosperity",
            lifeArea: "Finances",
            undiscoveredDescription: "A mysterious vault filled with secrets about money's true role in your life.",
            discoveredDescription: "Explore your relationship with money and make choices you feel good about."
        ),
        Realm(
            orderIndex: 3,
            emoji: "🌿",
            name: "Garden of Well-Being",
            lifeArea: "Health & Wellness",
            undiscoveredDescription: "A secluded garden promising hidden paths to inner balance and rejuvenation.",
            discoveredDescription: "Embrace self-care and mindful habits to cultivate lasting wellness."
        ),
        Realm(
            orderIndex: 4,
            emoji: "🎨",
            name: "Temple of Fulfillment",
            lifeArea: "Passion & Creativity",
            undiscoveredDescription: "An enigmatic temple hinting at bursts of passion and creative spark waiting to be found.",
            discoveredDescription: "Ignite your passions and break through creative blocks to fuel your inner drive."
        ),
        Realm(
            orderIndex: 5,
            emoji: "🌀",
            name: "Cavern of Self-Discovery",
            lifeArea: "Identity & Purpose",
            undiscoveredDescription: "A shadowed cavern offering clues to your true self and purpose.",
            discoveredDescription: "Engage in honest reflection and take steps to uncover your true identity."
        ),
        Realm(
            orderIndex: 6,
            emoji: "🏰",
            name: "Palace of Possibility",
            lifeArea: "Uncharted Paths",
            undiscoveredDescription: "A cloaked palace where bold, uncharted ideas are poised to ignite your future.",
            discoveredDescription: "Explore innovative ideas and dare to pursue uncharted paths that redefine your future."
        )
    ]
}
