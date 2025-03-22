//
//  QuestionOpenView.swift
//  Fearless2
//
//  Created by Yue Deng-Wu on 10/7/24.
//

import SwiftUI

struct QuestionOpenView: View {
    
    @Binding var topicText: String
    @FocusState.Binding var isFocused: Bool
    
    let question: String
    let placeholderText: String
    let answer: String
    let disableNewLine: Bool
    
    init(topicText: Binding<String>,
         isFocused: FocusState<Bool>.Binding,
         question: String = "",
         placeholderText: String = "Type your answer",
         answer: String = "",
         disableNewLine: Bool = false
    ) {
        self._topicText = topicText
        self._isFocused = isFocused
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
            
            TextField(placeholderText, text: $topicText, axis: .vertical)
                .font(.system(size: 16))
                .fontWeight(.light)
                .foregroundStyle(AppColors.textPrimary)
                .lineSpacing(3)
                .focused($isFocused)
                .keyboardType(.alphabet)
                .onChange(of: topicText) { oldValue, newValue in
                    if disableNewLine && newValue.contains("\n") {
                        topicText = newValue.replacingOccurrences(of: "\n", with: "")
                        
                    }
                }
                
        }//VStack
        .environment(\.colorScheme, .dark)
        .onAppear {
            if !answer.isEmpty {
                topicText = answer
            }
            
            if !isFocused {
                isFocused = true
            }
        }
        .onChange(of: question) {
            if !answer.isEmpty {
                topicText = answer
            }
            if !isFocused {
                isFocused = true
            }
        }
        
    }
}
