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
    @State private var answerOpenQ1: String = ""
    @State private var answerOpenQ2: String = ""
    @State private var answerSingleSelect: String = ""
    
    @State private var questions: [QuestionsNewCategory] = []
    // Track answers for each question
    @State private var savedAnswers: [Int: String] = [:]
    // Manage when to show alert for exiting create new category flow
    @State private var showExitFlowAlert: Bool = false
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
    @AppStorage("currentAppView") var currentAppView: Int = 0
    
    var body: some View {
        VStack (spacing: 10){
            // MARK: Header
            QuestionsProgressBar(
                currentQuestionIndex: $progressBarQuestionIndex,
                totalQuestions: 3,
                showXmark: true,
                xmarkAction: {
                    showExitFlowAlert = true
                },
                showBackButton: selectedQuestion > 0,
                backAction: handleBackButton
            )
                
            // MARK: Title
            getTitle()
               
            // MARK: Question
            switch currentQuestion.questionType {
                case .open:
                        QuestionOpenView(topicText: selectedQuestion == 2 ? $answerOpenQ2 : $answerOpenQ1,
                                 isFocused: $isFocused,
                                 question: currentQuestion.content,
                                 placeholderText: "For best results, be very specific.")
                      
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
            
        }//VStack
        .padding(.horizontal)
        .padding(.bottom)
        .background {
            BackgroundPrimary(backgroundColor: AppColors.backgroundOnboardingIntro)
        }
        .alert("Are you sure you exit?", isPresented: $showExitFlowAlert) {
            Button("Cancel", role: .cancel) {}
            Button("Yes", role: .destructive) {
                exitCreateNewCategory()
            }
        } message: {
            Text("You'll lose your progress towards unlocking a new realm.")
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
            return selectedQuestion == 2 ? answerOpenQ2.isEmpty : answerOpenQ1.isEmpty
        default:
            if selectedQuestion == 0 {
                return selectedCategory.isEmpty
            } else {
                return answerSingleSelect.isEmpty
            }
        }
    }
    
    // Handle the back button action
    private func handleBackButton() {
        let answeredQuestionIndex = selectedQuestion
        
        if answeredQuestionIndex > 0 {
            // Save current answer before going back
            saveCurrentAnswer(index: answeredQuestionIndex)
            
            // Go back one question
            if isFocused {
                isFocused = false
            }
            selectedQuestion -= 1
            withAnimation(.interpolatingSpring) {
                progressBarQuestionIndex -= 1
            }
            
            // Restore previous answer
            restorePreviousAnswer()
        }
    }
    
    // Save the current answer to our in-memory dictionary
    private func saveCurrentAnswer(index: Int) {
        switch currentQuestion.questionType {
        case .open:
            if selectedQuestion == 2 {
                savedAnswers[index] = answerOpenQ2
            } else {
                savedAnswers[index] = answerOpenQ1
            }
        case .singleSelect, .multiSelect:
            if selectedQuestion == 0 {
                savedAnswers[index] = selectedCategory
            } else {
                savedAnswers[index] = answerSingleSelect
            }
        }
    }
    
    // Restore a previously saved answer
    private func restorePreviousAnswer() {
        // Get the answer for the current question (after moving back)
        if let savedAnswer = savedAnswers[selectedQuestion] {
            switch questions[selectedQuestion].questionType {
            case .open:
                if selectedQuestion == 2 {
                    answerOpenQ2 = savedAnswer
                } else {
                    answerOpenQ1 = savedAnswer
                }
            case .singleSelect, .multiSelect:
                if selectedQuestion == 0 {
                    selectedCategory = savedAnswer
                } else {
                    answerSingleSelect = savedAnswer
                }
            }
        }
    }
    
    
    private func nextButtonAction() {
        //capture current state
        let answeredQuestionIndex = selectedQuestion
        
        // Save the current answer to in-memory dictionary
        saveCurrentAnswer(index: answeredQuestionIndex)
        
        switch answeredQuestionIndex {
        case 0:
            let categoryQuestions = QuestionsNewCategory.initialQuestionNewCategory(from: categories)
            
            questions = categoryQuestions
            
        default:
            break
        }
        
        //Save question answer to coredata on the last question
        if answeredQuestionIndex == 2 {
            Task {
                // Create the category
                let savedCategory = await dataController.createSingleCategory(lifeArea: selectedCategory)
                
                
                // Then save all other answers
                for (key, value) in savedAnswers where key > 0 {
                    
                    if let category = savedCategory {
                        await dataController.saveAnswerOnboarding(
                            questionType: .open,
                            question: questions[key],
                            userAnswer: value,
                            categoryLifeArea: selectedCategory,
                            category: category
                        )
                    }
                }
            }
        }
        
        if selectedQuestion < 2 {
            answerOpenQ1 = ""
            answerOpenQ2 = ""
            
            //navigate to the next question
            selectedQuestion += 1
            withAnimation(.interpolatingSpring) {
                progressBarQuestionIndex += 1
            }
            restorePreviousAnswer()
            
            if selectedQuestion == 1 {
                isFocused = true
            }
            
        } else {
            if isFocused {
                isFocused = false
            }
            
            dismiss()
            
            withAnimation {
                selectedIntroPage += 1
            }
            
        }
       
       
    }
    
    private func exitCreateNewCategory() {
        if isFocused {
            isFocused = false
        }
        
        currentAppView = 1
        
    }
}

//#Preview {
//    NewCategoryQuestionsView()
//}
