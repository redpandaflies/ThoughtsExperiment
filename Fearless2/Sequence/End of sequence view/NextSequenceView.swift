//
//  NextSequenceView.swift
//  Fearless2
//
//  Created by Yue Deng-Wu on 4/7/25.
//
import Mixpanel
import SwiftUI

struct NextSequenceView: View {
    @EnvironmentObject var dataController: DataController
    @StateObject var sequenceViewModel: SequenceViewModel
    @StateObject var newCategoryViewModel: NewCategoryViewModel
    // Manage when to show alert for exiting flow
    @State private var showExitFlowAlert: Bool = false
    @State private var selectedTab: Int = 0
    @State private var animationStage: Int = 0 //manages animation on celebration view, ensures that button is disabled until animation is complete
    
    // recap
    @State private var recapScrollPosition: Int?
    
    //for managing the questions
    @State private var selectedQuestion: Int = 0
    @State private var answersOpen: [String]
    @State private var answersSingleSelect: [String]
    @State private var answersMultiSelect: [[String]]
    @State private var multiSelectCustomItems: [[String]]
    @State private var multiSelectOptionsEdited: [Bool]
    
    @Binding var showNextSequenceView: Bool
    @Binding var animatedGoalIDs: Set<UUID>
    
    let goal: Goal
    let sequence: Sequence
    let topic: Topic?
    let backgroundColor: Color
    
    
    let questions: [QuestionNextSequence] = QuestionNextSequence.questions
    @FocusState var focusField: DefaultFocusField?
    
