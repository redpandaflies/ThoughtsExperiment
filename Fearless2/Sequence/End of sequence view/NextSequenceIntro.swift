//
//  NextSequenceIntro.swift
//  Fearless2
//
//  Created by Yue Deng-Wu on 4/16/25.
//

import SwiftUI

struct NextSequenceIntro: View {
    
    @State private var currentIndex: Int = -1
    
    let goal: Goal
    
    let content: [String] = [
        "What you uncovered",
        "Progress you've made",
        "How you feel about it",
        "Decide if this topic is resolved or not"
    ]
    
    var body: some View {
        VStack (alignment: .leading, spacing: 10) {
            Text(goal.goalTitle)
                .multilineTextAlignment(.leading)
                .font(.system(size: 25, design: .serif))
                .foregroundStyle(AppColors.textPrimary)
            
            Text(goal.goalResolution)
                .multilineTextAlignment(.leading)
                .font(.system(size: 17, weight: .light))
                .foregroundStyle(AppColors.textPrimary.opacity(0.7))
                .lineSpacing(1.4)
                .padding(.bottom, 18)
            
            ForEach(content.indices, id: \.self) { index in
               getContent(text: content[index])
                   .opacity(currentIndex >= index ? 1 : 0)
                   .animation(.easeIn(duration: 0.25), value: currentIndex)
            }
            
            
        }
        .onAppear {
            // schedule each item to appear 0.5s apart
            for i in content.indices {
                DispatchQueue.main.asyncAfter(deadline: .now() + Double(i) * 0.5) {
                    withAnimation {
                        currentIndex = i
                    }
                }
            }
        }
    }
    
    private func getContent(text: String) -> some View {
        HStack {
            Image(systemName: "arrow.right.circle")
                .multilineTextAlignment(.leading)
                .font(.system(size: 19))
                .foregroundStyle(AppColors.textPrimary)
                .contentTransition(.symbolEffect(.replace.offUp.byLayer))
            
            Text(text)
                .multilineTextAlignment(.leading)
                .font(.system(size: 19, weight: .light))
                .fontWidth(.condensed)
                .foregroundStyle(AppColors.textPrimary)
            
        }
        .padding(.horizontal)
        .padding(.bottom, 10)
    }
}


