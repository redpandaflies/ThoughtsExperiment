//
//  OnboardingIntroContent.swift
//  Fearless2
//
//  Created by Yue Deng-Wu on 10/7/24.
//

import Foundation


struct OnboardingIntroContent: Identifiable, Codable {
   let id: Int
   let title: String

   
   init(id: Int, title: String) {
       self.id = id
       self.title = title
       
   }
}

extension OnboardingIntroContent {
    
    static var pages: [OnboardingIntroContent] {
        [
            .init(id: 0, title: "I’m Kaleida.\n\nI’ll help you with the complex, messy problems that keep you up at night."),
            .init(id: 1, title: "Think of something you’re dealing with that doesn’t have a clear answer. I’ll guide you step by step.")
        ]
    }
}