    init(
        sequenceViewModel: SequenceViewModel,
        newCategoryViewModel: NewCategoryViewModel,
        goal: Goal,
        sequence: Sequence,
        topic: Topic?,
        backgroundColor: Color,
        showNextSequenceView: Binding<Bool>,
        animatedGoalIDs: Binding<Set<UUID>>
    ) {
        let count = QuestionNextSequence.questions.count

        // intialize every state var for storing question answers in memory
        _answersOpen = State(initialValue: Array(repeating: "", count: count))
        _answersSingleSelect = State(initialValue: Array(repeating: "", count: count))
        _answersMultiSelect = State(initialValue: Array(repeating: [], count: count))
        _multiSelectCustomItems = State(initialValue: Array(repeating: [], count: count))
        _multiSelectOptionsEdited = State(initialValue: Array(repeating: false, count: count))
        
        self.goal = goal
        self.sequence = sequence
        self.topic = topic
        self.backgroundColor = backgroundColor
        self._showNextSequenceView = showNextSequenceView
        self._animatedGoalIDs = animatedGoalIDs
        
        _newCategoryViewModel = StateObject(wrappedValue: newCategoryViewModel)
        _sequenceViewModel = StateObject(wrappedValue: sequenceViewModel)
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                VStack (alignment: (selectedTab == 1) ? .leading : .center, spacing: 5) {
                    switch selectedTab {
                        case 0:
                        NextSequenceIntro(goal: goal)
                            .padding(.horizontal)
                            
                        case 1:
                        getRecapView()
                            .padding(.horizontal)
                               
                        case 2:
                        //Question view
                        NextSequenceQuestionsView(
                            selectedQuestion: $selectedQuestion,
                            answersOpen: $answersOpen,
                            answersSingleSelect: $answersSingleSelect,
                            answersMultiSelect: $answersMultiSelect,
                            multiSelectCustomItems: $multiSelectCustomItems,
                            multiSelectOptionsEdited: $multiSelectOptionsEdited,
                            questions: questions,
                            focusField: $focusField,
                            sequenceObjectives: sequence.sequenceObjectives,
                            keepExploringAction: {
                                navigateToNextQuestion()
                            },
                            resolveTopicAction: {
                                goToCelebrationView()
                            }
                        )
                        .padding(.horizontal)
                       
                        case 3:
                        RecapCelebrationView(
                            animationStage: $animationStage,
                            title: goal.goalTitle,
                            text: "For resolving",
                            points: "+10"
                        )
                            .padding(.top, 100)
                            .padding(.horizontal)
                        
                        default:
                        SequenceSuggestionsView (
                            newCategoryViewModel: newCategoryViewModel,
                            showSheet: $showNextSequenceView,
                            completeSequenceAction: {
                                completeSequence()
                            }
                        )
                       
                    }
                }//VStack
                .padding(.top, 30)
                .frame(maxHeight: .infinity, alignment: .top)
                
                VStack {
                  
                    if selectedTab < 4 && !(selectedTab == 2 && selectedQuestion == 2) {
                        RectangleButtonPrimary(
                            buttonText: getButtonText(),
                            action: {
                                buttonAction()
                            },
                            disableMainButton: disableButton(),
                            buttonColor: .white
                        )
                        .padding(.bottom, 10)
                        .padding(.horizontal)
                        .ignoresSafeArea(getSafeAreaProperty())
                    }
                }
                .frame(maxHeight: .infinity, alignment: .bottom)
                
            }//VStack
            .background {
                BackgroundPrimary(backgroundColor: backgroundColor)
                
            }
            .onAppear {
                getSequenceRecap()
            }
            .alert("Exit retrospective?", isPresented: $showExitFlowAlert) {
                Button("Keep going", role: .cancel) {}
                Button("Exit", role: .destructive) {
                    exitFlow()
                }
            } message: {
                Text("You'll lose your progress on this step.")
            }
            .toolbar {
               
                ToolbarItem(placement: .principal) {
                    ToolbarTitleItem2(title: selectedTab == 0 ? "Recap" : goal.goalTitle)
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    XmarkToolbarItem(action: {
                        if selectedTab < 2 || selectedTab == 3 {
                            showNextSequenceView = false
                        } else if selectedQuestion > 0 {
                            showExitFlowAlert = true
                        } else {
                            showNextSequenceView = false
                        }
                    })
                }
                
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackgroundVisibility(.hidden)
            
        }//NavigationStack
    }
    
    private func getRecapView() -> some View {
        VStack (alignment: .leading, spacing: 25){
            Text("What you uncovered")
                .multilineTextAlignment(.leading)
                .font(.system(size: 25, design: .serif))
                .foregroundStyle(AppColors.textPrimary)
            
            NextSequenceRecap(
                sequenceViewModel: sequenceViewModel,
                recapScrollPosition: $recapScrollPosition,
                summaries: sequence.sequenceSummaries,
                retryAction: {
                    createSummary()
                }
            )
        }
    }
    
    private func buttonAction() {
        switch selectedTab {
        case 1:
            if sequence.sequenceStatus == SequenceStatusItem.completed.rawValue {
                showNextSequenceView = false
            } else {
                selectedTab += 1
            }
        case 2:
            manageQuestionFlow()
        case 3:
            completeGoal()
            
        default:
            selectedTab += 1
        }
        
    }
    
    private func disableButton() -> Bool {
        switch selectedTab {
        case 1:
            if sequenceViewModel.createSequenceSummary == .loading {
                return true
            } else if recapScrollPosition == sequence.sequenceSummaries.count - 1 {
                return false
            } else {
                return true
            }
        case 2:
           return disableButtonQuestions()
            
        case 3:
            return animationStage < 2
        default:
            return false
        }
    }
    
    private func disableButtonQuestions() -> Bool {
       
        switch questions[selectedQuestion].questionType {
        case .open:
            return answersOpen[selectedQuestion].isEmpty
        case .singleSelect:
            return answersSingleSelect[selectedQuestion].isEmpty
        case .multiSelect:
            return answersMultiSelect[selectedQuestion].isEmpty
        }

    }
    
    private func getButtonText() -> String {
        switch selectedTab {
            case 0:
                return "Get started"
            case 1:
               return getButtonTextRecapView()
            case 2:
                return "Next"
            default:
                return "Done"
        }
    }
    
    private func getButtonTextRecapView() -> String {
        switch sequenceViewModel.createSequenceSummary {
        case .ready:
            return "Continue"
        case .loading:
            return "Loading . . ."
        case .retry:
            return "Retry"
        }
    }
    
    private func getSafeAreaProperty() ->  SafeAreaRegions {
        if questions.isEmpty {
            return []
        } else if questions[selectedQuestion].questionType != .open {
            return .keyboard
        }
        
        return []
    }
    
    private func getSequenceRecap() {
        if sequence.sequenceStatus == SequenceStatusItem.completed.rawValue {
            selectedTab = 1
        }
        
        if sequence.sequenceSummaries.isEmpty {
            createSummary()
        }
        
    }
    
    private func createSummary() {
        sequenceViewModel.createSequenceSummary = .loading
        
        Task {
            // update topic status to active
            if let topicId = topic?.topicId {
                await dataController.updateTopicStatus(id: topicId, item: .active)
            }
            
            // get sequence summary
            do {
                try await sequenceViewModel.manageRun(selectedAssistant: .sequenceSummary, category: goal.category, goal: goal, sequence: sequence)
                
            } catch {
                sequenceViewModel.createSequenceSummary = .retry
            }
            
        }
        
    }
    
    private func createPlanSuggestions(category: Category, goal: Goal) {
        Task {
            do {
                try await newCategoryViewModel.manageRun(selectedAssistant: .planSuggestion, category: category, goal: goal, sequence: sequence)
                
            } catch {
                newCategoryViewModel.createPlanSuggestions = .retry
            }
        }
    }
    
    private func manageQuestionFlow() {
//        let answeredQuestionIndex = selectedQuestion
        
        if selectedQuestion < 2 {
            //update focus state
            if focusField != nil {
                focusField = nil
            }
            
            //go to next question
            navigateToNextQuestion()
        }
        
        if selectedQuestion == 3 {
            //update focus state
            if focusField != nil {
                focusField = nil
            }
            selectedTab = 4
            saveAnswers()
          
            if let category = goal.category {
              createPlanSuggestions(category: category, goal: goal)
            }
            
        }
        
    }
    
    private func navigateToNextQuestion() {
        selectedQuestion += 1
        
        DispatchQueue.global(qos: .background).async {
            Mixpanel.mainInstance().track(event: "Retro decision: topic resolved")
        }
    }
    
   
    private func saveAnswers() {
        
        Task {
            for (index, answer) in answersOpen.enumerated() where !answer.isEmpty {
                
                await dataController.saveAnswerDefaultQuestions(
                    questionType: .open,
                    question: questions[index],
                    userAnswer: answer,
                    sequence: sequence
                )
                
                if index == 3 {
                    DispatchQueue.global(qos: .background).async {
                        Mixpanel.mainInstance().track(event: "Ask for next plan: \(answer)")
                    }
                }
                
            }
            
            for (index, answer) in answersMultiSelect.enumerated() where !answer.isEmpty {
                
                await dataController.saveAnswerDefaultQuestions(
                    questionType: .multiSelect,
                    question: questions[index],
                    userAnswer: answer,
                    sequence: sequence
                )
                
                if index == 1 {
                    for item in answer {
                        let shortDescription = MixpanelDetailedEvents.sequenceRetro[item] ?? ""
                        
                        DispatchQueue.global(qos: .background).async {
                            Mixpanel.mainInstance().track(event: "Plan outcome: \(shortDescription)")
                        }
                        
                    }
                    
                }
                
            }
        }
        
    }
    
    
    private func goToCelebrationView() {
        selectedTab += 1
        
        saveAnswers()
        completeSequence()
        
        DispatchQueue.global(qos: .background).async {
            Mixpanel.mainInstance().track(event: "Retro decision: keep exploring topic")
        }
    }
    
    private func completeSequence() {
       
        Task {
            
            //mark sequence as complete
            if let topic = topic {
                await dataController.completeTopic(topic: topic, sequence: sequence)
            }
            
           // update points
            await dataController.updatePoints(newPoints: 10)
        }
    }
    
    private func completeGoal() {
        //close sheet
        showNextSequenceView = false
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            
            withAnimation {
                _ = animatedGoalIDs.remove(goal.goalId)
            }
            
            Task {
                await dataController.changeGoalStatus(goal: goal, newStatus: .completed)
            }
        }
        
    }
    
    private func exitFlow() {
        //close sheet
        showNextSequenceView = false
       
        
        if selectedTab > 2 {
            Task {
                await dataController.deleteSequenceEndQuestions(sequence: sequence)
                
            }
        }
    }
}

