//
//  SectionCategoryItem.swift
//  Fearless2
//
//  Created by Yue Deng-Wu on 10/14/24.
//

import Foundation
import SwiftUI

enum SectionCategoryItem: Int, CaseIterable, CategoryItemProtocol {
    case context
    
    func getFullName() -> String {
        switch self {
        case .context:
            return "Gather context"
        }
    }
    
    func getShortName() -> String {
        switch self {
        case .context:
            return "Context"
        }
    }
    
    func getBubbleTextColor() -> Color {
        switch self {
        case .context:
            return AppColors.blackDefault
        }
    }
    
    func getBubbleColor() -> Color {
        switch self {
        case .context:
            return AppColors.sectionPillBackground
        }
    }
    
}
