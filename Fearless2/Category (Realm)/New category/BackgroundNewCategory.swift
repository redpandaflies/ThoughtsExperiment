//
//  BackgroundNewCategory.swift
//  Fearless2
//
//  Created by Yue Deng-Wu on 3/1/25.
//

import SwiftUI

struct BackgroundNewCategory: View {
    @Binding var animationStage: Int
    let backgroundColor: Color
    let newBackgroundColor: Color
    
    let screenWidth = UIScreen.current.bounds.width
    let screenHeight = UIScreen.current.bounds.height
    
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
                            .frame(width: (animationStage == 2) ? screenWidth * 3 : 50,
                                   height: (animationStage == 2) ? screenWidth * 3 : 50)
                            .offset(y: screenHeight * 0.1)
                            .animation(.bouncy(duration: 1.5), value: (animationStage == 2))
                            .opacity( (animationStage == 2) ? 1 : 0)
                    }
                }
        }
        .ignoresSafeArea(.keyboard, edges: .all)
       
    }
}

//#Preview {
//    // Using a container view to manage state
//    struct PreviewContainer: View {
//        @State private var animationStage: Int = 1
//        
//        var body: some View {
//            BackgroundNewCategory(
//                animationStage: $animationStage,
//                backgroundColor: AppColors.backgroundOnboardingIntro,
//                newBackgroundColor: AppColors.backgroundCareer
//            )
//            .onAppear {
//                // Small delay to make animation visible
//                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
//                    animationStage = 2
//                }
//            }
//        }
//    }
//    
//    return PreviewContainer()
//}
