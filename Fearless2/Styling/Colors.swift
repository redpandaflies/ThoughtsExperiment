//
//  Colors.swift
//  Fearless2
//
//  Created by Yue Deng-Wu on 9/30/24.
//

import Foundation
import SwiftUI

struct AppColors {
    // General
    static let blackDefault = Color(.displayP3, red: 0.082, green: 0.106, blue: 0.133, opacity: 1) // #151b22
    static let black1 = Color(.displayP3, red: 0.102, green: 0.102, blue: 0.102, opacity: 1) // #1a1a1a **
    static let black2 = Color(.displayP3, red: 0.063, green: 0.063, blue: 0.063, opacity: 1) // #101010 **
    static let black3 = Color(.displayP3, red: 0.078, green: 0.078, blue: 0.078, opacity: 1) // #141414 **
    static let black4 = Color(.displayP3, red: 0.059, green: 0.059, blue: 0.059, opacity: 1) // #0f0f0f
    static let black5 = Color(.displayP3, red: 0.137, green: 0.137, blue: 0.137, opacity: 1) // #232323
    static let lightGrey1 = Color(.displayP3, red: 0.796, green: 0.796, blue: 0.796, opacity: 1) // #cbcbcb
    static let lightGrey2 = Color(.displayP3, red: 0.569, green: 0.569, blue: 0.569, opacity: 1) // #919191
    static let darkGrey1 = Color(.displayP3, red: 0.267, green: 0.267, blue: 0.267, opacity: 1) // #444444
    static let darkGrey2 = Color(.displayP3, red: 0.161, green: 0.161, blue: 0.161, opacity: 1) // #292929
    static let darkGrey3 = Color(.displayP3, red: 0.129, green: 0.129, blue: 0.129, opacity: 1) // #212121
    static let darkGrey4 = Color(.displayP3, red: 0.176, green: 0.176, blue: 0.176, opacity: 1) // #2d2d2d
    static let darkGrey5 = Color(.displayP3, red: 0.251, green: 0.251, blue: 0.251, opacity: 1) // #404040
    static let yellow1 = Color(.displayP3, red: 1, green: 0.722, blue: 0, opacity: 1) // #ffb800
    static let green1 = Color(.displayP3, red: 0.541, green: 1, blue: 0.624, opacity: 1) // #8aff9f
    static let green2 = Color(.displayP3, red: 0.188, green: 0.435, blue: 0, opacity: 1) // #306f00
    static let green3 = Color(.displayP3, red: 0.094, green: 0.243, blue: 0.075, opacity: 1) // #183e13
    static let ellipsisMenuColor = Color(.displayP3, red: 0.733, green: 0.733, blue: 0.706, opacity: 1) // #bbbbb4
    static let whiteDefault = Color.white.opacity(0.9)
    static let white2 = Color(.displayP3, red: 0.859, green: 0.859, blue: 0.859, opacity: 1) // #dbdbdb
    static let darkBrown = Color(.displayP3, red: 0.11, green: 0.09, blue: 0.059, opacity: 1) // #1c170f
    static let lightBrown = Color(.displayP3, red: 0.608, green: 0.475, blue: 0.235, opacity: 1) // #9b793c
    static let lightBrown2 = Color(.displayP3, red: 0.667, green: 0.482, blue: 0, opacity: 1) // #aa7b00
    
    //entry
    static let entrySubtitle = Color(#colorLiteral(red: 0.929, green: 0.741, blue: 0.408, alpha: 1)) // #edbd68
    
    //understand
    static let understandYellow = Color(#colorLiteral(red: 0.973, green: 0.69, blue: 0.435, alpha: 1)) // #f8b06f
    static let understandWhite = Color(#colorLiteral(red: 0.631, green: 0.584, blue: 0.545, alpha: 1)) // #a1958b
    static let questionBoxBackground = Color(#colorLiteral(red: 0.082, green: 0.082, blue: 0.082, alpha: 1)) // #151515
    
    //MARK: - New
    
    // Text
    static let textPrimary = Color.white.opacity(0.9)
    static let textSecondary = Color(.displayP3, red: 0.914, green: 0.922, blue: 0.949, opacity: 1) // #e9ebf2 light grey
    static let textBlack = Color.black.opacity(0.9)

    // Divider
    static let dividerPrimary = Color(.displayP3, red: 0.125, green: 0.141, blue: 0.204, opacity: 1) // #202434
    static let dividerShadow = textSecondary

    // Box Colors
    static let boxPrimary = Color(.displayP3, red: 0.949, green: 0.949, blue: 0.949, opacity: 1) //#f2f2f2
    static let boxSecondary = Color(.displayP3, red: 0.886, green: 0.886, blue: 0.886, opacity: 1) // #e2e2e2 off white/light grey
    static let boxGrey1 = Color(.displayP3, red: 0.682, green: 0.682, blue: 0.682, opacity: 1) // #aeaeae
    static let boxGrey2 = Color(.displayP3, red: 0.318, green: 0.318, blue: 0.318, opacity: 1) // #515151
    static let boxYellow1 = Color(.displayP3, red: 1, green: 0.831, blue: 0.396, opacity: 1) // #ffd465
    static let boxYellow2 = Color(.displayP3, red: 1, green: 0.722, blue: 0, opacity: 1) // #ffb800
    
    // Buttons
    static let buttonPrimary = textSecondary
    static let buttonYellow1 = boxYellow1
    static let buttonYellow2 = boxYellow2
    static let buttonLightGrey1 = Color(.displayP3, red: 0.89, green: 0.89, blue: 0.89, opacity: 1) // #e3e3e3
   

    // Background
    static let backgroundPrimary = textSecondary
    static let backgroundCareer = Color(.displayP3, red: 0.059, green: 0.141, blue: 0.239, opacity: 1) // #0f243d
    static let backgroundUncharted = Color(.displayP3, red: 0.29, green: 0.063, blue: 0.067, opacity: 1) // #4a1011
    static let backgroundRelationships = Color(.displayP3, red: 0.333, green: 0.149, blue: 0.039, opacity: 1) // #55260a
    static let backgroundFinances = Color(.displayP3, red: 0.365, green: 0.243, blue: 0, opacity: 1) // #5d3e00
    static let backgroundWellness = Color(.displayP3, red: 0.176, green: 0.22, blue: 0.024, opacity: 1) // #2d3806
    static let backgroundPassion = Color(.displayP3, red: 0.055, green: 0.204, blue: 0.188, opacity: 1) // #0e3430
    static let backgroundPurpose = Color(.displayP3, red: 0.114, green: 0.067, blue: 0.2, opacity: 1) // #1d1133
    static let backgroundOnboardingIntro = Color(.displayP3, red: 0.082, green: 0.082, blue: 0.09, opacity: 1)

    // Strokes
    static let strokePrimary = Color.white
    
    //Section progress bar
    static let progressBarPrimary = textPrimary
}
