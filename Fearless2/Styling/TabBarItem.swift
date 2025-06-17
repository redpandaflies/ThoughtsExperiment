//
//  TabBarItem.swift
//  Fearless2
//
//  Created by Yue Deng-Wu on 11/5/24.
//
import SwiftUI

enum TabBarItemHome: Int, CaseIterable {

    case daily
    case topics

    func selectedIconName() -> String {
        switch self {
        case .daily:
            return "sparkle"
        case .topics:
            return "rectangle.fill.on.rectangle.angled.fill"

        }
    }
    
    func iconLabel() -> String {
        switch self {
        case .daily:
            return "Sparks"
        case .topics:
            return "Your topics"
        }
    }


}
