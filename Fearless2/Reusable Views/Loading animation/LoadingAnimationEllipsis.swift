//
//  LoadingAnimationEllipsis.swift
//  Fearless2
//
//  Created by Yue Deng-Wu on 4/17/25.
//

import SwiftUI

struct LoadingAnimationEllipsis: View {
    
    @Binding var animationValue: Bool
    
    var body: some View {
        
        HStack {
            Image(systemName: "ellipsis")
                .font(.system(size: 25, weight: .regular))
                .foregroundStyle(AppColors.textPrimary.opacity(0.9))
                .symbolEffect(.wiggle.byLayer, options: animationValue ? .repeating : .nonRepeating, value: animationValue)
            
            Spacer()
        }
        .transition(.asymmetric(insertion: .opacity, removal: .identity))
        .onAppear {
            animationValue = true
        }
        .onDisappear {
            animationValue = false
        }
        
    }
}
