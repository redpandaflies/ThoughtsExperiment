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
    let background: Color
    let category: QuestionCategory
    
    init(orderIndex: Int, emoji: String, name: String, lifeArea: String,
         undiscoveredDescription: String, discoveredDescription: String, background: Color, category: QuestionCategory) {
        self.id = UUID()
        self.orderIndex = orderIndex
        self.emoji = emoji
        self.name = name
        self.lifeArea = lifeArea
        self.undiscoveredDescription = undiscoveredDescription
        self.discoveredDescription = discoveredDescription
        self.background = background
        self.category = category
    }
}

// Sample data
extension Realm {
    static let realmsData: [Realm] = [
        Realm(
            orderIndex: 0,
            emoji: "🏛️",
            name: "Halls of Ambition",
            lifeArea: "Career and professional growth",
            undiscoveredDescription: "A secret hall where whispers of achievement beckon you to unlock your potential.",
            discoveredDescription: "Set clear goals and take bold actions to drive your career forward.",
            background: AppColors.backgroundCareer,
            category: .career
        ),
        Realm(
            orderIndex: 1,
            emoji: "🤝",
            name: "Valley of Connection",
            lifeArea: "Relationships and social life",
            undiscoveredDescription: "A hidden valley where unexpected bonds await to redefine how you connect.",
            discoveredDescription: "Forge deeper bonds with the people you care about.",
            background: AppColors.backgroundRelationships,
            category: .relationships
        ),
        Realm(
            orderIndex: 2,
            emoji: "💰",
            name: "Vault of Prosperity",
            lifeArea: "Money and financial security",
            undiscoveredDescription: "A mysterious vault filled with secrets about money's true role in your life.",
            discoveredDescription: "Explore your relationship with money and make choices you feel good about.",
            background: AppColors.backgroundFinances,
            category: .finance
        ),
        Realm(
            orderIndex: 3,
            emoji: "🌿",
            name: "Garden of Well-Being",
            lifeArea: "Health and wellness",
            undiscoveredDescription: "A secluded garden promising hidden paths to inner balance and rejuvenation.",
            discoveredDescription: "Embrace self-care and mindful habits to cultivate lasting wellness.",
            background: AppColors.backgroundWellness,
            category: .wellness
        ),
        Realm(
            orderIndex: 4,
            emoji: "🎨",
            name: "Temple of Fulfillment",
            lifeArea: "Passion and creativity",
            undiscoveredDescription: "An enigmatic temple hinting at bursts of passion and creative spark waiting to be found.",
            discoveredDescription: "Ignite your passions and break through creative blocks to fuel your inner drive.",
            background: AppColors.backgroundPassion,
            category: .passion
        ),
        Realm(
            orderIndex: 5,
            emoji: "🌀",
            name: "Cavern of Self-Discovery",
            lifeArea: "Identity and purpose",
            undiscoveredDescription: "A shadowed cavern offering clues to your true self and purpose.",
            discoveredDescription: "Engage in honest reflection and take steps to uncover your true identity.",
            background: AppColors.backgroundPurpose,
            category: .purpose
        ),
        Realm(
            orderIndex: 6,
            emoji: "🏰",
            name: "Palace of Possibility",
            lifeArea: "Uncharted Paths",
            undiscoveredDescription: "A cloaked palace where bold, uncharted ideas are poised to ignite your future.",
            discoveredDescription: "Explore innovative ideas and dare to pursue uncharted paths that redefine your future.",
            background: AppColors.backgroundUncharted,
            category: .generic
        )
    ]
}

extension Realm {
    static func getBackgroundColor(forName name: String) -> Color {
        if let realm = realmsData.first(where: { $0.name == name }) {
            return realm.background
        }
        // Default color if no match is found
        return AppColors.backgroundCareer
    }
    
    static func getEmoji(forLifeArea lifeArea: String) -> String {
        if let realm = realmsData.first(where: { $0.lifeArea == lifeArea }) {
            return realm.emoji
        }
        return ""
    }
    
    static func getLifeArea(forCategory category: QuestionCategory) -> String {
        if let realm = realmsData.first(where: { $0.category == category }) {
            return realm.lifeArea
        }
        return ""
    }
    
}
