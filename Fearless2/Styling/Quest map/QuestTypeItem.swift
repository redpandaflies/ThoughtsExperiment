//
//  QuestTypeItem.swift
//  Fearless2
//
//  Created by Yue Deng-Wu on 3/25/25.
//
import Foundation
import SwiftUI

enum QuestTypeItem: String, CaseIterable {
    case expectations
    case guided
    case context
    case breakSignal // pause from questions, provides user something to read and reflect on
    case breakValues
    case breakFirstPrinciples
    case breakMentalModel
    case breakMythReframe
    case retro
    
    // get SF symbol name
    func getIconName() -> String {
        switch self {
            case .expectations:
                return "book.pages.fill"
            case .guided:
                return "questionmark"
            case .context:
                return "questionmark"
            case .retro:
                return "clock.arrow.circlepath"
            case .breakSignal:
                return "antenna.radiowaves.left.and.right"
            case .breakValues:
                return "heart.fill"
            case .breakMentalModel:
                return "cube.transparent"
            case .breakMythReframe:
                return "wand.and.rays"
            case .breakFirstPrinciples:
                return "circle.grid.cross.fill"
        }
    }
    
}
