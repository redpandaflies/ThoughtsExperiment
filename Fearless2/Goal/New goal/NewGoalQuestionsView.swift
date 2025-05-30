//
//  NewGoalQuestionsView.swift
//  Fearless2
//
//  Created by Yue Deng-Wu on 3/5/25.
//
import Mixpanel
import SwiftUI

struct NewGoalQuestionsView: View {
    @EnvironmentObject var dataController: DataController
    @ObservedObject var newGoalViewModel: NewGoalViewModel
    
    @Binding var showProgressBar: Bool
    @Binding var mainSelectedTab: Int
    @Binding var selectedQuestion: Int
    @Binding var questions: [QuestionNewCategory]
    // Array to store all open question answers
    @Binding var answersOpen: [String]
    // Array to store all single-select question answers
    @Binding var answersSingleSelect: [String]
    @Binding var multiSelectAnswers: [[String]]
    @Binding var multiSelectCustomItems: [[String]]
    
    @FocusState.Binding var focusField: DefaultFocusField?
    
    var currentQuestion: QuestionNewCategory {
        return questions[selectedQuestion]
    }
    
    var body: some View {
        VStack (spacing: 10){
            
            // MARK: Title
            if selectedQuestion > 0 {
                getTitle()
            }
               
            // MARK: Question
            switch currentQuestion.questionType {
                case .open:
                    QuestionOpenView2 (
                        topicText: $answersOpen[selectedQuestion],
                        focusField: $focusField,
                        focusValue: .question(selectedQuestion),
                        question: currentQuestion.content,
                        placeholderText: "For best results, be very specific."
                    )
                
                case .multiSelect:
                    QuestionMultiSelectView (
                        multiSelectAnswers: $multiSelectAnswers[selectedQuestion],
                        customItems: $multiSelectCustomItems[selectedQuestion],
                        showProgressBar: $showProgressBar,
                        question: currentQuestion.content,
                        items: getMultiSelectOptions(),
                        subTitle: selectedQuestion == 5 ? "Choose at least two" : "Choose all that apply"
                    )
       
                default:
                    QuestionSingleSelectView (
                        singleSelectAnswer: $answersSingleSelect[selectedQuestion],
                        showProgressBar: $showProgressBar,
                        question: currentQuestion.content,
                        items: currentQuestion.options ?? [],
                        subTitle: selectedQuestion == 0 ? "Think of something that's been bothering you" : "",
                        showSymbol: selectedQuestion == 0 ? true : false
                    )
                    
            }
            
        }//VStack
        .padding(.bottom)
        
    }
    
    private func getTitle() -> some View {
        HStack (spacing: 5){
            Text(answersSingleSelect[0])
                .font(.system(size: 19, weight: .light).smallCaps())
                .fontWidth(.condensed)
                .foregroundStyle(AppColors.textPrimary.opacity(0.7))
            
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        
    }
    
    private func getMultiSelectOptions() -> [String] {
        if selectedQuestion == 5 {
            
           var questions = newGoalViewModel.newCategorySummary?.areas ?? []
            questions.append(CustomOptionType.other.rawValue)
            
            return questions
        }
        
        return currentQuestion.options ?? []
    }

}

//#Preview {
//    NewCategoryQuestionsView()
//}
