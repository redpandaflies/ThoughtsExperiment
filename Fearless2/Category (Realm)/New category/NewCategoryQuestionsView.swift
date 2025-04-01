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
    @State private var answerSingleSelect: String = ""
    
    @State private var questions: [QuestionsNewCategory] = []
    // Array to store all open question answers
    @State private var answersOpen: [String] = Array(repeating: "", count: 3)
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
    
    @FocusState var focusField: NewCategoryFocusField?
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
                
                    NewCategoryQuestionOpenView(
                        topicText: $answersOpen[selectedQuestion],
                        focusField: $focusField,
                        focusValue: .question(selectedQuestion),
                        question: currentQuestion.content,
                        placeholderText: "For best results, be very specific."
                    )
       
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
                
                Image(Realm.getIcon(forLifeArea: selectedCategory))
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 19)
                
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
            return answersOpen[selectedQuestion].isEmpty
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
               await saveAnswersForCategory()
            }
        }
        
        //navigate to next view
        handleUIAndNavigation(answeredQuestionIndex: answeredQuestionIndex)
       
       
    }
    
    private func exitCreateNewCategory() {
        if focusField != nil {
            focusField = nil
        }
        currentAppView = 1
        
    }
    
    private func saveAnswersForCategory() async {

        // Create the category
        let savedCategory = await dataController.createSingleCategory(lifeArea: selectedCategory)
        
        if let category = savedCategory {
            
            for (index, answer) in answersOpen.enumerated() where !answer.isEmpty {
                // Skip the single-select question (index 1)
                if index > 0 {
                    await dataController.saveAnswerOnboarding(
                        questionType: .open,
                        question: questions[index],
                        userAnswer: answer,
                        categoryLifeArea: selectedCategory,
                        category: category
                    )
                }
            }
            
            //create first set of topics for the realm based on a quest map
            await dataController.createTopics(questMap: QuestMapItem.questMap1, category: category)
            
        }
    }
    
    private func handleUIAndNavigation(answeredQuestionIndex index: Int) {
        if index < 2 {
            navigateToNextQuestion()
            updateFocusState(answeredQuestionIndex: index)
        } else {
            finishOnboarding()
        }
    }

   

    private func navigateToNextQuestion() {
        selectedQuestion += 1
        withAnimation(.interpolatingSpring) {
            progressBarQuestionIndex += 1
        }
    }

    private func updateFocusState(answeredQuestionIndex index: Int) {
        if index == 1 {
            focusField = .question(index + 1)
        }
    }

    private func finishOnboarding() {
        focusField = nil
        
        dismiss()
        
        withAnimation {
            selectedIntroPage += 1
        }
    }
    
    // MARK: - Handle the back button action
    
    private func handleBackButton() {
        let answeredQuestionIndex = selectedQuestion
        
        if answeredQuestionIndex > 0 {
            // Go back one question
            navigateToPreviousQuestion()
        }
    }
    
    
    private func navigateToPreviousQuestion() {
        
        focusField = nil
        selectedQuestion -= 1
        withAnimation(.interpolatingSpring) {
            progressBarQuestionIndex -= 1
        }
    }

}

//#Preview {
//    NewCategoryQuestionsView()
//}
