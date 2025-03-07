//
//  NewCategoryContent.swift
//  Fearless2
//
//  Created by Yue Deng-Wu on 3/5/25.
//

import Foundation


struct NewCategoryContent: Identifiable, Codable {
    let id: Int
    let imageName: String
    let title: String
    let description: String
    
    init(id: Int, imageName: String = "", title: String = "", description: String) {
        self.id = id
        self.imageName = imageName
        self.title = title
        self.description = description
    }
}

extension NewCategoryContent {
    
    static var pages: [NewCategoryContent] {
        [
            .init(
                id: 0,
                imageName: "onboarding-9-hat",
                title: "KAND'OR SAYS:",
                description: "Before you cross into this\nnew realm, I must ask you a\nfew things."
            ),
            .init(
                id: 1,
                imageName: "onboarding-11-sunset",
                title: "",
                description: "Your answers have cleared\nthe mist. The path to the\nnext realm is emerging."
            )
        ]
    }
}
