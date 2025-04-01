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
    let icon: String
    let name: String
    let lifeArea: String
    let undiscoveredDescription: String
    let discoveredDescription: String
    let background: Color
    let category: QuestionCategory
    
    init(orderIndex: Int, icon: String, name: String, lifeArea: String,
         undiscoveredDescription: String, discoveredDescription: String, background: Color, category: QuestionCategory) {
        self.id = UUID()
        self.orderIndex = orderIndex
        self.icon = icon
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
            icon: "realm11",
            name: "Peak of Ambition",
            lifeArea: "Career and professional growth",
            undiscoveredDescription: "Where the air is thin, and something inside you keeps reaching higher.",
            discoveredDescription: "Explore what truly drives you and examine the values behind your pursuit.",
            background: AppColors.backgroundCareer,
            category: .career
        ),
        Realm(
            orderIndex: 1,
            icon: "realm22",
            name: "Nest of Belonging",
            lifeArea: "Relationships and social life",
            undiscoveredDescription: "A quiet place that feels warm, even before you step inside.",
            discoveredDescription: "Reflect on the relationships that shape you and what it means to feel connected.",
            background: AppColors.backgroundRelationships,
            category: .relationships
        ),
        Realm(
            orderIndex: 2,
            icon: "realm33",
            name: "Chamber of Fortune",
            lifeArea: "Money and financial security",
            undiscoveredDescription: "Echoes of value linger here — some inherited, some earned.",
            discoveredDescription: "Understand how you think about money and what it means to feel secure.",
            background: AppColors.backgroundFinances,
            category: .finance
        ),
        Realm(
            orderIndex: 3,
            icon: "realm44",
            name: "Garden of Well-Being",
            lifeArea: "Health and wellness",
            undiscoveredDescription: "Still and alive at once, with rhythms you’ve felt but never named.",
            discoveredDescription: "Look at how you care for yourself and what your habits reveal about your needs.",
            background: AppColors.backgroundWellness,
            category: .wellness
        ),
        Realm(
            orderIndex: 4,
            icon: "realm55",
            name: "Attic of Fulfillment",
            lifeArea: "Passion and creativity",
            undiscoveredDescription: "Dust floats in the light, and something meaningful rests quietly in the corner.",
            discoveredDescription: "Revisit what excites you and uncover what brings you creative joy.",
            background: AppColors.backgroundPassion,
            category: .passion
        ),
        Realm(
            orderIndex: 5,
            icon: "realm66",
            name: "Room of Mirrors",
            lifeArea: "Identity and purpose",
            undiscoveredDescription: "You step inside, and everything reflects — some of it familiar, some of it not.",
            discoveredDescription: "Explore how you see yourself and what shapes your sense of identity.",
            background: AppColors.backgroundPurpose,
            category: .purpose
        ),
        Realm(
            orderIndex: 6,
            icon: "realm77",
            name: "Palace of Possibility",
            lifeArea: "Uncharted Paths",
            undiscoveredDescription: "Each corridor feels like a question you haven’t asked yet.",
            discoveredDescription: "Examine the paths that call to you and what holds you back from exploring them.",
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
    
    static func getIcon(forLifeArea lifeArea: String) -> String {
        if let realm = realmsData.first(where: { $0.lifeArea == lifeArea }) {
            return realm.icon
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
