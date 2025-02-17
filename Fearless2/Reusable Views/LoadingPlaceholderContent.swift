//
//  LoadingPlaceholderContent.swift
//  Fearless2
//
//  Created by Yue Deng-Wu on 1/9/25.
//

import SwiftUI

enum PlaceholderContent {
    case focusArea
    case suggestions
}

struct LoadingPlaceholderContent: View {
    @State private var enableAnimation: Bool = false
    @State private var animationEffect: Int = 0
    let timer = Timer.publish(every: 3, on: .main, in: .common).autoconnect()
    let contentType: PlaceholderContent
    private let screenWidth = UIScreen.current.bounds.width
    
    var body: some View {
        
        HStack (spacing: 12) {
            Spacer()
                
            loadingBox()
                
            Spacer()
        }
        
    }
    
    private func loadingBox() -> some View {
        VStack {
            
            Text(getLoadingText())
                .font(.system(size: 11))
                .foregroundStyle(AppColors.textPrimary)
                .opacity(0.4)
                .textCase(.uppercase)
            
        }
        .frame(width: 150, height: 180)
        .background {
            RoundedRectangle(cornerRadius: 20)
                .stroke(Color.white.opacity(0.2), lineWidth: 0.5)
                .fill(Color.clear)
        }
        .animation(.default, value: animationEffect)
        .changeEffect (
            .shine.delay(0.2),
            value: animationEffect,
            isEnabled: enableAnimation
        )
        .onAppear {
            
            withAnimation(.easeIn(duration: 0.5)) {
                enableAnimation = true
                animationEffect += 1
            }
            
        }
        .onDisappear {
            
            timer.upstream.connect().cancel()
                            
        }
        .onReceive(timer) { time in

            animationEffect += 1
        }
    }
    
    private func getLoadingText() -> String {
        switch contentType {
        case .focusArea:
            return "Uncovering path"
        case .suggestions:
            return "Uncovering suggestions"
        }
    }
}

