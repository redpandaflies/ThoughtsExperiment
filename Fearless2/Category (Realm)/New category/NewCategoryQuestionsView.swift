//
//  NewCategoryQuestionsView.swift
//  Fearless2
//
//  Created by Yue Deng-Wu on 3/5/25.
//

import SwiftUI

struct NewCategoryQuestionsView: View {
    @EnvironmentObject var dataController: DataController
    @ObservedObject var newCategoryViewModel: NewCategoryViewModel
    
    // Manage when to show alert for exiting create new category flow
    @State private var showExitFlowAlert: Bool = false
    
    @Binding var showNewGoalSheet: Bool
    @Binding var mainSelectedTab: Int
    @Binding var selectedCategory: String
    @Binding var selectedQuestion: Int
    @Binding  var progressBarQuestionIndex: Int
    @Binding var questions: [QuestionNewCategory]
    // Array to store all open question answers
    @Binding var answersOpen: [String]
    // Array to store all single-select question answers
    @Binding var answersSingleSelect: [String]
    @Binding var newGoalSaved: Bool
    
    var currentQuestion: QuestionNewCategory {
        return questions[selectedQuestion]
       
    }
    
    @FocusState var focusField: DefaultFocusField?
    
    var body: some View {
        VStack (spacing: 10){
            // MARK: Header
            QuestionsProgressBar(
                currentQuestionIndex: $progressBarQuestionIndex,
                totalQuestions: 5,
                showXmark: true,
                xmarkAction: {
                    showExitFlowAlert = true
                },
                showBackButton: selectedQuestion > 0,
                backAction: handleBackButton
            )
                
            // MARK: Title
            if selectedQuestion > 1 {
                getTitle()
            }
               
            // MARK: Question
            switch currentQuestion.questionType {
                case .open:
                    QuestionOpenView2(
                        topicText: $answersOpen[selectedQuestion],
                        focusField: $focusField,
                        focusValue: .question(selectedQuestion),
                        question: currentQuestion.content,
                        placeholderText: "For best results, be very specific."
                    )
       
                default:
                    if selectedQuestion == 0 {
                        NewCategorySelectCategoryQuestion(
                            selectedCategory: $selectedCategory,
                            question: currentQuestion.content,
                            items: currentQuestion.options ?? [])
                           
                    } else {
                        QuestionSingleSelectView(
                            singleSelectAnswer: $answersSingleSelect[selectedQuestion],
                            question: currentQuestion.content,
                            items: currentQuestion.options ?? [],
                            subTitle: selectedQuestion == 1 ? "Choose your primary goal" : "",
                            showSymbol: selectedQuestion == 1 ? true : false
                        )
                    }
            }

            Spacer()
            
            // MARK: Next button
            RectangleButtonPrimary(
                buttonText: "Continue",
                action: {
                nextButtonAction()
                },
                disableMainButton: disableButton(),
                buttonColor: .white)
            
        }//VStack
        .padding(.horizontal)
        .padding(.bottom)
        .alert("Are you sure you exit?", isPresented: $showExitFlowAlert) {
            Button("Cancel", role: .cancel) {}
            Button("Yes", role: .destructive) {
                exitCreateNewCategory()
            }
        } message: {
            Text("You'll lose your progress towards adding a new question.")
        }
    }
    
    private func getTitle() -> some View {
        HStack (spacing: 5){
            Text(selectedQuestion == 4 ? selectedCategory : answersSingleSelect[1])
                .font(.system(size: 19, weight: .light).smallCaps())
                .fontWidth(.condensed)
                .foregroundStyle(AppColors.textPrimary.opacity(0.7))
          
            
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
                return answersSingleSelect[selectedQuestion].isEmpty
            }
        }
    }
    
    private func nextButtonAction() {
        //capture current state
        let answeredQuestionIndex = selectedQuestion
        
        switch answeredQuestionIndex {
        case 1:
            
            
            let remainingQuestions = QuestionNewCategory.remainingQuestionsNewCategory(userAnswer: answersSingleSelect[answeredQuestionIndex])
            
            questions += remainingQuestions
            
            print("questions: \(questions.count)")
            
        default:
            break
        }
        
        
        //navigate to next view
        handleUIAndNavigation(answeredQuestionIndex: answeredQuestionIndex)
        
        //Save question answer to coredata on the last question
        if answeredQuestionIndex == 4 {
            Task {
               await saveAnswersForCategory()
            }
        }
    }
    
    private func exitCreateNewCategory() {
        if focusField != nil {
            focusField = nil
        }
        showNewGoalSheet = false
    }
    
    private func saveAnswersForCategory() async {

        // Create the category
        let savedCategory = await dataController.createSingleCategory(lifeArea: selectedCategory)
        //Create new goal
        /// need to make sure questions are related to the right goal when saved
        let savedGoal = await dataController.createNewGoal(category: savedCategory, problemType: answersSingleSelect[1])
        
        if let category = savedCategory, let goal = savedGoal {

            for (index, answer) in answersOpen.enumerated() where !answer.isEmpty {
             
                await dataController.saveAnswerDefaultQuestions(
                    questionType: .open,
                    question: questions[index],
                    userAnswer: answer,
                    category: category,
                    goal: goal
                )
                
            }
            
            for (index, answer) in answersSingleSelect.enumerated() where !answer.isEmpty {
                   
                    await dataController.saveAnswerDefaultQuestions(
                        questionType: .singleSelect,
                        question: questions[index],
                        userAnswer: answer,
                        category: category,
                        goal: goal
                    )
                
            }
            
            await manageRun(category: category, goal: goal)
            
        }
    }
    
    private func handleUIAndNavigation(answeredQuestionIndex index: Int) {
        if index < 4 {
            navigateToNextQuestion()
            updateFocusState(answeredQuestionIndex: index)
        } else {
            finishQuestions()
        }
    }

   

    private func navigateToNextQuestion() {
        selectedQuestion += 1
        withAnimation(.interpolatingSpring) {
            progressBarQuestionIndex += 1
        }
    }

    private func updateFocusState(answeredQuestionIndex index: Int) {
        if index == 1 || index == 3 {
            focusField = nil
        } else {
            focusField = .question(index + 1)
        }
    }

    private func finishQuestions() {
        focusField = nil
        mainSelectedTab += 1
        if !newGoalSaved {
            newGoalSaved = true
        }
    }
    
    
    private func manageRun(category: Category, goal: Goal) async {
        
        Task {
            do {
                try await newCategoryViewModel.manageRun(selectedAssistant: .newCategory, category: category, goal: goal)
                
            } catch {
                newCategoryViewModel.createNewCategorySummary = .retry
            }
            
            do {
                try await newCategoryViewModel.manageRun(selectedAssistant: .planSuggestion, category: category, goal: goal)
                
            } catch {
                newCategoryViewModel.createPlanSuggestions = .retry
            }
            
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
