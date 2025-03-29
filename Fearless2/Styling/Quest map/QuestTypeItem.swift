//
//  QuestTypeItem.swift
//  Fearless2
//
//  Created by Yue Deng-Wu on 3/25/25.
//
import Foundation
import SwiftUI

enum QuestTypeItem: String, CaseIterable {
    case guided
    case newCategory
    case context
    case retro
    
    // get SF symbol name
    func getIconName() -> String {
        switch self {
            case .guided:
                return "questionmark"
            case .newCategory:
                return "mountain.2.fill"
            case .context:
                return "book.pages.fill"
            case .retro:
                return "clock.arrow.circlepath"
        }
    }
    
}
