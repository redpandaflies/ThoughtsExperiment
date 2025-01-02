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
    
    var question: String
    let placeholderText: String
    
    init(topicText: Binding<String>,
         isFocused: FocusState<Bool>.Binding,
         question: String = "",
         placeholderText: String = "Enter your answer") {
        self._topicText = topicText
        self._isFocused = isFocused
        self.question = question
        self.placeholderText = placeholderText
    }
    
    var body: some View {
        
        VStack (alignment: .leading, spacing: 15) {
            
            Text(question)
                .multilineTextAlignment(.leading)
                .font(.system(size: 25, weight: .light))
                .foregroundStyle(AppColors.whiteDefault)
                .fixedSize(horizontal: false, vertical: true)
            
            TextField(placeholderText, text: $topicText, axis: .vertical)
                .font(.system(size: 16))
                .fontWeight(.light)
                .foregroundStyle(AppColors.whiteDefault)
                .lineSpacing(3)
                .focused($isFocused)
                .keyboardType(.alphabet)
                
        }//VStack
        
    }
}
