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
    @ObservedObject var topicViewModel: TopicViewModel
    
    @State private var mainSelectedTab: Int = 0
    @State private var animationStage: Int = 0
    
    //State vars that retain user's answers in memory
    @State private var selectedQuestion: Int = 0
    @State private var progressBarQuestionIndex: Int = 0
    @State private var questions: [QuestionNewCategory] = QuestionNewCategory.initialQuestionsNewCategory()
    // Array to store all open question answers
    @State private var answersOpen: [String] = Array(repeating: "", count: 6)
    // Array to store all single-select question answers
    @State private var answersSingleSelect: [String] = Array(repeating: "", count: 6)
    @State private var multiSelectAnswers: [[String]] = Array(repeating: [], count: 6)
    @State private var multiSelectCustomItems: [[String]] = Array(repeating: [], count: 6)
    
    // Manage when to show alert for exiting create new category flow
    @State private var showExitFlowAlert: Bool = false
    // Hide progress bar when user is inputing answers for single and multi-select questions
    @State private var showProgressBar: Bool = true
    
    // expectations
    @State private var expectationsScrollPosition: Int?
    @State private var disableButtonExpectations: Bool = true
    
    // plan suggestions view
    @State private var selectedTabPlan: Int = 0
    
    @Binding var showNewGoalSheet: Bool
   
    let backgroundColor: Color
    let isOnboarding: Bool
        
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
            if mainSelectedTab == 0 && showProgressBar {
                
                QuestionsProgressBar(
                    currentQuestionIndex: $progressBarQuestionIndex,
                    totalQuestions: 6,
                    showXmark: true,
                    xmarkAction: {
                        manageDismissButtonAction()
                    },
                    showBackButton: selectedQuestion > 0,
                    backAction: handleBackButton
                )
                
               
            } else {
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
                        showProgressBar: $showProgressBar,
                        mainSelectedTab: $mainSelectedTab,
                        selectedQuestion: $selectedQuestion,
                        questions: $questions,
                        answersOpen: $answersOpen,
                        answersSingleSelect: $answersSingleSelect,
                        multiSelectAnswers: $multiSelectAnswers,
                        multiSelectCustomItems: $multiSelectCustomItems,
                        focusField: $focusField
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
    
                case 2:
                    NewGoalExpectationsView(
                        expectationsScrollPosition: $expectationsScrollPosition
                    )
                
                default:
                    SequenceSuggestionsView (
                        topicViewModel: topicViewModel,
                        viewModel: newGoalViewModel,
                        planSelectedTab: $selectedTabPlan,
                        showSheet: $showNewGoalSheet,
                        showExitFlowAlert: $showExitFlowAlert,
                        retryAction: {
                            retryActionPlans()
                        }
                    )
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .background {
            BackgroundPrimary(backgroundColor: backgroundColor)
        }
        .overlay {
            if mainSelectedTab == 0 || mainSelectedTab == 2 {
                getViewButton()
            }
        }
        .onChange(of: expectationsScrollPosition) {
            if (expectationsScrollPosition == NewGoalExpectation.expectations.count - 1) {
                if disableButtonExpectations {
                    disableButtonExpectations = false
                }
            }
        }
        .alert("Discard new topic?", isPresented: $showExitFlowAlert) {
            Button("Cancel", role: .cancel) {}
            Button("Yes", role: .destructive) {
                if focusField != nil {
                    focusField = nil
                }
                exitFlowAction()
            }
        } message: {
            Text("You'll lose your progress.")
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
                    buttonText: mainSelectedTab == 0 ? "Continue" : "Reveal my paths",
                    action: {
                        mainSelectedTab == 0 ? nextButtonAction() : (mainSelectedTab += 1)
                    },
                    disableMainButton: mainSelectedTab == 0 ? disableButtonQuestions() : disableButtonExpectations,
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
    
    private func disableButtonQuestions() -> Bool {
        switch currentQuestion.questionType {
        case .open:
            return answersOpen[selectedQuestion].isEmpty && selectedQuestion != 3
        case .multiSelect:
            if selectedQuestion == 5 {
                return multiSelectAnswers[selectedQuestion].count < 2
            }
            
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
                    questions.removeLast(min(5, questions.count))
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
               await saveAnswersPart1()

            }
        }
        
        if answeredQuestionIndex == 5 {
            Task {
                await saveAnswersPart2()
            }
        }
        
       sendMixpanelEvents(
        answeredQuestionIndex: answeredQuestionIndex
       )
        
        
    }
    
    private func saveAnswersPart1() async {

        // Create the category
        let savedCategory = await dataController.createSingleCategory()
        
        // Create new goal
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
                userAnswer: multiSelectAnswers[4],
                category: category,
                goal: goal
            )
            
            await manageRun(category: category, goal: goal)
            
        }
    }
    
    private func saveAnswersPart2() async {
        
        if let category = newGoalViewModel.currentCategory, let goal = newGoalViewModel.currentGoal {
            await dataController.saveAnswerDefaultQuestions (
                questionType: .multiSelect,
                question: questions[5],
                userAnswer: multiSelectAnswers[5],
                category: category,
                goal: goal
            )
            await manageRunPlanSuggestion(category: category, goal: goal)
        }
        
    }
    
    private func handleUIAndNavigation(answeredQuestionIndex index: Int) {
        if index < questions.count - 2 {
            navigateToNextQuestion()
            updateFocusState(for: index)
        } else if index == questions.count - 2 {
            print("selectedQuestion =", selectedQuestion,
                  "questions.count =", questions.count,
                  "answersOpen.count =", answersOpen.count,
                  "answersSingleSelect.count =", answersSingleSelect.count)
            
            finishQuestionsPart1()
        } else {
            finishQuestionsPart2()
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

    private func finishQuestionsPart1() {
//        if focusField != nil {
//            focusField = nil
//        }
        mainSelectedTab = 1
    }
    
    private func finishQuestionsPart2() {
//        if focusField != nil {
//            focusField = nil
//        }
        withAnimation(.interpolatingSpring) {
            progressBarQuestionIndex += 1
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            if isOnboarding {
                mainSelectedTab = 2
            } else {
                mainSelectedTab = 3
            }
        }
    }
    
    private func manageRun(category: Category, goal: Goal) async {
        
        Task {
            do {
                // get reflection, goal title and description, options for last question
                try await newGoalViewModel.manageRun (
                    selectedAssistant: .newGoal,
                    category: category,
                    goal: goal
                )
                
            } catch {
                await MainActor.run {
                    newGoalViewModel.createNewCategorySummary = .retry
                }
            }
            
        }
        
    }
    
    private func manageRunPlanSuggestion(category: Category, goal: Goal) async {
        
        Task {
            do {
                try await newGoalViewModel.manageRun(selectedAssistant: .planSuggestion, category: category, goal: goal)
                
            } catch {
                await MainActor.run {
                    newGoalViewModel.createPlanSuggestions = .retry
                }
            }
            
        }
        
    }
    
    private func retryActionPlans() {
        selectedTabPlan = 0
        // reset var for managing when loading animation
       newGoalViewModel.completedLoadingAnimationPlan = false
        
        if let category = newGoalViewModel.currentCategory, let goal = newGoalViewModel.currentGoal {
            Task {
                await manageRunPlanSuggestion(category: category, goal: goal)
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
            let userAnswer = multiSelectAnswers[4]
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
    
    // MARK: - Exit flow
    private func manageDismissButtonAction() {
        if !answersOpen[1].isEmpty {
            showExitFlowAlert = true
        } else {
            if focusField != nil {
                focusField = nil
            }
            
            exitFlowAction()
        }
        
        DispatchQueue.global(qos: .background).async {
            Mixpanel.mainInstance().track(event: "Closed new topic flow")
        }
    }
    
    private func exitFlowAction() {
        //dismiss
        topicViewModel.currentGoal = nil
        showNewGoalSheet = false
        
        Task {
            
            await dataController.deleteIncompleteGoals()
            
            try await newGoalViewModel.cancelCurrentRun()
            
            DispatchQueue.global(qos: .background).async {
                Mixpanel.mainInstance().track(event: "Closed new topic flow")
            }
        }
    }
    
    // MARK: - Handle the back button action for questions
    private func handleBackButton() {
        let answeredQuestionIndex = selectedQuestion
        
        if answeredQuestionIndex > 0 && answeredQuestionIndex < 5 {
            // Go back one question
            navigateToPreviousQuestion()
        } else if answeredQuestionIndex == 5 {
            mainSelectedTab = 1
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
            
        case 3:
            return "Choose a direction"
            
        default:
           return ""
        }
        
    }
    
}
