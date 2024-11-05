//
//  AssistantItem.swift
//  Fearless2
//
//  Created by Yue Deng-Wu on 10/2/24.
//

import Foundation


enum AssistantItem: Int, CaseIterable {
    
    case section
    case sectionSummary
    case sectionSuggestions
    case focusArea
    
    func getAssistantId() -> String? {
        switch self {
        case .section:
            return Constants.openAIAssistantIdSection
        case .sectionSummary:
            return Constants.openAIAssistantIdSectionSummary
        case .sectionSuggestions:
            return Constants.openAIAssistantIdSectionSuggestions
        case .focusArea:
            return Constants.openAIAssistantIdFocusArea
        }
    }
    
}
