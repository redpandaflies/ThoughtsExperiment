//
//  RecapCelebrationView.swift
//  Fearless2
//
//  Created by Yue Deng-Wu on 2/18/25.
//

import SwiftUI


struct RecapCelebrationView: View {
    
    let title: String
    let text: String
    let points: String
    
    var body: some View {

        VStack {
            Spacer()
            
            LaurelItem(size: 50, points: points)
                .padding(.bottom, 20)
            
            Text(text)
                .font(.system(size: 25, weight: .light).smallCaps())
                .fontWidth(.condensed)
                .foregroundStyle(AppColors.textPrimary.opacity(0.5))
            
            Text(title)
                .multilineTextAlignment(.center)
                .font(.system(size: 25, design: .serif))
                .foregroundStyle(AppColors.textPrimary)
            
            Spacer()
        }

    }
        
}
