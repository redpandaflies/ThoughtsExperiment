//
//  GoalTypeSymbol.swift
//  Fearless2
//
//  Created by Yue Deng-Wu on 4/28/25.
//

struct GoalTypeInfo {
    let symbolName: String
    let imageName: String
}

enum GoalTypeItem: String, CaseIterable {
    case decision
    case problem
    case clarity
    case deepDive
    
    func getNameLong() -> String {
        switch self {
        case .decision:
            return "Make a decision"
        case .problem:
            return "Solve a problem"
        case .clarity:
            return "Get clarity on something"
        case .deepDive:
            return "Do a deep dive"
        }
    }
    
    func getNameShort() -> String {
        switch self {
        case .decision:
            return "Make a decision"
        case .problem:
            return "Solve a problem"
        case .clarity:
            return "Get clarity"
        case .deepDive:
            return "Deep dive"
        }
    }
    
    func getQuestion() -> String {
        switch self {
        case .decision:
            return "What decision do you need to make?"
        case .problem:
            return "What problem are you trying to solve?"
        case .clarity:
            return "What do you need clarity on?"
        case .deepDive:
            return "What do you want to dive into?"
        }
    }
    
    func getSymbol() -> String {
        switch self {
        case .decision:
            return "arrow.triangle.branch"
        case .problem:
            return "checkmark.seal"
        case .clarity:
            return "magnifyingglass"
        case .deepDive:
            return "square.2.layers.3d.bottom.filled"
        }
    }
        
    func getImage() -> String {
        switch self {
        case .decision:
            return "goalDecision"
        case .problem:
            return "goalProblem"
        case .clarity:
            return "goalClarity"
        case .deepDive:
            return "goalDecision"
        }
    }
    
    static func fromLongName(_ longName: String) -> GoalTypeItem {
        return self.allCases.first { $0.getNameLong() == longName } ?? .decision
    }
    
    static func question(forLongName longName: String) -> String {
            return fromLongName(longName).getQuestion()
        }
    
    static func imageName(forLongName longName: String) -> String {
        return fromLongName(longName).getImage()
    }
    
    static func symbolName(forLongName longName: String) -> String {
        return fromLongName(longName).getSymbol()
    }
   
}

struct GoalTypeSymbol {
        private static let info: [String: GoalTypeInfo] = [
            "Make a decision": GoalTypeInfo(symbolName: "arrow.triangle.branch", imageName: "goalDecision"),
            "Solve a problem": GoalTypeInfo(symbolName: "checkmark.seal", imageName: "goalProblem"),
            "Get clarity on something": GoalTypeInfo(symbolName: "magnifyingglass", imageName: "goalClarity")
        ]
    
    /// Returns the symbol name for a given problem description, or a default if none matches.
        static func symbolName(for problem: String, default defaultName: String) -> String {
            return info[problem]?.symbolName ?? defaultName
        }
        
    /// Returns the image name for a given problem description, or a default if none matches.
        static func imageName(for problem: String, default defaultName: String) -> String {
            return info[problem]?.imageName ?? defaultName
        }
}
