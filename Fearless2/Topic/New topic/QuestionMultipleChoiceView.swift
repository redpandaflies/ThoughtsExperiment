//
//  QuestionMultipleChoiceView.swift
//  Fearless2
//
//  Created by Yue Deng-Wu on 10/5/24.
//

import SwiftUI
import WrappingHStack

struct QuestionMultiSelectView: View {
    @Binding var selectedOptions: [String]
    let question: String
    let items: [String]
        
    var body: some View {
        VStack (alignment: .leading, spacing: 10) {
            
            Text(question)
                .multilineTextAlignment(.leading)
                .font(.system(size: 19))
                .fontWeight(.semibold)
                .foregroundStyle(Color.white)
                .fixedSize(horizontal: false, vertical: true)
                .padding(.vertical, 10)
            
            Text("Choose all that apply")
                .font(.system(size: 11))
                .fontWeight(.light)
                .foregroundStyle(Color.white)
                .textCase(.uppercase)
            
            WrappingHStack(items, id: \.self, alignment: .leading, spacing: .constant(13), lineSpacing: 12) { pill in
                QuestionBubble(selected: selectedOptions.contains(pill), option: pill)
                    .onTapGesture {
                        selectPill(pillLabel: pill)
                    }
            }
            .padding(.bottom, 30)
            
        }
    }
    
    private func selectPill(pillLabel: String) {
        if let index = selectedOptions.firstIndex(of: pillLabel) {
            // If the pill is already selected, remove it
            selectedOptions.remove(at: index)
        } else {
            // Otherwise, add it to the selected pills
            selectedOptions.append(pillLabel)
        }
    }
}

struct QuestionBubble: View {
    let selected: Bool
    let option: String
    
    var body: some View {
        HStack (spacing: 5) {
            Text(option)
                .font(.system(size: 14))
                .foregroundStyle(selected ? Color.black : Color.white)
                .fontWeight(.light)
                .textCase(.lowercase)
                .fixedSize(horizontal: true, vertical: true)
        }
        .padding(.horizontal, 18)
        .frame(height: 33)
        .background {
            RoundedRectangle(cornerRadius: 10)
                .stroke(Color.white, lineWidth: 1)
                .fill(selected ? Color.white : Color.clear)
        }
    }
}

//#Preview {
//    QuestionMultiSelectView()
//}
