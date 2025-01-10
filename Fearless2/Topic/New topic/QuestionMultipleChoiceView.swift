//
//  QuestionMultipleChoiceView.swift
//  Fearless2
//
//  Created by Yue Deng-Wu on 10/5/24.
//

import SwiftUI
import WrappingHStack

struct QuestionMultiSelectView: View {
    @Binding var multiSelectAnswers: [String]
    let question: String
    let items: [String]
        
    var body: some View {
        VStack (alignment: .leading, spacing: 10) {
            
            Text(question)
                .multilineTextAlignment(.leading)
                .font(.system(size: 25, weight: .light))
                .foregroundStyle(AppColors.whiteDefault)
                .fixedSize(horizontal: false, vertical: true)
                .padding(.vertical, 10)
            
            Text("Choose all that apply")
                .font(.system(size: 11))
                .fontWeight(.light)
                .foregroundStyle(AppColors.whiteDefault.opacity(0.7))
                .textCase(.uppercase)
            
            WrappingHStack(items, id: \.self, alignment: .leading, spacing: .constant(14), lineSpacing: 14) { pill in
                MultiSelectQuestionBubble(selected: multiSelectAnswers.contains(pill), option: pill)
                    .onTapGesture {
                        selectPill(pillLabel: pill)
                    }
            }

        }//VStack
    }
    
    private func selectPill(pillLabel: String) {
        if let index = multiSelectAnswers.firstIndex(of: pillLabel) {
            // If the pill is already selected, remove it
            multiSelectAnswers.remove(at: index)
        } else {
            // Otherwise, add it to the selected pills
            multiSelectAnswers.append(pillLabel)
        }
    }
}

struct MultiSelectQuestionBubble: View {
    let selected: Bool
    let option: String
    
    var body: some View {
        HStack (spacing: 5) {
            Text(option)
                .font(.system(size: 15, weight: .light))
                .foregroundStyle(selected ? Color.black : AppColors.whiteDefault)
                .fixedSize(horizontal: true, vertical: true)
        }
        .padding(.horizontal, 18)
        .frame(height: 35)
        .background {
            RoundedRectangle(cornerRadius: 10)
                .stroke(AppColors.whiteDefault, lineWidth: 0.5)
                .fill(selected ? AppColors.whiteDefault : Color.clear)
        }
    }
}

//#Preview {
//    QuestionMultiSelectView()
//}
