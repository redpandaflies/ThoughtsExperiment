//
//  AssistantItem.swift
//  Fearless2
//
//  Created by Yue Deng-Wu on 10/2/24.
//

import Foundation


enum AssistantItem: Int, CaseIterable {
    
    case topic
    
    func getAssistantId() -> String? {
        switch self {
        case .topic:
            return Constants.openAIAssistantIdTopic
        }
        
    }
    
}
