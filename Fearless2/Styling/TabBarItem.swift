//
//  TabBarItem.swift
//  Fearless2
//
//  Created by Yue Deng-Wu on 11/5/24.
//
import SwiftUI

enum TabBarItemHome: Int, CaseIterable {

    case topics
    case daily
   

    func selectedIconName() -> String {
        switch self {
        case .topics:
            return "rectangle.fill.on.rectangle.angled.fill"
        case .daily:
            return "calendar"

        }
    }
    
    func iconLabel() -> String {
        switch self {
        case .topics:
            return "Your topics"
        case .daily:
            return "Topic of the day"
        }
    }


}
