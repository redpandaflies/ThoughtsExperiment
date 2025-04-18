//
//  AssistantItem.swift
//  Fearless2
//
//  Created by Yue Deng-Wu on 10/2/24.
//

import Foundation


enum AssistantItem: Int, CaseIterable {
    
    case newCategory
    case planSuggestion
    case topic
    case topicOverview
    case topicSuggestions
    case topicSuggestions2
    case sectionSummary
    case focusArea
    case focusAreaSuggestions
    case focusAreaSummary
    case entry
    case understand
    
    func getAssistantId() -> String? {
        switch self {
        case .newCategory:
            return Constants.openAIAssistantIdNewCategory
        case .planSuggestion:
            return Constants.openAIAssistantIdPlanSuggestion
        case .topic:
            return Constants.openAIAssistantIdTopic
        case .topicOverview:
            return Constants.openAIAssistantIdTopicOverview
        case .topicSuggestions:
            return Constants.openAIAssistantIdTopicSuggestions
        case .topicSuggestions2:
            return Constants.openAIAssistantIdTopicSuggestions2
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
