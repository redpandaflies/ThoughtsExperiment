//
//  TutorialFirstFocusArea.swift
//  Fearless2
//
//  Created by Yue Deng-Wu on 2/27/25.
//
import CloudStorage
import SwiftUI

struct TutorialFirstFocusArea: View {
    @Environment(\.dismiss) var dismiss
    let backgroundColor: Color
    let screenHeight = UIScreen.current.bounds.height
    
    @CloudStorage("discoveredFirstFocusArea") var firstFocusArea: Bool = false
    
    var body: some View {
        VStack(spacing: 5) {
            
            Text("Each quest has a number of paths you need to explore")
                .multilineTextAlignment(.center)
                .font(.system(size: 25, design: .serif))
                .foregroundStyle(AppColors.textPrimary)
                .lineSpacing(1.4)
                .padding(.bottom, 35)
            
            Text("Paths are sets of questions designed to\nhelp you explore certain parts of your life.\nThey are unique to you.")
                .multilineTextAlignment(.center)
                .font(.system(size: 17, weight: .light))
                .foregroundStyle(AppColors.textPrimary)
                .lineSpacing(1.4)
                .padding(.bottom, 10)
            
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
                firstFocusArea = true
            })
      
        }
        .padding(.horizontal, 30)
        .padding(.top, 70)
        .padding(.bottom, 40)
        .frame(maxWidth: .infinity, maxHeight: screenHeight * 0.65)
        .backgroundSecondary(backgroundColor: backgroundColor, height: screenHeight * 0.65, yOffset: -(screenHeight * 0.35))
    }
}
