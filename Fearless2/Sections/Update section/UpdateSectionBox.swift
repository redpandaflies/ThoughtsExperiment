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
                Text(section?.sectionTitle ?? "")
                    .multilineTextAlignment(.leading)
                    .font(.system(size: 11, weight: .regular))
                    .foregroundStyle(AppColors.yellow1)
                    .textCase(.uppercase)
                
                Spacer()
            }
            
            if let questionType = QuestionType(rawValue: questions[selectedQuestion].questionType) {
               
                let currentQuestion = questions[selectedQuestion]
                
                switch questionType {
                    
                    case .singleSelect:
                        let optionsString = currentQuestion.questionSingleSelectOptions
                        let optionsArray = optionsString.components(separatedBy: ",")
                        QuestionSingleSelectView(singleSelectAnswer: $singleSelectAnswer, question: currentQuestion.questionContent, items: optionsArray)
                        
                    case .multiSelect:
                        let optionsString = currentQuestion.questionMultiSelectOptions
                        let optionsArray = optionsString.components(separatedBy: ",")
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
