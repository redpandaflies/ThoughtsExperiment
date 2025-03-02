//
//  BackgroundOnboarding.swift
//  Fearless2
//
//  Created by Yue Deng-Wu on 3/1/25.
//

import SwiftUI

struct BackgroundOnboarding: View {
    @Binding var animationStage: Int
    let backgroundColor: Color
    let newBackgroundColor: Color
    
    let screenWidth = UIScreen.current.bounds.width
    
    var body: some View {
        GeometryReader { geo in
            //geometryreader needed to keep the image from being pushed up by keyboard
            
            Image("backgroundPrimary")
                .resizable()
                .aspectRatio(contentMode: .fill)
                .ignoresSafeArea()
                .background {
                    ZStack {
                        backgroundColor
                            .ignoresSafeArea()
                        
                        Circle()
                            .fill(newBackgroundColor)
                            .opacity( (animationStage == 2) ? 1 : 0)
                            .frame(width: (animationStage == 2) ? screenWidth * 3 : 50,
                                   height: (animationStage == 2) ? screenWidth * 3 : 50)
                           .animation(.easeInOut(duration: 2), value: (animationStage == 2))
                    }
                }
        }
        .ignoresSafeArea(.keyboard, edges: .all)
    }
}

//#Preview {
//    BackgroundOnboarding(backgroundColor: AppColors.backgroundOnboardingIntro, newBackgroundColor: AppColors.backgroundCareer)
//}
