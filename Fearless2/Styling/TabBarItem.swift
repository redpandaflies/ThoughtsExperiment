//
//  TabBarItem.swift
//  Fearless2
//
//  Created by Yue Deng-Wu on 11/5/24.
//
import SwiftUI

enum TabBarItem: Int, CaseIterable {

    case topics
    case understand
   

    func selectedIconName() -> String {
        switch self {
        case .topics:
            return "rectangle.portrait.on.rectangle.portrait.angled.fill"
        case .understand:
            return "lightbulb.max.fill"
       

        }
    }
    
    func iconLabel() -> String {
        switch self {
        case .topics:
            return "Topics"
        case .understand:
            return "Understand"
        
        }
    }


}
