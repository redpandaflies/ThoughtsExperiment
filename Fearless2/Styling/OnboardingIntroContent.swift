//
//  OnboardingIntroContent.swift
//  Fearless2
//
//  Created by Yue Deng-Wu on 10/7/24.
//

import Foundation


struct OnboardingIntroContent: Identifiable, Codable {
   let id: Int
   let emoji: String
   let title: String
   let description: String
   
   init(id: Int, emoji: String = "", title: String, description: String = "") {
       self.id = id
       self.emoji = emoji
       self.title = title
       self.description = description
   }
}

extension OnboardingIntroContent {
    
    static var pages: [OnboardingIntroContent] {
        [
            .init(id: 0, emoji: "🔭", title: "This is a game of exploration"),
            .init(id: 1, emoji: "🌝", title: "You'll explore the topics that keep you up at night"),
            .init(id: 2, title: "You'll travel through 7 different realms"),
            .init(id: 3, emoji: "🔍", title: "Each of them will reveal new insights and clues about the things that matter to you"),
            .init(id: 4, emoji: "🦊", title: "You'll encounter friendly characters that share their wisdom with you"),
            .init(id: 5, emoji: "👻", title: "And defeat the foes that stand in your way"),
            .init(id: 6, emoji: "⭐️", title: "Ready to begin?", description: "We'll start with a few questions about what matters to you.\n\nYour answers will shape the entire experience."),
            .init(id: 7, emoji: "👀", title: "One last question"),
            .init(id: 8, title: "Ready to discover your first realm?")
        ]
    }
}

