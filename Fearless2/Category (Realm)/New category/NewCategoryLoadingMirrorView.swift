//
//  NewCategoryLoadingMirrorView.swift
//  Fearless2
//
//  Created by Yue Deng-Wu on 4/9/25.
//
import Combine
import SwiftUI

struct NewCategoryLoadingView: View {
   
    @State private var currentTextIndex = 0
    @State private var isVisible = true
    @State private var timer: AnyCancellable?
    @State private var mirrorSelectedTab: Int = 0
    
    let texts: [String]
    
    var body: some View {
        VStack {
          
            getTextView()
                .padding(.horizontal)

                
        }
        .padding(.top, 150)
        .ignoresSafeArea(.keyboard)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .onAppear {
            startTextRotation()
        }
        .onDisappear {
            // Cancel the timer when the view disappears
            timer?.cancel()
        }
    }
    
    private func getTextView() -> some View {
        Text(texts[currentTextIndex])
            .multilineTextAlignment(.center)
            .font(.system(size: 20, design: .serif))
            .foregroundStyle(AppColors.textPrimary)
            .fixedSize(horizontal: false, vertical: true)
            .lineSpacing(1.4)
            .opacity(isVisible ? 1 : 0)
            .animation(.easeInOut(duration: 0.5), value: isVisible)
    }
    
    private func startTextRotation() {
        // Create a repeating timer that changes the text every 3 seconds
        timer = Timer.publish(every: 2, on: .main, in: .common).autoconnect()
            .sink { _ in
            // First fade out the current text
            withAnimation {
                isVisible = false
            }
            
            // After a short delay, change the text and fade in
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                // Move to the next text
                currentTextIndex = (currentTextIndex + 1) % texts.count
                
                // Fade in the new text
                withAnimation {
                    isVisible = true
                }
            }
        }
    }
    
   
}


