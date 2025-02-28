//
//  OnboardingQuestionsView.swift
//  Fearless2
//
//  Created by Yue Deng-Wu on 2/25/25.
//

import SwiftUI

struct OnboardingQuestionsView: View {
    @EnvironmentObject var dataController: DataController
    
    @State private var selectedQuestion: Int = 0
   
    @State private var answerOpen: String = ""
    @State private var answerSingleSelect: String = ""
    @State private var questions: [QuestionsOnboarding] = QuestionsOnboarding.initialQuestion
    
    @Binding var selectedTab: Int
    @Binding var categoriesScrollPosition: Int?
    @Binding var selectedCategory: String
    
    var currentQuestion: QuestionsOnboarding {
        return questions[selectedQuestion]
    }
    
    @FocusState var isFocused: Bool
    
    var body: some View {
        VStack {
            // MARK: Header
            QuestionsProgressBar(currentQuestionIndex: $selectedQuestion, totalQuestions: 6, xmarkAction: {
                    //tbd
            })
                
            // MARK: Title
            getTitle()
            
            
            // MARK: Question
            switch currentQuestion.questionType {
            case .open:
                QuestionOpenView(topicText: $answerOpen, isFocused: $isFocused, question: currentQuestion.content, placeholderText: "Share as much as you’d like")
            default:
                if selectedQuestion == 0 {
                    QuestionSingleSelectView(singleSelectAnswer: $selectedCategory, question: currentQuestion.content, items: currentQuestion.options ?? [])
                } else {
                    QuestionSingleSelectView(singleSelectAnswer: $answerSingleSelect, question: currentQuestion.content, items: currentQuestion.options ?? [])
                }
            }
           
            
            Spacer()
            
            // MARK: Next button
            RectangleButtonPrimary(buttonText: "Continue", action: {
                nextButtonAction()
            }, buttonColor: .white)
        }
        .padding(.horizontal)
        .padding(.bottom)
    }
    
    private func getTitle() -> some View {
        HStack (spacing: 5){
            if selectedQuestion == 0 {
                
                Text("🛌")
                    .font(.system(size: 40, design: .serif))
                
                
            } else {
               
                Text(Realm.getEmoji(forLifeArea: selectedCategory))
                    .font(.system(size: 19, weight: .light))
                    .fontWidth(.condensed)
                
                Text(selectedCategory)
                    .font(.system(size: 19, weight: .light))
                    .fontWidth(.condensed)
                    .foregroundStyle(AppColors.textPrimary.opacity(0.7))
          
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        
    }
    
    private func nextButtonAction() {
        //capture current state
        let answeredQuestionIndex = selectedQuestion
        let answeredQuestion = currentQuestion
        
        var answeredQuestionOpen: String?
        var answeredQuestionSingleSelect: String?
        
        switch answeredQuestion.questionType {
        case .open:
            answeredQuestionOpen = answerOpen
        default:
            if answeredQuestionIndex == 0 {
                answeredQuestionSingleSelect = selectedCategory
            } else {
                answeredQuestionSingleSelect = answerSingleSelect
            }
        }
        
        switch answeredQuestionIndex {
        case 0:
            let categoryQuestions = QuestionsOnboarding.getQuestionFlow(for: selectedCategory)
                questions.append(contentsOf: categoryQuestions)
        case 4:
            selectedTab = 0
            
        case 5:
            if isFocused {
                isFocused = false
            }
            categoriesScrollPosition = 4
            
            selectedTab = 0
            
            answerOpen = ""
            
        default:
            break
        }
        
        if selectedQuestion < 4 {
            selectedQuestion += 1
        }
        
        //Save question answer
        if answeredQuestionIndex > 0 {
                Task {
                switch answeredQuestion.questionType {
                case .open:
                    await dataController.saveAnswerOnboarding(questionType: answeredQuestion.questionType, question: answeredQuestion, userAnswer: answeredQuestionOpen ?? "", categoryLifeArea: Realm.getLifeArea(forCategory: answeredQuestion.category))
                default:
                    
                    await dataController.saveAnswerOnboarding(questionType: answeredQuestion.questionType, question: answeredQuestion, userAnswer: answeredQuestionSingleSelect ?? "", categoryLifeArea: Realm.getLifeArea(forCategory: answeredQuestion.category) )
                    
                }
                
            }
        }
    }
}
