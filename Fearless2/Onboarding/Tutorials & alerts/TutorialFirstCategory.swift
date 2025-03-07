//
//  TutorialFirstCategory.swift
//  Fearless2
//
//  Created by Yue Deng-Wu on 2/27/25.
//
import CloudStorage
import SwiftUI

struct TutorialFirstCategory: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var dataController: DataController
    let backgroundColor: Color
    
    let screenHeight = UIScreen.current.bounds.height
 
    @AppStorage("showTopics") var showTopics: Bool = false
    @CloudStorage("seenTutorialFirstCategory") var seenTutorialFirstCategory: Bool = false
    
    var body: some View {
        VStack(spacing: 5) {
            
            HStack (spacing: 8){
                
                Image(systemName: "laurel.leading")
                    .font(.system(size: 50, weight: .light))
                    .foregroundStyle(AppColors.textPrimary)
                
                Image(systemName: "laurel.trailing")
                    .font(.system(size: 50, weight: .light))
                    .foregroundStyle(AppColors.textPrimary)
                    
            }
            .padding(.bottom, 35)

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
           
           
            Text("Keep exploring to earn more")
                .font(.system(size: 17, weight: .light))
                .foregroundStyle(AppColors.textPrimary)
                
             
            
            Spacer()
            
            RoundButton(buttonImage: "checkmark", size: 30, frameSize: 80, buttonAction: {
                completeTutorial()
            })
      
        }
   
        .padding(.horizontal, 20)
        .padding(.top, 70)
        .padding(.bottom, 40)
        .frame(maxWidth: .infinity, maxHeight: screenHeight * 0.65)
        .backgroundSecondary(backgroundColor: backgroundColor, height: screenHeight * 0.65, yOffset: -(screenHeight * 0.35))
       
    }
    
    private func completeTutorial() {
        dismiss()
        seenTutorialFirstCategory = true
        Task {
            await dataController.updatePoints(newPoints: 5)
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                withAnimation(.snappy(duration: 0.25)) {
                    showTopics = true
                }
            }
        }
    }
}

#Preview {
    TutorialFirstCategory(backgroundColor: AppColors.backgroundCareer)
}
