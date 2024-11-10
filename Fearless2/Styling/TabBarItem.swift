//
//  TabBarItem.swift
//  Fearless2
//
//  Created by Yue Deng-Wu on 11/5/24.
//
import SwiftUI

enum TabBarItem: Int, CaseIterable {

    case topics
    case lifeChart
   

    func selectedIconName() -> String {
        switch self {
        case .topics:
            return "rectangle.portrait.on.rectangle.portrait.angled.fill"
        case .lifeChart:
            return "chart.dots.scatter"
       

        }
    }
    
    func iconLabel() -> String {
        switch self {
        case .topics:
            return "Topics"
        case .lifeChart:
            return "Life Chart"
        
        }
    }
    
    func iconSize() -> Font {
        switch self {
        case .topics:
            .title3
        case .lifeChart:
            .title2
        }
    }


}
