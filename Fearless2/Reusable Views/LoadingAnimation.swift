//
//  LoadingAnimation.swift
//  Fearless2
//
//  Created by Yue Deng-Wu on 10/2/24.
//
import SwiftUI

struct LoadingAnimation: View {
    @State private var play = false
    @State private var animationSpeed: CGFloat = 2.0
    
    
    var body: some View {
        VStack {
            LottieView(name: "loadingAnimation3", animationSpeed: $animationSpeed, play: $play)
                .aspectRatio(contentMode: .fit)
    
        }
        .frame(height: 120)
        .ignoresSafeArea(.keyboard)
        .onAppear {
            self.play = true
            UIApplication.shared.isIdleTimerDisabled = true
            
        }
        .onDisappear {
            self.play = false
            UIApplication.shared.isIdleTimerDisabled = false
        }
    }
}

#Preview {
    LoadingAnimation()
}
