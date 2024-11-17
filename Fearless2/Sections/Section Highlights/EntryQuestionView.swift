//
//  EntryQuestionView.swift
//  Tinyverse
//
//  Created by Yue Deng-Wu on 10/23/24.
//

import SwiftUI

struct EntryQuestionView: View {
    
    let question: Question
    
    var body: some View {
        
        VStack (alignment: .leading, spacing: 10) {
            Text(question.questionContent)
                .multilineTextAlignment(.leading)
                .foregroundStyle(Color.white)
                .font(.headline)
                .fontWeight(.semibold)
            
            Text(getAnswer())
                .multilineTextAlignment(.leading)
                .foregroundStyle(Color.white)
                .font(.headline)
                .fontWeight(.regular)
        }
        .padding(.bottom, 8)
    }
    
    
   private func getAnswer() -> String {
       guard let questionType = QuestionType(rawValue: question.questionType) else { return "" }
       
        switch questionType {
        case .open:
            return question.questionAnswerOpen
        case .scale:
            return "On a scale of 1 to 10, \(question.answerScale)"
        case .multiSelect:
            return question.questionAnswerMultiSelect
        }
        
    }
}

//#Preview {
//    EntryQuestionsView()
//}