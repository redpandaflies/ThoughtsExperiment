//
//  LoadingPlaceholderContent.swift
//  Fearless2
//
//  Created by Yue Deng-Wu on 1/9/25.
//

import SwiftUI
import Pow

enum PlaceholderContent {
    case focusArea
    case newTopic
    case suggestions
    case recap
    case topicFragment
}

struct LoadingPlaceholderContent: View {
    @State private var isAnimating: Bool = false
    @State private var animate: Bool = false
    @State private var trimLight: Bool = false
  
    let contentType: PlaceholderContent
    private let screenWidth = UIScreen.current.bounds.width
    
    var body: some View {
        
        HStack (spacing: 12) {
                
            loadingBox()
           
        }
        .frame(maxWidth: .infinity, alignment: .center)
        .onDisappear {
            isAnimating = false
        }
    }
    
    private func loadingBox() -> some View {
        VStack {
            
            Text(getLoadingText())
                .multilineTextAlignment(.center)
                .font(.system(size: 11))
                .foregroundStyle(AppColors.textPrimary)
                .opacity(0.4)
                .textCase(.uppercase)
            
        }//VStack
        .frame(width: 150, height: 180)
        .background {
           
            getBackground()
                
        }
        
        .onAppear {
            isAnimating = true
            manageAnimationSequence()

        }
        .onDisappear {
            isAnimating = false
        }
    }
    
    private func getLoadingText() -> String {
        switch contentType {
        case .focusArea:
            return "Uncovering path"
        case .suggestions:
            return "Uncovering suggestions"
        case .topicFragment:
            return "Restoring fragment"
        case .newTopic:
            return "Creating new quest"
        case .recap:
            return "Getting reflections"
        }
    }
    
    private func getBackground() -> some View {
        ZStack {
            RoundedRectangle(cornerRadius: 20)
                .stroke(Color.white.opacity(0.3), lineWidth: 0.5)
                .fill(Color.clear)
            
            if animate {
                RoundedRectangle(cornerRadius: 20)
                    .stroke(Color.white, lineWidth: 0.5)
                    .fill(Color.clear)
                    .transition(.movingParts.clock(blurRadius: 5))
                    .mask {
                        if trimLight {
                            RoundedRectangle(cornerRadius: 20)
                                .opacity(0)
                        } else {
                            RoundedRectangle(cornerRadius: 20)
                               
                        }
                    }
            }

        }
        
    }
    
    private func manageAnimationSequence() {
        guard isAnimating else { return }
        
        withAnimation(
            .smooth(duration: 2)
        ) {
            animate = true
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            withAnimation(
                .smooth(duration: 1.5)
            ) {
                trimLight.toggle()
            }
    
                   
// Reset and repeat
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
               animate = false
               trimLight.toggle()
               manageAnimationSequence()
           }
       }
    }
}

