//
//  TutorialFirstFocusArea.swift
//  Fearless2
//
//  Created by Yue Deng-Wu on 2/27/25.
//

import SwiftUI

struct TutorialFirstFocusArea: View {
    @Environment(\.dismiss) var dismiss
    
    let screenHeight = UIScreen.current.bounds.height
    
    var body: some View {
        VStack(spacing: 5) {
            
            Text("Each quest has a number of paths you need to explore")
                .multilineTextAlignment(.center)
                .font(.system(size: 25, design: .serif))
                .foregroundStyle(AppColors.textPrimary)
                .padding(.bottom, 25)
            
            Text("Paths are sets of questions designed to\nhelp you explore certain parts of your life.\nThey are unique to you.")
                .multilineTextAlignment(.center)
                .font(.system(size: 17, weight: .light))
                .foregroundStyle(AppColors.textPrimary)
            
            HStack {
                Text("Earn")
                    .font(.system(size: 17, weight: .light))
                    .foregroundStyle(AppColors.textPrimary)
                
                LaurelItem(size: 17, points: "LAURELS", useSmallCaps: true)
                
                Text("for each completed path.")
                    .font(.system(size: 17, weight: .light))
                    .foregroundStyle(AppColors.textPrimary)
            }

            
            Spacer()
            
            RoundButton(buttonImage: "checkmark", size: 30, frameSize: 80, buttonAction: {
                dismiss()
            })
      
        }
        .padding(.horizontal, 20)
        .padding(.top, 40)
        .padding(.bottom, 60)
        .backgroundSecondary(backgroundColor: AppColors.backgroundCareer, height: screenHeight * 0.65, yOffset: -(screenHeight * 0.35))
    }
}
