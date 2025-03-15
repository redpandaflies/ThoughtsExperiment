//
//  NewCategoryQuestionsView.swift
//  Fearless2
//
//  Created by Yue Deng-Wu on 3/5/25.
//

import SwiftUI

struct NewCategoryQuestionsView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var dataController: DataController
    
    @State private var selectedQuestion: Int = 0
    @State private var progressBarQuestionIndex: Int = 0
    @State private var answerOpen: String = ""
    @State private var answerSingleSelect: String = ""
    
    @State private var questions: [QuestionsNewCategory] = []
    @Binding var selectedCategory: String
    @Binding var selectedIntroPage: Int
    
    let categories: FetchedResults<Category>
    
    var currentQuestion: QuestionsNewCategory {
        let firstQuestion = QuestionsNewCategory.initialQuestionNewCategory(from: categories)
            
        if questions.isEmpty {
            return firstQuestion[0]
        } else {
            return questions[selectedQuestion]
        }
    }
    
    @FocusState var isFocused: Bool
    
    var body: some View {
        VStack (spacing: 10){
            // MARK: Header
            QuestionsProgressBar(
                currentQuestionIndex: $progressBarQuestionIndex,
                totalQuestions: 3
            )
                
            // MARK: Title
            getTitle()
               
            // MARK: Question
            switch currentQuestion.questionType {
                case .open:
                QuestionOpenView(topicText: $answerOpen, isFocused: $isFocused, question: currentQuestion.content, placeholderText: "For best results, be very specific.")
                      
                default:
                    if selectedQuestion == 0 {
                        QuestionSingleSelectView(singleSelectAnswer: $selectedCategory, question: currentQuestion.content, items: currentQuestion.options ?? [])
                           
                    } else {
                        QuestionSingleSelectView(singleSelectAnswer: $answerSingleSelect, question: currentQuestion.content, items: currentQuestion.options ?? [])
                            
                    }
            }
           
            
            Spacer()
            
            // MARK: Next button
            RectangleButtonPrimary(
                buttonText: "Continue",
                action: {
                nextButtonAction()
                }, disableMainButton: disableButton(),
                buttonColor: .white)
        }
        .padding(.horizontal)
        .padding(.bottom)
        .background {
            BackgroundPrimary(backgroundColor: AppColors.backgroundOnboardingIntro)
        }
    }
    
    private func getTitle() -> some View {
        HStack (spacing: 5){
            if selectedQuestion == 0 {
                
                Text("💭")
                    .font(.system(size: 40, design: .serif))
                
                
            } else {
               
                Text(Realm.getEmoji(forLifeArea: selectedCategory))
                    .font(.system(size: 19, weight: .light))
                    .fontWidth(.condensed)
                
                Text(selectedCategory)
                    .font(.system(size: 19, weight: .light).smallCaps())
                    .fontWidth(.condensed)
                    .foregroundStyle(AppColors.textPrimary.opacity(0.7))
          
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        
    }
    
    private func disableButton() -> Bool {
      
        switch currentQuestion.questionType {
        case .open:
            return answerOpen.isEmpty
        default:
            if selectedQuestion == 0 {
                return selectedCategory.isEmpty
            } else {
                return answerSingleSelect.isEmpty
            }
        }
    }
    
    private func nextButtonAction() {
        //capture current state
        let answeredQuestionIndex = selectedQuestion
        let answeredQuestion = currentQuestion
        
        var answeredQuestionOpen: String?
//        var answeredQuestionSingleSelect: String?
        
        switch answeredQuestion.questionType {
        case .open:
            answeredQuestionOpen = answerOpen
        default:
//            if answeredQuestionIndex == 0 {
//                answeredQuestionSingleSelect = selectedCategory
//            } else {
//                answeredQuestionSingleSelect = answerSingleSelect
//            }
            break
        }
        
        switch answeredQuestionIndex {
        case 0:
            let categoryQuestions = QuestionsNewCategory.initialQuestionNewCategory(from: categories)
            
            questions = categoryQuestions
            
        case 2:
            if isFocused {
                isFocused = false
            }
            
            dismiss()
            
            withAnimation {
                selectedIntroPage += 1
            }
            
        default:
            break
        }
        
        DispatchQueue.main.async {
            if !answerOpen.isEmpty {
                answerOpen = ""
            }
            
            if selectedQuestion < 2 {
                
                selectedQuestion += 1
                
                withAnimation(.interpolatingSpring) {
                    progressBarQuestionIndex += 1
                }
            }
        }
        
        //Save question answer
        if answeredQuestionIndex > 0 {
                Task {
                switch answeredQuestion.questionType {
                case .open:
                    await dataController.saveAnswerOnboarding(questionType: answeredQuestion.questionType, question: answeredQuestion, userAnswer: answeredQuestionOpen ?? "", categoryLifeArea: selectedCategory)
                default:
                    
                    break
                    
                }
                
            }
        } else {
            //add the selected category to coredata
            Task {
                await dataController.createSingleCategory(lifeArea: selectedCategory)
                
            }
            
        }
    }
}

//#Preview {
//    NewCategoryQuestionsView()
//}
