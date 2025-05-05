//
//  QuestTypeItem.swift
//  Fearless2
//
//  Created by Yue Deng-Wu on 3/25/25.
//
import Foundation
import SwiftUI

enum QuestTypeItem: String, CaseIterable {
    case expectations
    case guided
    case newCategory
    case context
    case break1 // pause from questions, provides user something to read and reflect on
    case retro
    
    // get SF symbol name
    func getIconName() -> String {
        switch self {
            case .expectations:
                return "book.pages.fill"
            case .guided:
                return "questionmark"
            case .newCategory:
                return "mountain.2.fill"
            case .context:
                return "questionmark"
            case .retro:
                return "clock.arrow.circlepath"
            case .break1:
                return "cube.transparent"
        }
    }
    
}
