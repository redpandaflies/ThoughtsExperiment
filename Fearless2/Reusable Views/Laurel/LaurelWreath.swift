//
//  Untitled 2.swift
//  Fearless2
//
//  Created by Yue Deng-Wu on 3/7/25.
//

import SwiftUI

struct LaurelWreath: View {
    var size: CGFloat = 50
    var weight: Font.Weight = .light
    var color: Color = AppColors.textPrimary
    var spacing: CGFloat = 8
    var bottomPadding: CGFloat = 35
    
    var body: some View {
        HStack(spacing: spacing) {
            Image(systemName: "laurel.leading")
                .font(.system(size: size, weight: weight))
                .foregroundStyle(color)
            
            Image(systemName: "laurel.trailing")
                .font(.system(size: size, weight: weight))
                .foregroundStyle(color)
        }
        .padding(.bottom, bottomPadding)
    }
}

