//
//  QuestionSingleSelectView.swift
//  Fearless2
//
//  Created by Yue Deng-Wu on 10/5/24.
//

import SwiftUI
import WrappingHStack

struct QuestionSingleSelectView: View {
    @Binding var singleSelectAnswer: String
    let question: String
    let items: [String]
        
    var body: some View {
        VStack (alignment: .leading, spacing: 15) {
            
            Text(question)
                .multilineTextAlignment(.leading)
                .font(.system(size: 22, design: .serif))
                .foregroundStyle(AppColors.textPrimary)
                .fixedSize(horizontal: false, vertical: true)
                .padding(.bottom, 15)
            
            
            VStack (spacing: 15) {
                ForEach(items, id: \.self) { pill in
                    SingleSelectQuestionBubble(selected: singleSelectAnswer == pill, option: pill)
                        .onTapGesture {
                            selectPill(pillLabel: pill)
                        }
                }
            }
        }//VStack
    }
    
    private func selectPill(pillLabel: String) {
        if singleSelectAnswer == pillLabel {
            // If the pill is already selected, reset selectedOption
            singleSelectAnswer = ""
        } else {
            singleSelectAnswer = pillLabel
        }
    }
}

struct SingleSelectQuestionBubble: View {
    let selected: Bool
    let option: String
    
    var body: some View {
        HStack (spacing: 5) {
            Text(option)
                .font(.system(size: 15, weight: .light))
                .foregroundStyle(selected ? AppColors.textBlack : AppColors.textPrimary)
                .fixedSize(horizontal: false, vertical: true)
            
            Spacer()
        }
        .padding(20)
        .contentShape(Rectangle())
        .background {
            RoundedRectangle(cornerRadius: 15)
                .stroke(selected ? Color.white.opacity(0.2) : Color.white.opacity(0.2), lineWidth: 0.5)
                .fill(selected ? Color.white.opacity(0.8) : Color.white.opacity(0.05))
        }
    }
}

//#Preview {
//    QuestionMultiSelectView()
//}
