//
//  NewGoalLoadingView.swift
//  Fearless2
//
//  Created by Yue Deng-Wu on 4/9/25.
//
import Combine
import Lottie
import Pow
import SwiftUI

struct NewGoalLoadingView: View {
    @State private var animationSpeed: CGFloat = 1.0
    @State private var symbolAnimationValue: Bool = false
    @State private var play: Bool = true
    @State private var nextLine: Int = -1 // controls which line of text is shown
    @State private var checkOff: Int = 0 // controls the sf symbol shown
    
    @Binding var animationCompleted: Bool
    
    let texts: [String]
    let showFooter: Bool
    
    
    init(
        texts: [String],
        showFooter: Bool = false,
        animationCompleted: Binding<Bool> = .constant(false)
    ) {
        self.texts = texts
        self.showFooter = showFooter
        self._animationCompleted = animationCompleted
    }
    
    var body: some View {
        VStack (alignment: .leading, spacing: 20) {
            
//            if play {
//                SpinnerDefault()
//                    .transition(.opacity)
//                    .padding(.bottom, 20)
//            }
            LottieView(
                loopMode: .playOnce,
                animationSpeed: $animationSpeed,
                play: $play
            )
            .aspectRatio(contentMode: .fit)
            .frame(width: 90, height: 90)
                
            
            ForEach(Array(texts.enumerated()), id: \.offset) { index, text in
                if index <= nextLine {
                    getContent(index: index, title: text)
                        .transition(.opacity)
                        .padding(.bottom, 5)
                        .padding(.horizontal)
                }
            }
            
            if showFooter {
                Spacer()
                
                getFooter()
                    .padding(.bottom, 20)
                    .padding(.horizontal)
            }
      
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .onAppear {
            startAnimation()
        }
        .onDisappear {
            symbolAnimationValue = false
        }
    }
    
    private func startAnimation() {
        
//        withAnimation(.snappy(duration: 0.5)) {
            play = true
//        }
    
        updateNextLine(after: 1.5)
        updateNextLine(after: 4)
        updateNextLine(after: 6.5, showCheckmark: false)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 7.0) {
            animationCompleted = true
        }
    }
    
    private func updateNextLine(after delay: Double, showCheckmark: Bool = true) {
       DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
           withAnimation(.smooth(duration: 0.2)) {
               nextLine += 1
           }
           
           if showCheckmark {
               DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                   withAnimation(.snappy(duration: 0.2)) {
                       checkOff += 1
                   }
               }
           } else {
               symbolAnimationValue = true
           }
       }
   }
    
    private func getContent(index: Int, title: String) -> some View {
        
        HStack (spacing: 10) {
          
            if index < checkOff {
                Image(systemName: getIcon(index: index))
                    .multilineTextAlignment(.leading)
                    .font(.system(size: 19))
                    .foregroundStyle(getColor(index: index))
                    .transition(
                        .movingParts.pop(AppColors.textPrimary)
                    )
            } else {
                Image(systemName: getIcon(index: index))
                    .multilineTextAlignment(.leading)
                    .font(.system(size: 19))
                    .foregroundStyle(getColor(index: index))
                    .contentTransition(.symbolEffect(.replace.offUp.byLayer))
                    .symbolEffect(.wiggle.byLayer, options: .repeat(.periodic(delay: 1.0)), value: symbolAnimationValue)
            }
            

            Text(title)
                .multilineTextAlignment(.leading)
                .font(.system(size: 19, design: .serif))
                .foregroundStyle(getColor(index: index))
 
        }//HStack
        
        
    }
   
    private func getIcon(index: Int) -> String {
        
        if index < checkOff {
            return "checkmark"
        }
        
        return "arrow.forward"
        
    }
    
    private func getColor(index: Int) -> Color {
        if index == nextLine {
            return AppColors.textPrimary
        }
        
        return AppColors.textPrimary.opacity(0.5)
    }
    
    private func getFooter() -> some View {
        HStack (spacing: 5) {
            Image(systemName: "clock.fill")
                .multilineTextAlignment(.leading)
                .font(.system(size: 14, weight: .light))
                .foregroundStyle(AppColors.textPrimary.opacity(0.5))
            
            Text("This step might take up to a minute")
                .multilineTextAlignment(.leading)
                .font(.system(size: 14, weight: .light))
                .foregroundStyle(AppColors.textPrimary.opacity(0.5))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
    
}


