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
    
    var question: String? = nil
    
    var body: some View {
        VStack (alignment: .leading, spacing: 10) {
            
            Text(question ?? "")
            .multilineTextAlignment(.leading)
            .font(.system(size: 19))
            .foregroundStyle(Color.white)
            .fixedSize(horizontal: false, vertical: true)
            
            TextField("Enter your answer", text: $topicText, axis: .vertical)
                .font(.system(size: 16))
                .fontWeight(.light)
                .foregroundStyle(Color.white)
                .lineSpacing(3)
                .lineLimit(7)
                .focused($isFocused)
                .keyboardType(.alphabet)
                
        }//HStack
        .padding(.vertical, 10)
    }
}
