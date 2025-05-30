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
    static let boxGrey3 = Color(.displayP3, red: 0.729, green: 0.729, blue: 0.729, opacity: 1) // #bababa
    static let boxGrey4 = Color(.displayP3, red: 0.518, green: 0.518, blue: 0.518, opacity: 1) // #848484
    static let boxGrey5 = Color(.displayP3, red: 0.620, green: 0.620, blue: 0.620, opacity: 1) // #9E9E9E
    static let boxGrey6 = Color(.displayP3, red: 0.498, green: 0.498, blue: 0.498, opacity: 1) // #7F7F7F
    static let boxYellow1 = Color(.displayP3, red: 1, green: 0.831, blue: 0.396, opacity: 1) // #ffd465
    static let boxYellow2 = Color(.displayP3, red: 1, green: 0.722, blue: 0, opacity: 1) // #ffb800
    
    // Category gradients
    static let careerGradient1 = Color(.displayP3, red: 0, green: 0.294, blue: 0.647, opacity: 1) // #004ba5
    static let careerGradient2 = Color(.displayP3, red: 0, green: 0.118, blue: 0.259, opacity: 1) // #001e42

    static let financesGradient1 = Color(.displayP3, red: 1, green: 0.667, blue: 0, opacity: 1) // #ffaa00
    static let financesGradient2 = Color(.displayP3, red: 0.365, green: 0.243, blue: 0, opacity: 1) // #5d3e00

    static let relationshipsGradient1 = Color(.displayP3, red: 1, green: 0.373, blue: 0, opacity: 1) // #ff5f00
    static let relationshipsGradient2 = Color(.displayP3, red: 0.467, green: 0.224, blue: 0.078, opacity: 1) // #773914

    static let passionsGradient1 = Color(.displayP3, red: 0.349, green: 0.176, blue: 0.667, opacity: 1) // #592daa
    static let passionsGradient2 = Color(.displayP3, red: 0.114, green: 0.067, blue: 0.2, opacity: 1) // #1d1133

    static let wellnessGradient1 = Color(.displayP3, red: 0.78, green: 1, blue: 0, opacity: 1) // #c7ff00
    static let wellnessGradient2 = Color(.displayP3, red: 0.267, green: 0.341, blue: 0, opacity: 1) // #445700
    
    // Buttons
    static let buttonPrimary = textSecondary
    static let buttonYellow1 = boxYellow1
    static let buttonYellow2 = boxYellow2
    static let buttonLightGrey1 = Color(.displayP3, red: 0.89, green: 0.89, blue: 0.89, opacity: 1) // #e3e3e3
    static let buttonLightGrey2 = Color(.displayP3, red: 0.059, green: 0.141, blue: 0.239, opacity: 0.2) // #0F243D
    static let buttonBlack1 = Color(.displayP3, red: 0.216, green: 0.216, blue: 0.216, opacity: 1) // #373737
    static let buttonBlack2 = Color(.displayP3, red: 0.075, green: 0.075, blue: 0.075, opacity: 1) // #131313
   

    // MARK: Backgrounds
    static let backgroundPrimary = textSecondary
    static let backgroundOnboardingIntro = Color(.displayP3, red: 0.059, green: 0.075, blue: 0.169, opacity: 1) // #0F132B
    
    static let background1 = Color(.displayP3, red: 0.149, green: 0.212, blue: 0.090, opacity: 1) // #263617
    static let background2 = Color(.displayP3, red: 0.106, green: 0.196, blue: 0.106, opacity: 1) // #1B321B
    static let background3 = Color(.displayP3, red: 0.098, green: 0.204, blue: 0.149, opacity: 1) // #193426
    static let background4 = Color(.displayP3, red: 0.090, green: 0.212, blue: 0.212, opacity: 1) // #173636
    static let background5 = Color(.displayP3, red: 0.075, green: 0.149, blue: 0.224, opacity: 1) // #132639
    static let background6 = Color(.displayP3, red: 0.141, green: 0.141, blue: 0.259, opacity: 1) // #242442
    static let background7 = Color(.displayP3, red: 0.149, green: 0.098, blue: 0.204, opacity: 1) // #261934
    static let background8 = Color(.displayP3, red: 0.196, green: 0.106, blue: 0.196, opacity: 1) // #321B32
    static let background9 = Color(.displayP3, red: 0.212, green: 0.090, blue: 0.149, opacity: 1) // #361726
    static let background10 = Color(.displayP3, red: 0.216, green: 0.082, blue: 0.082, opacity: 1) // #371515
    static let background11 = Color(.displayP3, red: 0.239, green: 0.149, blue: 0.059, opacity: 1) // #3D260F
    static let background12 = Color(.displayP3, red: 0.212, green: 0.212, blue: 0.090, opacity: 1) // #363617
    
    
    // realms version (old)
    static let backgroundUncharted = Color(.displayP3, red: 0.427, green: 0.090, blue: 0.094, opacity: 1) // #6D1718
    static let backgroundRelationships = Color(.displayP3, red: 0.478, green: 0.204, blue: 0.043, opacity: 1) // #7A340B
    static let backgroundFinances = Color(.displayP3, red: 0.506, green: 0.337, blue: 0, opacity: 1) // #815600
    static let backgroundWellness = Color(.displayP3, red: 0.247, green: 0.306, blue: 0.039, opacity: 1) // #3F4E0A
    static let backgroundPassion = Color(.displayP3, red: 0.059, green: 0.310, blue: 0.286, opacity: 1) // #0F4F49
    static let backgroundCareer = Color(.displayP3, red: 0.090, green: 0.216, blue: 0.365, opacity: 1) // #17375D
    static let backgroundPurpose = Color(.displayP3, red: 0.173, green: 0.098, blue: 0.318, opacity: 1) // #2C1951
    
    
    // Strokes
    static let strokePrimary = Color.white
    
    //Section progress bar
    static let progressBarPrimary = textPrimary
    
    //picker
    static let pickerColorPrimary = Color(.displayP3, red: 0.373, green: 0.373, blue: 0.373, opacity: 1) // #5F5F5F
    static let pickerColorPrimaryUI = UIColor(
            displayP3Red: 0.373,
            green: 0.373,
            blue: 0.373,
            alpha: 1.0
        )
    static let pickerColorSelected = Color(.displayP3, red: 0.498, green: 0.498, blue: 0.498, opacity: 0.6) // #7F7F7F
    static let pickerColorSelectedUI = UIColor(
            displayP3Red: 0.498,
            green: 0.498,
            blue: 0.498,
            alpha: 0.6
        )
}

extension AppColors {
    
    static let allBackgrounds: [Color] = [
        background6,  // #242442
        background3,  // #193426
        background5,  // #132639
        background4,  // #173636
        background11, // #3D260F
        background2,  // #1B321B
        background7,  // #261934
        background10, // #371515
        background8,  // #321B32
        background1,  // #263617
        background9,  // #361726
        background12  // #363617
    ]
}
