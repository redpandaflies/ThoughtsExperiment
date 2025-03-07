//
//  AlertUnlockNewCategory.swift
//  Fearless2
//
//  Created by Yue Deng-Wu on 2/27/25.
//
import CloudStorage
import SwiftUI

struct AlertUnlockNewCategory: View {
    @Environment(\.dismiss) var dismiss
    let backgroundColor: Color
    let screenHeight = UIScreen.current.bounds.height
    
    @CloudStorage("currentAppView") var currentAppView: Int = 0
    
    var body: some View {
        VStack(spacing: 5) {
            
            Image(systemName: "mountain.2.fill")
                .font(.system(size: 50, weight: .light))
                .foregroundStyle(AppColors.textPrimary)
                .padding(.bottom, 35)
            
            Text("A new realm emerges")
                .multilineTextAlignment(.center)
                .font(.system(size: 25, design: .serif))
                .foregroundStyle(AppColors.textPrimary)
                .lineSpacing(1.4)
                .padding(.bottom, 25)
            
            Text("The path ahead is shifting.\nStep forward and see where it leads.")
                .multilineTextAlignment(.center)
                .font(.system(size: 17, weight: .light))
                .foregroundStyle(AppColors.textPrimary)
                .lineSpacing(1.4)
               
            Spacer()
            
            
            RectangleButtonPrimary(
                buttonText: "Unveil your next realm",
                action: {
                    exitView()
                   
                }, buttonColor: .white)
      
        }
        .padding(.horizontal, 30)
        .padding(.top, 70)
        .padding(.bottom, 40)
        .frame(maxWidth: .infinity, maxHeight: screenHeight * 0.65)
        .backgroundSecondary(backgroundColor: backgroundColor, height: screenHeight * 0.65, yOffset: -(screenHeight * 0.35))
    }
    
    private func exitView() {
        dismiss()
        currentAppView = 2
    }
}
