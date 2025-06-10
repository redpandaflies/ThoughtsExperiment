//
//  RoundButtonWithEmoji.swift
//  Fearless2
//
//  Created by Yue Deng-Wu on 6/8/25.
//

import SwiftUI

struct RoundButtonWithEmoji: View {
    let symbol: String
    let buttonAction: () -> Void
    
    var body: some View {
        
        VStack {
            Image(systemName: symbol)
                .font(.system(size: 20, weight: .medium))
                .foregroundStyle(AppColors.textPrimary)
        }
        .frame(width: 60, height: 60)
        .contentShape(Circle())
        .background(
            Circle()
                .stroke(Color.white.opacity(0.1), lineWidth: 0.5)
                .fill(AppColors.boxGrey1.opacity(0.3))
                .shadow(color: Color.black.opacity(0.05), radius: 15, x: 0, y: 3)
                .blendMode(.colorDodge)
        )
        .onTapGesture {
            buttonAction()
        }
    }
}

