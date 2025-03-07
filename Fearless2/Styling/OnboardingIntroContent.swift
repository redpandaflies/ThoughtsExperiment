//
//  OnboardingIntroContent.swift
//  Fearless2
//
//  Created by Yue Deng-Wu on 10/7/24.
//

import Foundation


struct OnboardingIntroContent: Identifiable, Codable {
   let id: Int
   let imageName: String
   let title: String
   let description: String
   
   init(id: Int, imageName: String = "", title: String, description: String = "") {
       self.id = id
       self.imageName = imageName
       self.title = title
       self.description = description
   }
}

extension OnboardingIntroContent {
    
    static var pages: [OnboardingIntroContent] {
        [
            .init(id: 0, imageName: "onboarding-1-mirror", title: "Humans are losing touch\nwith themselves."),
            .init(id: 1, imageName: "onboarding-2-signpost", title: "They’re more and more\ndistracted. Stuck. Lost."),
            .init(id: 2, imageName: "onboarding-3-flame", title: "Their inner wisdom is\nfading away."),
            .init(id: 3, imageName: "onboarding-4-scroll", title: "Ancient truths that once\nguided humankind\nnow lie scattered\nand forgotten."),
            .init(id: 4, imageName: "onboarding-5-star", title: "Fear not — there is still hope.\nBut it’s not gonna be easy."),
            .init(id: 5, imageName: "onboarding-6-mountain", title: "Your mission is to travel\nthrough the forgotten\nrealms."),
            .init(id: 6, imageName: "onboarding-7-gem", title: "Restore lost fragments of\nwisdom."),
            .init(id: 7, imageName: "onboarding-8-lantern", title: "And follow their light to find\nmeaning and purpose."),
            .init(id: 8, imageName: "onboarding-9-hat", title: "My name is Kand’or.\nI’ll be your guide."),
            .init(id: 9, imageName: "onboarding-10-bubble", title: "To start charting your path,\nI need to ask you a few\nquestions."),
            .init(id: 10, imageName: "onboarding-11-sunset", title: "Your answers have cleared\nthe mist. The path to the first\nrealm is emerging.")
            
        ]
    }
}

