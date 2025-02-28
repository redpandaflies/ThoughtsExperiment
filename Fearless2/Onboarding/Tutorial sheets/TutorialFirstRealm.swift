//
//  TutorialFirstRealm.swift
//  Fearless2
//
//  Created by Yue Deng-Wu on 2/27/25.
//

import SwiftUI

struct TutorialFirstRealm: View {
    @Environment(\.dismiss) var dismiss
    let backgroundColor: Color
    
    let screenHeight = UIScreen.current.bounds.height
 
    var body: some View {
        VStack(spacing: 5) {

            HStack(spacing: 5) {
                Text("You earned")
                    .font(.system(size: 25, design: .serif))
                    .foregroundStyle(AppColors.textPrimary)
                
                // Laurel icon and number
                LaurelItem(size: 25, points: "5", fontWeight: .regular)
                
                Text("for")
                    .font(.system(size: 25, design: .serif))
                    .foregroundStyle(AppColors.textPrimary)
            }
            
            Text("discovering your first realm")
                .multilineTextAlignment(.center)
                .font(.system(size: 25, design: .serif))
                .foregroundStyle(AppColors.textPrimary)
                .padding(.bottom, 25)
           
            HStack {
                Text("You can use")
                    .font(.system(size: 17, weight: .light))
                    .foregroundStyle(AppColors.textPrimary)
                
                LaurelItem(size: 17, points: "LAURELS", useSmallCaps: true)
                
                Text("to unlock new")
                    .font(.system(size: 17, weight: .light))
                    .foregroundStyle(AppColors.textPrimary)
            }

            
            Text("realms and abilities.\n\nKeep exploring to earn more.")
                .multilineTextAlignment(.center)
                .font(.system(size: 17, weight: .light))
                .foregroundStyle(AppColors.textPrimary)
        
            
            Spacer()
            
            RoundButton(buttonImage: "checkmark", size: 30, frameSize: 80, buttonAction: {
                dismiss()
            })
      
        }
        .padding(.horizontal, 20)
        .padding(.top, 40)
        .padding(.bottom, 60)
        .backgroundSecondary(backgroundColor: backgroundColor, height: screenHeight * 0.65, yOffset: -(screenHeight * 0.35))
    }
}

//#Preview {
//    TutorialFirstRealm()
//}
