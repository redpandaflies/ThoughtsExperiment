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
   
   
   func getFullName() -> String {
       switch self {
       case .personal:
           return "Personal"
       case .work:
           return "Work"
       }
   }
   
   func getShortName() -> String {
       switch self {
       case .personal:
           return "Personal"
       case .work:
           return "Work"
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
       case .personal:
           return AppColors.personal
       case .work:
           return AppColors.work
       }
   }
   
   func getDescription() -> String {
       switch self {
       case .personal:
           return "Family, friends, hobbies, wellness and self-care"
       case .work:
           return "Ideas, projects, and challenges at work"
           
       }
   }
   
   func getQuestion() -> String {
       switch self {
       case .personal:
           return "What is on your mind?"
       case .work:
           return "What is on your mind?"
       }
   }
    
}

extension TopicCategoryItem {
    static func fromShortName(_ shortName: String) -> TopicCategoryItem? {
        return self.allCases.first { $0.getShortName() == shortName }
    }
}
