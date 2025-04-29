//
//  GoalTypeSymbol.swift
//  Fearless2
//
//  Created by Yue Deng-Wu on 4/28/25.
//

struct GoalTypeSymbol {
    private static let symbols: [String: String] = [
        "Make a decision":       "arrow.triangle.branch",
        "Solve a problem":       "checkmark.seal",
        "Resolve a conflict":    "bubble.left.and.bubble.right",
        "Get clarity":           "magnifyingglass",
        "Reduce anxiety":        "slowmo",
        "Feel more confident":   "figure.dance"
    ]
    
    /// Returns the SF Symbol name for a given problem description,
    /// or `nil` if none matches.
    static func symbolName(for problem: String) -> String? {
        return symbols[problem]
    }
    
    /// Returns the SF Symbol name for a given problem description,
    /// or a default placeholder if none matches.
    static func symbolName(for problem: String, default defaultName: String) -> String {
        return symbols[problem] ?? defaultName
    }
}
