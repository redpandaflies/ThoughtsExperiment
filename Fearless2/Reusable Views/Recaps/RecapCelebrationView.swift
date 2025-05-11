//
//  RecapCelebrationView.swift
//  Fearless2
//
//  Created by Yue Deng-Wu on 2/18/25.
//
import Pow
import SwiftUI


struct RecapCelebrationView: View {
    @Binding var animationStage: Int

    let title: String
    let text: String
    let points: String
    
    var body: some View {

        VStack {
            
            if animationStage >= 1 {
                LaurelItem(size: 50, points: points)
                    .transition(
                        .identity
                            .animation(.linear(duration: 1).delay(2))
                            .combined(
                                with: .movingParts.anvil
                            )
                    )
                    .padding(.bottom, 20)
            } else {
                LaurelItem(size: 50, points: points)
                    .opacity(0.0)
                    .padding(.bottom, 20)
            }
            
            Text(text)
                .font(.system(size: 25, weight: .light).smallCaps())
                .fontWidth(.condensed)
                .foregroundStyle(AppColors.textPrimary.opacity(0.5))
                .opacity((animationStage > 1) ? 1 : 0)
                
            
            Text(title)
                .multilineTextAlignment(.center)
                .font(.system(size: 25, design: .serif))
                .foregroundStyle(AppColors.textPrimary)
                .opacity((animationStage > 1) ? 1 : 0)
            
        }//VStack
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                withAnimation {
                    animationStage += 1
                }
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    withAnimation (.easeIn(duration: 0.25)) {
                        animationStage += 1
                    }
                }
                
            }
        }

    }
        
}
