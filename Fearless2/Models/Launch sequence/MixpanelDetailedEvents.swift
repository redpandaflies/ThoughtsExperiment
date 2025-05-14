//
//  MixpanelDetailedEvents.swift
//  Fearless2
//
//  Created by Yue Deng-Wu on 5/13/25.
//

import Foundation

struct MixpanelDetailedEvents {
    
    static let problemRecency: [String: String] = [
        "It's a recent thing": "recent thing",
        "For a few weeks": "weeks",
        "For several months": "months",
        "For a year or more": "year"
    ]
    
    static let userAsk: [String: String] = [
        "Offer a different perspective" : "different perspective",
        "Give candid feedback" : "candid feedback",
        "Suggest next steps" : "next steps"
    ]
    
    static let sequenceRetro: [String: String] = [
        "I feel more clear" : "more clear",
        "I feel less anxious" : "less anxious",
        "I gained a new perspective": "new perspective",
        "I feel more content": "more content",
        "I don’t feel any better about it": "no change"
    ]
}
