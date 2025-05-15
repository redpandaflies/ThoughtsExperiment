//
//  QuestMapItem.swift
//  Fearless2
//
//  Created by Yue Deng-Wu on 3/25/25.
//

import Foundation
import SwiftUI


struct QuestMapItem: Identifiable {
    let id: UUID
    let orderIndex: Int
    let questType: QuestTypeItem
    
    init(orderIndex: Int, questType: QuestTypeItem) {
        self.id = UUID()
        self.orderIndex = orderIndex
        self.questType = questType
    }
}


extension QuestMapItem {
    
    static let questMap1: [QuestMapItem] = [
        QuestMapItem(orderIndex: 0, questType: .guided),
        QuestMapItem(orderIndex: 1, questType: .guided),
        QuestMapItem(orderIndex: 2, questType: .context),
        QuestMapItem(orderIndex: 3, questType: .guided),
        QuestMapItem(orderIndex: 4, questType: .guided),
        QuestMapItem(orderIndex: 5, questType: .guided),
        QuestMapItem(orderIndex: 6, questType: .guided)
    ]

}
