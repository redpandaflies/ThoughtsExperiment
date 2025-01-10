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
        ScrollView (.horizontal) {
            HStack (spacing: 12) {
                ForEach(0..<4) { _ in
                    
                    loadingBox()
                    
                }
            }
        }
        .padding(.horizontal)
        .scrollIndicators(.hidden)
        .scrollClipDisabled(true)
    }
    
    private func loadingBox() -> some View {
        VStack {
            
            Text("Generating")
                .font(.system(size: 11))
                .foregroundStyle(AppColors.whiteDefault)
                .opacity(0.6)
                .textCase(.uppercase)
            
        }
        .frame(width: getWidth(), height: getHeight())
        .background {
            RoundedRectangle(cornerRadius: 20)
                .stroke(AppColors.whiteDefault.opacity(0.2), lineWidth: 1)
                .fill(AppColors.black4)
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
    
    private func getWidth() -> CGFloat {
        switch contentType {
        case .focusArea:
            return 150
        case .suggestions:
            return screenWidth * 0.80
        }
    }
    
    private func getHeight() -> CGFloat {
        switch contentType {
        case .focusArea:
            return 180
        case .suggestions:
            return 330
        }
    }
}

