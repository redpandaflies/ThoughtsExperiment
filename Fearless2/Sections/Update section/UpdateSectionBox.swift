//
//  UpdateSectionBox.swift
//  Fearless2
//
//  Created by Yue Deng-Wu on 10/3/24.
//

import SwiftUI

struct UpdateSectionBox: View {
    @EnvironmentObject var dataController: DataController
    @ObservedObject var topicViewModel: TopicViewModel
    @Binding var selectedQuestion: Int
    @Binding var topicText: String
    @Binding var singleSelectAnswer: String
    @Binding var multiSelectAnswers: [String]

    @FocusState.Binding var isFocused: Bool

    let section: Section?
    let questions: [Question]
    
    var body: some View {
            
        VStack (alignment: .leading, spacing: 5) {
            
            HStack {
                
                HStack (spacing: 0) {
                    
                    if let categoryEmoji = section?.category?.categoryEmoji {
                        Text(categoryEmoji)
                            .font(.system(size: 19))
                            .padding(.trailing, 5)
                    }
                    
                    Text(section?.sectionTitle ?? "")
                        .multilineTextAlignment(.leading)
                        .font(.system(size: 19, weight: .light).smallCaps())
                        .fontWidth(.condensed)
                        .foregroundStyle(AppColors.textPrimary.opacity(0.8))
                }
                Spacer()
            }
            
            if let questionType = QuestionType(rawValue: questions[selectedQuestion].questionType) {
               
                let currentQuestion = questions[selectedQuestion]
                
                switch questionType {
                    
                    case .singleSelect:
                        let optionsString = currentQuestion.questionSingleSelectOptions
                        let optionsArray = optionsString.components(separatedBy: ";")
                        QuestionSingleSelectView(singleSelectAnswer: $singleSelectAnswer, question: currentQuestion.questionContent, items: optionsArray)
                        
                    case .multiSelect:
                        let optionsString = currentQuestion.questionMultiSelectOptions
                        let optionsArray = optionsString.components(separatedBy: ";")
                        QuestionMultiSelectView(multiSelectAnswers: $multiSelectAnswers, question: currentQuestion.questionContent, items: optionsArray)
                    
                    default:
                        QuestionOpenView(topicText: $topicText, isFocused: $isFocused, question: currentQuestion.questionContent)
                    
                }
            }
            
            Spacer()
            
        }//VStack
        
    }
}

//#Preview {
//    UpdateTopicBox()
//}
