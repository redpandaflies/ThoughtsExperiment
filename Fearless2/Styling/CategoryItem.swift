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
    let gradient1: Color
    let gradient2: Color
    let category: QuestionCategory
    
    init(orderIndex: Int, icon: String, name: String, lifeArea: String,
         undiscoveredDescription: String, discoveredDescription: String,
         background: Color, gradient1: Color, gradient2: Color, category: QuestionCategory) {
        self.id = UUID()
        self.orderIndex = orderIndex
        self.icon = icon
        self.name = name
        self.lifeArea = lifeArea
        self.undiscoveredDescription = undiscoveredDescription
        self.discoveredDescription = discoveredDescription
        self.background = background
        self.gradient1 = gradient1
        self.gradient2 = gradient2
        self.category = category
    }
}

// Sample data
extension Realm {
    static let realmsData: [Realm] = [
        Realm(
            orderIndex: 0,
            icon: "realm11",
            name: "Work & Career",
            lifeArea: "Career",
            undiscoveredDescription: "Where the air is thin, and something inside you keeps reaching higher.",
            discoveredDescription: "Explore what truly drives you and examine the values behind your pursuit.",
            background: AppColors.backgroundCareer,
            gradient1: AppColors.careerGradient1,
            gradient2: AppColors.careerGradient2,
            category: .career
        ),
        Realm(
            orderIndex: 1,
            icon: "realm22",
            name: "Life & Relationships",
            lifeArea: "Relationships",
            undiscoveredDescription: "A quiet place that feels warm, even before you step inside.",
            discoveredDescription: "Reflect on the relationships that shape you and what it means to feel connected.",
            background: AppColors.backgroundRelationships,
            gradient1: AppColors.relationshipsGradient1,
            gradient2: AppColors.relationshipsGradient2,
            category: .relationships
        ),
        Realm(
            orderIndex: 2,
            icon: "realm44",
            name: "A Mix of Both",
            lifeArea: "All",
            undiscoveredDescription: "Echoes of value linger here — some inherited, some earned.",
            discoveredDescription: "Understand how you think about money and what it means to feel secure.",
            background: AppColors.backgroundWellness,
            gradient1: AppColors.wellnessGradient1,
            gradient2: AppColors.wellnessGradient2,
            category: .mixed
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
    
    static func getGradient1(forName name: String) -> Color {
        if let realm = realmsData.first(where: { $0.name == name }) {
            return realm.gradient1
        }
        // Default color if no match is found
        return AppColors.careerGradient1
    }

    static func getGradient2(forName name: String) -> Color {
        if let realm = realmsData.first(where: { $0.name == name }) {
            return realm.gradient2
        }
        // Default color if no match is found
        return AppColors.careerGradient2
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
    
    static func getRealm(forName name: String) -> Realm? {
        if let realm = realmsData.first(where: { $0.name == name }) {
            return realm
        }
        return nil
    }
    
}
