//
//  RecapCelebrationView.swift
//  Fearless2
//
//  Created by Yue Deng-Wu on 2/18/25.
//

import SwiftUI


struct RecapCelebrationView: View {
    
    let title: String?
    
    var body: some View {

        VStack {
            Spacer()
            
            LaurelItem(size: 50, points: "+1")
                .padding(.bottom, 20)
                .padding(.top, 30)
            
            Text("For exploring")
                .font(.system(size: 25, weight: .light).smallCaps())
                .fontWidth(.condensed)
                .foregroundStyle(AppColors.textPrimary.opacity(0.5))
            
            Text(title ?? "")
                .multilineTextAlignment(.center)
                .font(.system(size: 25, design: .serif))
                .foregroundStyle(AppColors.textPrimary)
            
            Spacer()
        }

    }
        
}
