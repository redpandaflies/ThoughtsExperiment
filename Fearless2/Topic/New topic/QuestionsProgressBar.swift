//
//  QuestionsProgressBar.swift
//  Fearless2
//
//  Created by Yue Deng-Wu on 11/9/24.
//

import SwiftUI

struct QuestionsProgressBar: View {
    @Binding var currentQuestionIndex: Int
    let questionCount: Int
    let screenWidth = UIScreen.current.bounds.width
    let action: () -> Void
    
    var body: some View {
        HStack {
            Image(systemName: "arrow.right.circle.fill")
                .font(.system(size: 30, weight: .light))
                .foregroundStyle(Color.clear)
            
            Spacer()
            
            if questionCount > 1 {
                HStack(spacing: 5) {
                    ForEach(0..<questionCount, id: \.self) { index in
                        Circle()
                            .stroke(getDotStrokeColor(index: index), lineWidth: 1)
                            .fill(getDotColor(index: index))
                            .frame(width: 10, height: 10)
                        
                    }
                }
                
                
                Spacer()
            }
            
            Button {
                action()
            } label: {
                Image(systemName: "arrow.right.circle.fill")
                    .font(.system(size: 30, weight: .light))
                    .foregroundStyle(Color.white)
                    .padding(.horizontal)
            }
        }
        .padding(.vertical, 10)
    }
    
    private func getDotColor(index: Int) -> Color {
        index < currentQuestionIndex ? Color.white : Color.clear
    }
    
    private func getDotStrokeColor(index: Int) -> Color {
        index <= currentQuestionIndex ? Color.white : Color.white.opacity(0.4)
    }
}

//#Preview {
//    QuestionsProgressBar(questionCount: 5)
//}
