//
//  TopicCategoryItem.swift
//  Fearless2
//
//  Created by Yue Deng-Wu on 10/1/24.
//

import Foundation
import SwiftUI

enum TopicCategoryItem: Int, CaseIterable, CategoryItemProtocol{
    case personal
    case work
    case relationships
    case entertainment
    case hobbies
    case finances
    case wellness
    case spirituality
   
   
   func getFullName() -> String {
       switch self {
       case .personal:
           return "Personal Growth"
       case .work:
           return "Work"
       case .relationships:
           return "Relationships"
       case .entertainment:
           return "Entertainment"
       case .hobbies:
           return "Hobbies and Interests"
       case .finances:
           return "Finances"
       case .wellness:
           return "Wellness"
       case .spirituality:
           return "Spirituality"
       }
   }
   
   func getShortName() -> String {
       switch self {
       case .personal:
           return "Personal"
       case .work:
           return "Work"
       case .relationships:
           return "Relationships"
       case .entertainment:
           return "Entertainment"
       case .hobbies:
           return "Hobbies"
       case .finances:
           return "Finances"
       case .wellness:
           return "Wellness"
       case .spirituality:
           return "Spirituality"
       }
   }
   
   func getBubbleTextColor() -> Color {
       switch self {
       case .personal:
           return AppColors.blackDefault
       default:
           return Color.white
       }
   }
   
   func getBubbleColor() -> Color {
       switch self {
       case .work, .finances:
           return AppColors.categoryYellow
       default:
           return AppColors.categoryRed
       }
   }
    
    func getCategoryColor() -> Color {
        switch self {
        case .work, .finances:
            return AppColors.categoryYellow
        default:
            return AppColors.categoryRed
        }
    }
    
    func getCategoryEmoji() -> String {
        switch self {
        case .work:
            return "desktopcomputer"
        case .finances:
            return "creditcard.fill"
        default:
            return "heart.fill"
        }
    }
}

extension TopicCategoryItem {
    static func fromShortName(_ shortName: String) -> TopicCategoryItem? {
        return self.allCases.first { $0.getShortName() == shortName }
    }
}
