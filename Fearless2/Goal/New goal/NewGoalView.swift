//
//  NewGoalView.swift
//  Fearless2
//
//  Created by Yue Deng-Wu on 2/24/25.
//
import CoreData
import Mixpanel
import SwiftUI

struct NewGoalView: View {
    @EnvironmentObject var dataController: DataController
    @StateObject var newGoalViewModel: NewGoalViewModel
    @State private var mainSelectedTab: Int = 0
    @State private var animationStage: Int = 0
    
    //State vars that retain user's answers in memory
    @State private var selectedQuestion: Int = 0
    @State private var progressBarQuestionIndex: Int = 0
    @State private var questions: [QuestionNewCategory] = QuestionNewCategory.initialQuestionsNewCategory()
    // Array to store all open question answers
    @State private var answersOpen: [String] = Array(repeating: "", count: 5)
    // Array to store all single-select question answers
    @State private var answersSingleSelect: [String] = Array(repeating: "", count: 5)
    @State private var multiSelectAnswers: [String] = []
    @State private var multiSelectCustomItems: [String] = []
    
    @Binding var showNewGoalSheet: Bool
    
    let backgroundColor: Color
        
    var currentQuestion: QuestionNewCategory {
        guard selectedQuestion < questions.count else {
            return QuestionNewCategory.defaultQuestion()
        }
        
        return questions[selectedQuestion]
    }
    
    @FocusState var focusField: DefaultFocusField?


