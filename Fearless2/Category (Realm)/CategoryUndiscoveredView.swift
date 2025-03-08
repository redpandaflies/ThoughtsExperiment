//
//  CategoryUndiscoveredView.swift
//  Fearless2
//
//  Created by Yue Deng-Wu on 2/7/25.
//
import CloudStorage
import Mixpanel
import SwiftUI

struct CategoryUndiscoveredView: View {

    @CloudStorage("currentAppView") var currentAppView: Int = 0
    
    var body: some View {
        VStack {
            
            VStack (spacing: 13) {
                Text("Undiscovered")
                    .multilineTextAlignment(.center)
                    .font(.system(size: 25, design: .serif))
                    .foregroundStyle(AppColors.textPrimary)
                
                Text("A new realm is waiting for you")
                    .multilineTextAlignment(.center)
                    .font(.system(size: 16, weight: .light))
                    .foregroundStyle(AppColors.textPrimary.opacity(0.8))
                    .lineSpacing(1.5)
            }
            .padding(.vertical, 25)
            .padding(.horizontal, 30)
          
            shortLine()
                .padding(.horizontal)
                .padding(.bottom, 75)
                .padding(.top, 75)
            
            DiscoverNewCategoryButton()
                .onTapGesture {
                    startNewRealmFlow()
                }
            
        }
      

    }
    
    private func shortLine() -> some View {
        Rectangle()
            .fill(Color.white.opacity(0.05))
            .frame(maxWidth: .infinity)
            .frame(height: 1)
    }
    
    private func startNewRealmFlow() {
        withAnimation(.smooth(duration: 0.25)) {
            currentAppView = 2
        }
        DispatchQueue.global(qos: .background).async {
            Mixpanel.mainInstance().track(event: "Started unveiling a new realm")
        }
    }
}


struct DiscoverNewCategoryButton: View {
    
    
   
   
    var body: some View {
  
        VStack {
            
            Text("Discover your\nnext realm")
                .multilineTextAlignment(.center)
                .foregroundStyle(AppColors.textBlack)
                .font(.system(size: 21))
                .fontWidth(.condensed)
                .lineSpacing(1.3)
                .padding(.horizontal)
            
            
            Spacer()
            
            RoundButton(buttonImage: "arrow.right",
                        buttonAction: {
            })
            .disabled(true)
        }
        .padding(.vertical, 30)
        .frame(width: 215, height: 220)
        .contentShape(RoundedRectangle(cornerRadius: 25))
        .background {
            RoundedRectangle(cornerRadius: 15)
                .stroke(AppColors.strokePrimary.opacity(0.50), lineWidth: 0.5)
                .fill(
                    LinearGradient(
                        gradient: Gradient(colors: [AppColors.boxYellow1, AppColors.boxYellow2]),
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .shadow(color: Color.black.opacity(0.30), radius: 15, x: 0, y: 3)
        }
            
    }
}

//#Preview {
//    CategoryDescriptionView()
//}
