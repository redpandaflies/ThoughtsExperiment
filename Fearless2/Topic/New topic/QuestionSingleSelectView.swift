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
                .font(.system(size: 25, weight: .light))
                .foregroundStyle(AppColors.whiteDefault)
                .fixedSize(horizontal: false, vertical: true)
            
            
            VStack {
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
                .foregroundStyle(selected ? Color.black : AppColors.whiteDefault)
                .textCase(.lowercase)
                .fixedSize(horizontal: true, vertical: true)
            
            Spacer()
        }
        .padding(20)
        .background {
            RoundedRectangle(cornerRadius: 15)
                .stroke(AppColors.whiteDefault, lineWidth: 1)
                .fill(selected ? AppColors.whiteDefault : Color.clear)
        }
    }
}

//#Preview {
//    QuestionMultiSelectView()
//}
