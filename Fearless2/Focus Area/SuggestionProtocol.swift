//
//  SuggestionProtocol.swift
//  Fearless2
//
//  Created by Yue Deng-Wu on 11/26/24.
//

import Foundation

protocol SuggestionProtocol: Identifiable {
    var title: String { get }
    var suggestionDescription: String { get }
    var symbol: String { get }
}

extension FocusAreaSuggestion: SuggestionProtocol {
    var title: String { self.suggestionContent }
    var suggestionDescription: String { self.suggestionReasoning }
    var symbol: String { self.suggestionEmoji }
}

extension NewSuggestion: SuggestionProtocol {
    var id: UUID { UUID() }
    var title: String { self.content }
    var suggestionDescription: String {self.reasoning}
    var symbol: String { self.emoji }
}
