//
//  AssistantItem.swift
//  Fearless2
//
//  Created by Yue Deng-Wu on 10/2/24.
//

import Foundation


enum AssistantItem: Int, CaseIterable {
    
    case topic
    case sectionSummary
    case focusArea
    case focusAreaSuggestions
    case focusAreaSummary
    case entry
    case understand
    
    func getAssistantId() -> String? {
        switch self {
        case .topic:
            return Constants.openAIAssistantIdTopic
        case .sectionSummary:
            return Constants.openAIAssistantIdSectionSummary
        case .focusArea:
            return Constants.openAIAssistantIdFocusArea
        case .focusAreaSuggestions:
            return Constants.openAIAssistantIdFocusAreaSuggestions
        case .focusAreaSummary:
            return Constants.openAIAssistantIdFocusAreaSummary
        case .entry:
            return Constants.openAIAssistantIdEntry
        case .understand:
            return Constants.openAIAssistantIdUnderstand
        }
    }
    
}
