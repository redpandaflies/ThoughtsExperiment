//
//  GoalTypeSymbol.swift
//  Fearless2
//
//  Created by Yue Deng-Wu on 4/28/25.
//

struct GoalTypeSymbol {
    private static let symbols: [String: String] = [
        "Make a decision": "arrow.triangle.branch",
        "Solve a problem": "checkmark.seal",
        "Get clarity on something": "magnifyingglass"
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