    var body: some View {
        
        VStack (spacing: 10) {
            
            // MARK: - Header
            if mainSelectedTab > 0 {
                NewCategoryHeader(
                    mainSelectedTab: $mainSelectedTab,
                    xmarkAction: {
                        exitFlowAction()
                    }
                )
            }
            
            // MARK: - View Content
            switch mainSelectedTab {
                case 0:
                    NewGoalQuestionsView (
                        newGoalViewModel: newGoalViewModel,
                        mainSelectedTab: $mainSelectedTab,
                        selectedQuestion: $selectedQuestion,
                        progressBarQuestionIndex: $progressBarQuestionIndex,
                        questions: $questions,
                        answersOpen: $answersOpen,
                        answersSingleSelect: $answersSingleSelect,
                        multiSelectAnswers: $multiSelectAnswers,
                        multiSelectCustomItems: $multiSelectCustomItems,
                        focusField: $focusField,
                        exitFlowAction: {
                            exitFlowAction()
                        }
                    )
                    .padding(.horizontal)
                
                case 1:
                    NewGoalReflectionView (
                        newGoalViewModel: newGoalViewModel,
                        mainSelectedTab: $mainSelectedTab,
                        selectedQuestion: $selectedQuestion,
                        progressBarQuestionIndex: $progressBarQuestionIndex
                    )
                    .padding(.horizontal)
    
                default:
                    SequenceSuggestionsView (
                        newGoalViewModel: newGoalViewModel,
                        showSheet: $showNewGoalSheet
                    )
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .background {
            BackgroundPrimary(backgroundColor: backgroundColor)
        }
        .overlay {
            if mainSelectedTab == 0 {
                getViewButton()
            }
        }
     
    }
  
    private func getViewButton() -> some View {
        VStack (alignment: .leading) {
            if answersSingleSelect[0].isEmpty  {
                SampleGoalsView(
                    showSymbol: true,
                    onTapAction: { selectedGoal in
                        answersSingleSelect[selectedQuestion] = selectedGoal
                })
                .padding(.horizontal, 30)
                
            } else {
                //Next button
                RectangleButtonPrimary(
                    buttonText: "Continue",
                    action: {
                        nextButtonAction()
                    },
                    disableMainButton: disableButton(),
                    buttonColor: .white)
                .padding(.horizontal)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomLeading)
        .padding(.bottom)
        .ignoresSafeArea(getSafeAreaProperty())
    }
    
    private func getSafeAreaProperty() ->  SafeAreaRegions {
        if questions.isEmpty {
            return []
        } else if currentQuestion.questionType != .open {
            return .keyboard
        }
        
        return []
    }
    
    private func disableButton() -> Bool {
      
        switch currentQuestion.questionType {
        case .open:
            return answersOpen[selectedQuestion].isEmpty && selectedQuestion != 3
            
        case .multiSelect:
            return false
        default:
            return answersSingleSelect[selectedQuestion].isEmpty
            
        }
    }
    
    private func nextButtonAction() {
        //capture current state
        let answeredQuestionIndex = selectedQuestion
        
        switch answeredQuestionIndex {
        case 0:
            let remainingQuestions = QuestionNewCategory.remainingQuestionsNewCategory(userAnswer: answersSingleSelect[answeredQuestionIndex])
            
            if questions.count > 1 {
                if questions[1].content != GoalTypeItem.question(forLongName: answersSingleSelect[answeredQuestionIndex]) {
                    questions.removeLast(min(4, questions.count))
                    questions += remainingQuestions
                }
            } else {
                questions += remainingQuestions
            }

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
        
       sendMixpanelEvents(
        answeredQuestionIndex: answeredQuestionIndex
       )
        
        
    }
    
    private func saveAnswersForCategory() async {

        // Create the category
        let savedCategory = await dataController.createSingleCategory()
        //Create new goal
        /// need to make sure questions are related to the right goal when saved
        
        let savedGoal = await dataController.createNewGoal(category: savedCategory, problemType: answersSingleSelect[0])
        
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
            
            // save last question (the only multi-select)
            await dataController.saveAnswerDefaultQuestions(
                questionType: .multiSelect,
                question: questions[4],
                userAnswer: multiSelectAnswers,
                category: category,
                goal: goal
            )
            
            await manageRun(category: category, goal: goal)
            
        }
    }
    
    private func handleUIAndNavigation(answeredQuestionIndex index: Int) {
        if index < questions.count - 1{
            navigateToNextQuestion()
            updateFocusState(for: index)
        } else {
            print("selectedQuestion =", selectedQuestion,
                  "questions.count =", questions.count,
                  "answersOpen.count =", answersOpen.count,
                  "answersSingleSelect.count =", answersSingleSelect.count)
            
            finishQuestions()
        }
    }

   

    private func navigateToNextQuestion() {
        if focusField != nil {
            focusField = nil
        }
        selectedQuestion += 1
        withAnimation(.interpolatingSpring) {
            progressBarQuestionIndex += 1
        }
    }

    private func updateFocusState(for index: Int) {
        if currentQuestion.questionType == .open {
            focusField = .question(index + 1)
        }
    }

    private func finishQuestions() {
//        if focusField != nil {
//            focusField = nil
//        }
        mainSelectedTab = 1
     
    }
    
    
    private func manageRun(category: Category, goal: Goal) async {
        
        Task {
            do {
                try await newGoalViewModel.manageRun (
                    selectedAssistant: .newGoal,
                    category: category,
                    goal: goal
                )
                
            } catch {
                newGoalViewModel.createNewCategorySummary = .retry
            }
            
            do {
                try await newGoalViewModel.manageRun (
                    selectedAssistant: .planSuggestion,
                    category: category,
                    goal: goal
                )
                
            } catch {
                newGoalViewModel.createPlanSuggestions = .retry
            }
            
        }
        
    }

    private func exitFlowAction() {
        
        Task {
            await newGoalViewModel.cancelCurrentRun()
            
            await MainActor.run {
                //dismiss
                dataController.createdNewGoal = false
                showNewGoalSheet = false
            }
            
            await dataController.deleteIncompleteGoals()
            
            DispatchQueue.global(qos: .background).async {
                Mixpanel.mainInstance().track(event: "Closed new topic flow")
            }
        }
    }
    
    private func sendMixpanelEvents(answeredQuestionIndex: Int) {
        switch answeredQuestionIndex {
        case 0:
            let userAnswer = answersSingleSelect[answeredQuestionIndex]
            let goalType = GoalTypeItem.fromLongName(userAnswer).rawValue
            print("Goal type: \(goalType)")
            DispatchQueue.global(qos: .background).async {
                Mixpanel.mainInstance().track(event: "Topic type: \(goalType)")
            }
        
        case 2:
            let userAnswer = answersSingleSelect[answeredQuestionIndex]
            let timespan = MixpanelDetailedEvents.problemRecency[userAnswer] ?? "Unknown"
            DispatchQueue.global(qos: .background).async {
                Mixpanel.mainInstance().track(event: "Topic recency: \(timespan)")
            }
            
        case 4:
            let userAnswer = multiSelectAnswers
            for answer in userAnswer {
                let shortAnswer = MixpanelDetailedEvents.userAsk[answer] ?? "\(answer)"
                DispatchQueue.global(qos: .background).async {
                    Mixpanel.mainInstance().track(event: "User ask: \(shortAnswer)")
                }
            }
            
        default:
            break
            
        }
        
    }
    
    
}


struct NewCategoryHeader: View {
    @Binding var mainSelectedTab: Int
    let xmarkAction: () -> Void
    let screenWidth = UIScreen.current.bounds.width
    
    var body: some View {
        
        HStack (spacing: 0) {
            ToolbarTitleItem2(
                emoji: "",
                title: getToolBarText()
            )
            
            Button {
                xmarkAction()
            } label: {
                
                Image(systemName: "xmark.circle.fill")
                    .font(.system(size: 25))
                    .foregroundStyle(AppColors.progressBarPrimary.opacity(0.3))
            }
    
        }//HStack
        .frame(width: screenWidth - 32)
        .padding(.top)
        .padding(.bottom, 15)
    }
    
    private func getToolBarText() -> String {
        switch mainSelectedTab {
            
        case 1:
            return "Reflection"
            
        case 2:
            return "Choose a direction"
            
        default:
           return ""
        }
        
    }
    
}
