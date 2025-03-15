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
    
    init(topicText: Binding<String>,
         isFocused: FocusState<Bool>.Binding,
         question: String = "",
         placeholderText: String = "Type your answer",
         answer: String = ""
    ) {
        self._topicText = topicText
        self._isFocused = isFocused
        self.question = question
        self.placeholderText = placeholderText
        self.answer = answer
  
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
                    if newValue.contains("\n") {
                        topicText = newValue.replacingOccurrences(of: "\n", with: "")
                    }
                }
                
        }//VStack
        .environment(\.colorScheme, .dark)
        .onAppear {
            if !isFocused {
                isFocused = true
            }
            
            if !answer.isEmpty {
                topicText = answer
            }
        }
        .onChange(of: question) {
            if !isFocused {
                isFocused = true
            }
        }
        
    }
}
