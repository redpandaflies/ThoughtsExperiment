//
//  QuestionOpenView2.swift
//  Fearless2
//
//  Created by Yue Deng-Wu on 10/7/24.
//

import SwiftUI

struct QuestionOpenView2: View {
    
    @Binding var topicText: String
    @FocusState.Binding var focusField: DefaultFocusField?
    let focusValue: DefaultFocusField
    
    let question: String
    let placeholderText: String
    let answer: String
    let disableNewLine: Bool
    
    init(topicText: Binding<String>,
         focusField: FocusState<DefaultFocusField?>.Binding,
         focusValue: DefaultFocusField,
         question: String = "",
         placeholderText: String = "Type your answer",
         answer: String = "",
         disableNewLine: Bool = false
    ) {
        self._topicText = topicText
        self._focusField = focusField
        self.focusValue = focusValue
        self.question = question
        self.placeholderText = placeholderText
        self.answer = answer
        self.disableNewLine = disableNewLine
    }
    
    var body: some View {
        
        VStack (alignment: .leading, spacing: 15) {
            
            Text(question)
                .multilineTextAlignment(.leading)
                .font(.system(size: 22, design: .serif))
                .foregroundStyle(AppColors.textPrimary)
                .fixedSize(horizontal: false, vertical: true)
            
            TextField("", text: $topicText, prompt: Text(placeholderText).foregroundStyle(AppColors.textPrimary.opacity(0.6)),axis: .vertical)
                .font(.system(size: 16))
                .fontWeight(.light)
                .foregroundStyle(AppColors.textPrimary)
                .lineSpacing(3)
                .focused($focusField, equals: focusValue)
                .keyboardType(.alphabet)
                .onChange(of: topicText) { oldValue, newValue in
                    if disableNewLine && newValue.contains("\n") {
                        topicText = newValue.replacingOccurrences(of: "\n", with: "")
                    }
                }
                
        }//VStack
        .onAppear {
            if !answer.isEmpty {
                topicText = answer
            }
            
            if focusField == nil {
                focusField = focusValue
            }
        }
        .onChange(of: question) {
            if !answer.isEmpty {
                topicText = answer
            }
            if focusField == nil {
                focusField = focusValue
            }
        }
    }
}
