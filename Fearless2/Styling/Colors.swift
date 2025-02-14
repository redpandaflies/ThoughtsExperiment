//
//  Colors.swift
//  Fearless2
//
//  Created by Yue Deng-Wu on 9/30/24.
//

import Foundation
import SwiftUI

struct AppColors {
    //general
    static let blackDefault = Color(#colorLiteral(red: 0.082, green: 0.106, blue: 0.133, alpha: 1)) // #151b22
    static let black1 = Color(#colorLiteral(red: 0.102, green: 0.102, blue: 0.102, alpha: 1)) // #1a1a1a **
    static let black2 = Color(#colorLiteral(red: 0.063, green: 0.063, blue: 0.063, alpha: 1)) // #101010 **
    static let black3 = Color(#colorLiteral(red: 0.078, green: 0.078, blue: 0.078, alpha: 1)) // #141414 **
    static let black4 = Color(#colorLiteral(red: 0.059, green: 0.059, blue: 0.059, alpha: 1)) // #0f0f0f
    static let black5 = Color(#colorLiteral(red: 0.137, green: 0.137, blue: 0.137, alpha: 1)) // #232323
    static let lightGrey1 = Color(#colorLiteral(red: 0.796, green: 0.796, blue: 0.796, alpha: 1)) // #cbcbcb
    static let lightGrey2 = Color(#colorLiteral(red: 0.569, green: 0.569, blue: 0.569, alpha: 1)) // #919191
    static let darkGrey1 =  Color(#colorLiteral(red: 0.267, green: 0.267, blue: 0.267, alpha: 1)) // #444444
    static let darkGrey2 = Color(#colorLiteral(red: 0.161, green: 0.161, blue: 0.161, alpha: 1)) // #292929
    static let darkGrey3 = Color(#colorLiteral(red: 0.129, green: 0.129, blue: 0.129, alpha: 1)) // #212121
    static let darkGrey4 = Color(#colorLiteral(red: 0.176, green: 0.176, blue: 0.176, alpha: 1)) // #2d2d2d
    static let darkGrey5 = Color(#colorLiteral(red: 0.251, green: 0.251, blue: 0.251, alpha: 1)) // #404040
    static let yellow1 = Color(#colorLiteral(red: 1, green: 0.722, blue: 0, alpha: 1)) // #ffb800
    static let green1 = Color(#colorLiteral(red: 0.541, green: 1, blue: 0.624, alpha: 1)) // #8aff9f
    static let green2 = Color(#colorLiteral(red: 0.188, green: 0.435, blue: 0, alpha: 1)) // #306f00
    static let green3 = Color(#colorLiteral(red: 0.094, green: 0.243, blue: 0.075, alpha: 1)) // #183e13
    static let ellipsisMenuColor = Color(#colorLiteral(red: 0.733, green: 0.733, blue: 0.706, alpha: 1)) // #bbbbb4
    static let whiteDefault = Color.white.opacity(0.9)
    static let white2 = Color(#colorLiteral(red: 0.859, green: 0.859, blue: 0.859, alpha: 1)) // #dbdbdb
    static let darkBrown = Color(#colorLiteral(red: 0.11, green: 0.09, blue: 0.059, alpha: 1)) // #1c170f
    static let lightBrown = Color(#colorLiteral(red: 0.608, green: 0.475, blue: 0.235, alpha: 1)) // #9b793c
    static let lightBrown2 = Color(#colorLiteral(red: 0.667, green: 0.482, blue: 0, alpha: 1)) // #aa7b00
    
    //home
    static let homeBackground = Color(#colorLiteral(red: 0.933, green: 0.929, blue: 0.91, alpha: 1)) // #eeede8
    
    //categories
    static let categoryYellow = Color(#colorLiteral(red: 1, green: 0.722, blue: 0, alpha: 1)) // #ffb800
    static let categoryDividerYellow = Color(#colorLiteral(red: 0.129, green: 0.086, blue: 0.012, alpha: 1)) // #211603
    static let categoryRed = Color(#colorLiteral(red: 1, green: 0.49, blue: 0.376, alpha: 1)) // #ff7d60
    
    //sections
    static let sectionPillBackground = Color(#colorLiteral(red: 0.871, green: 0.863, blue: 0.831, alpha: 1)) // #dedcd4
    static let sectionBoxBackground = Color(#colorLiteral(red: 0.102, green: 0.102, blue: 0.102, alpha: 1)) // #1a1a1a
    
    //sectionSummary
    static let sectionSummaryLight = Color(#colorLiteral(red: 0.827, green: 0.851, blue: 0.922, alpha: 1)) // #d3d9eb
    static let sectionSummaryDark = Color(#colorLiteral(red: 0.227, green: 0.325, blue: 0.682, alpha: 1)) // #3a53ae
    static let sectionSummaryOffWhite = Color(#colorLiteral(red: 0.976, green: 0.988, blue: 1, alpha: 1)) // #f9fcff
    
    //questions
    static let pillStrokeColor = Color(#colorLiteral(red: 0.902, green: 0.902, blue: 0.902, alpha: 1)) // #e6e6e6
    static let questionBoxBackground = Color(#colorLiteral(red: 0.082, green: 0.082, blue: 0.082, alpha: 1)) // #151515
    
    //topic detail view
    static let topicTitle = Color(#colorLiteral(red: 0.847, green: 0.827, blue: 0.788, alpha: 1)) // #d8d3c9
    static let topicSubtitle = Color(#colorLiteral(red: 0.906, green: 0.906, blue: 0.906, alpha: 1)) // #e7e7e7
    static let topicFooterBackground = Color(#colorLiteral(red: 0.055, green: 0.055, blue: 0.055, alpha: 1)) // #0e0e0e **

    //insights
    static let insightBoxBackground = Color(#colorLiteral(red: 0.608, green: 0.475, blue: 0.235, alpha: 1)) // #9b793c
    static let insightBoxStroke = Color(#colorLiteral(red: 0.608, green: 0.475, blue: 0.235, alpha: 1)) // #9b793c
    
    //entry
    static let entrySubtitle = Color(#colorLiteral(red: 0.929, green: 0.741, blue: 0.408, alpha: 1)) // #edbd68
    
    //understand
    static let understandYellow = Color(#colorLiteral(red: 0.973, green: 0.69, blue: 0.435, alpha: 1)) // #f8b06f
    static let understandWhite = Color(#colorLiteral(red: 0.631, green: 0.584, blue: 0.545, alpha: 1)) // #a1958b
    
    //MARK: - New
    
    //text
    static let textPrimary = Color.white.opacity(0.9)
    static let textSecondary = Color(#colorLiteral(red: 0.914, green: 0.922, blue: 0.949, alpha: 1)) // #e9ebf2
    
    //divider
    static let dividerPrimary = Color(#colorLiteral(red: 0.125, green: 0.141, blue: 0.204, alpha: 1)) // #202434
    static let dividerShadow = Color(#colorLiteral(red: 0.914, green: 0.922, blue: 0.949, alpha: 1)) // #e9ebf2
    
    //button color
    static let buttonPrimary = Color(#colorLiteral(red: 0.914, green: 0.922, blue: 0.949, alpha: 1)) // #e9ebf2
    
    //box color
    static let boxPrimary = Color(#colorLiteral(red: 0.914, green: 0.922, blue: 0.949, alpha: 1)) // #e9ebf2
    
    //background
    static let backgroundPrimary = Color(#colorLiteral(red: 0.914, green: 0.922, blue: 0.949, alpha: 1)) // #e9ebf2
    static let backgroundCareer = Color(#colorLiteral(red: 0.059, green: 0.141, blue: 0.239, alpha: 1)) // #0f243d
}
