//
//  TopicCategoryItem.swift
//  Fearless2
//
//  Created by Yue Deng-Wu on 10/1/24.
//

import Foundation
import SwiftUI

enum TopicCategoryItem: Int, CaseIterable, CategoryItemProtocol{
     case decision
     case problem
     case event
     case emotions
    
    
    func getFullName() -> String {
        switch self {
        case .decision:
            return "Make decision"
        case .problem:
            return "Solve problem or conflict"
        case .event:
            return "Reflect on an event"
        case .emotions:
            return "Process emotions"
        }
    }
    
    func getShortName() -> String {
        switch self {
        case .decision:
            return "Decision"
        case .problem:
            return "Problem"
        case .event:
            return "Event"
        case .emotions:
            return "Emotion"
        }
    }
    
    func getBubbleTextColor() -> Color {
        switch self {
        case .decision:
            return AppColors.blackDefault
        default:
            return Color.white
        }
    }
    
    func getBubbleColor() -> Color {
        switch self {
        case .decision:
            return AppColors.decision
        case .problem:
            return AppColors.problem
        case .event:
            return AppColors.event
        case .emotions:
            return AppColors.emotions
        }
    }
    
    func getDescription() -> String {
        switch self {
        case .decision:
            return "Get guidance on making a clear, confident decision"
        case .problem:
            return "Break down and resolve a challenge or conflict"
        case .event:
            return "Understand and learn from a recent experience"
        case .emotions:
            return "Work through and make sense of your emotions"
            
        }
    }
    
    func getQuestion() -> String {
        switch self {
        case .decision:
            return "What do you need to make a decision on?"
        case .problem:
            return "What challenge or conflict are you trying to resolve?"
        case .event:
            return "What's the event you're thinking about?"
        case .emotions:
            return "What emotions are you working through right now?"
        }
    }
    
}

extension TopicCategoryItem {
    static func fromShortName(_ shortName: String) -> TopicCategoryItem? {
        return self.allCases.first { $0.getShortName() == shortName }
    }
}
