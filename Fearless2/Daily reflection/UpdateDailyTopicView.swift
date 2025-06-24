//
//  UpdateDailyTopicView.swift
//  Fearless2
//
//  Created by Yue Deng-Wu on 10/3/24.
//
import CoreData
import Mixpanel
import SwiftUI

struct UpdateDailyTopicView: View {
    @EnvironmentObject var dataController: DataController
    @ObservedObject var topicViewModel: TopicViewModel
    @ObservedObject var dailyTopicViewModel: DailyTopicViewModel
    @ObservedObject private var notificationManager = NotificationManager.shared
    
    @State private var showProgressBar: Bool = true //for hiding progress bar when user is typing their answer for single-select question
    @State private var selectedTab: Int = 0
    @State private var showExitFlowAlert: Bool = false
    
    /// questions view
    @State private var selectedTabQuestions: Int = 0
    @State private var selectedQuestion: Int = 0
    @State private var answersOpen: [String] = Array(repeating: "", count: 3) // open ended answer
    @State private var singleSelectAnswer: String = "" //single-select answer
    @State private var multiSelectAnswers: [String] = [] //answers user choose for muti-select questions
    @State private var currentQuestionIndex: Int = 0 //for the progress bar
    @State private var singleSelectCustomItems: [String] = []//stores updated array when user inputs their own answer for single select
    @State private var multiSelectCustomItems: [String] = []//stores updated array when user inputs their own answer for multi select
    @State private var animationStage: Int = 0 //manages animation on celebration view, ensures that button is disabled until animation is complete
    @State private var selectedTabTopicsList: Int = 0
    
    /// for expectations view
    @State private var expectationsScrollPosition: Int?
    @State private var disableButtonExpectations: Bool = true
    
    /// recap reflection view
    @State private var selectedTabRecap: Int = 0 //manage the UI changes when recap is ready
    
    /// for feedback view
    @State private var feedbackScrollPosition: Int?
    @State private var disableButtonFeedback: Bool = true
    
    /// plan suggestions view
    @State private var selectedTabPlan: Int = 0
    
    @Binding var showUpdateTopicView: Bool //dismiss sheet
    
    let topic: TopicDaily
    let hasTopicForTomorrow: Bool
    let backgroundColor: LinearGradient
    let retryActionQuestions: () -> Void
    
    @FetchRequest var questions: FetchedResults<Question>
    
    @FocusState var focusField: DefaultFocusField?
    
    var mainFlowQuestionsCount: Int {
        let totalQuestions = questions.count
        let staticQuestions = NewQuestion.questionsDailyTopic.count
        return max(totalQuestions - staticQuestions, 0)
    }
    
    init(
         topicViewModel: TopicViewModel,
         dailyTopicViewModel: DailyTopicViewModel,
         showUpdateTopicView: Binding<Bool>,
         topic: TopicDaily,
         hasTopicForTomorrow: Bool,
         backgroundColor: LinearGradient,
         retryActionQuestions: @escaping () -> Void
    ) {
        self.topicViewModel = topicViewModel
        self.dailyTopicViewModel = dailyTopicViewModel
        self._showUpdateTopicView = showUpdateTopicView
        self.topic = topic
        self.hasTopicForTomorrow = hasTopicForTomorrow
        self.backgroundColor = backgroundColor
        self.retryActionQuestions = retryActionQuestions
        
        let request: NSFetchRequest<Question> = Question.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: "questionNumber", ascending: true)]
        request.predicate = NSPredicate(format: "topicDaily == %@", topic)
        self._questions = FetchRequest(fetchRequest: request)
        
    }
    
    var body: some View {
        
        VStack {
            
            if selectedTab == 1 && showProgressBar && selectedTabQuestions == 1 && selectedQuestion < mainFlowQuestionsCount {
                //Header
                QuestionsProgressBar (
                    currentQuestionIndex: $currentQuestionIndex,
                    totalQuestions: mainFlowQuestionsCount,
                    showXmark: true,
                    xmarkAction: {
                        dismiss()
                    },
                    showBackButton: selectedQuestion > 0,
                    backAction: {
                        backButtonAction()
                    }
                )
                .transition(.opacity)
                
            } else if selectedTab != 1 || (selectedTab == 1 && selectedTabQuestions != 1) || (selectedTab == 1 && selectedQuestion >= mainFlowQuestionsCount) && showProgressBar {
                SheetHeader(
                    title: topic.topicTheme,
                    xmarkAction: {
                        if selectedTab > 1 && topic.topicStatus != TopicStatusItem.completed.rawValue {
                            showExitFlowAlert = true
                        } else {
                            dismiss()
                        }
                    }
                )
            }
            
            //Question
            switch selectedTab {
                case 0:
                    UpdateTopicCarouselView(
                        title: topic.topicTitle,
                        items:  topic.topicExpectations
                            .sorted { $0.orderIndex < $1.orderIndex },
                        scrollPosition: $expectationsScrollPosition,
                        extractContent: { $0.expectationContent })
                    
                case 1:
                    UpdateDailyTopicQuestionsView(
                        dailyTopicViewModel: dailyTopicViewModel,
                        selectedTabQuestions: $selectedTabQuestions,
                        showProgressBar: $showProgressBar,
                        selectedQuestion: $selectedQuestion,
                        answersOpen: $answersOpen,
                        singleSelectAnswer: $singleSelectAnswer,
                        multiSelectAnswers: $multiSelectAnswers,
                        singleSelectCustomItems: $singleSelectCustomItems,
                        multiSelectCustomItems: $multiSelectCustomItems,
                        topic: topic,
                        questions: questions,
                        mainFlowQuestionsCount: mainFlowQuestionsCount,
                        retryAction: {
                            retryActionQuestions()
                        },
                        focusField: $focusField)
                    
                case 2:
                    RecapCelebrationView (
                        animationStage: $animationStage,
                        title: topic.topicTitle,
                        text: "For completing",
                        points: "+1"
                    )
                    .padding(.horizontal)
                    .padding(.top, 80)
                    .onAppear {
                        if topic.topicFeedback.isEmpty {
                            getRecapAndNextTopicQuestions()
                        }
                    }
                    
                case 3:
                    UpdateTopicRecapView(
                        viewModel: dailyTopicViewModel,
                        recapSelectedTab: $selectedTabRecap,
                        topic: topic,
                        retryAction: {
                            getRecapAndNextTopicQuestions()
                        }
                    )
                
                case 4:
                    UpdateTopicCarouselView(
                        title: "Here's what I think",
                        items: topic.topicFeedback
                            .sorted { $0.orderIndex < $1.orderIndex },
                        scrollPosition: $feedbackScrollPosition,
                        extractContent: { $0.feedbackContent }
                    )
                
                case 5:
                    QuestionWhereToNext2(
                        imageName: "spark",
                        title: "Spark complete",
                        subtitle: "Explore further?",
                        leftAction: {
                            completeFlowAction()
                        },
                        rightAction: {
                            diveDeeperAction()
                        },
                        leftTitle: "I'm done",
                        leftSubtitle: "Get a new spark tomorrow",
                        rightTitle: "Go deeper",
                        rightSubtitle: "Look at it from a new angle",
                        leftSymbol: "checkmark",
                        rightSymbol: "arrow.right"
                    )
                    .padding(.horizontal)
                
                case 6:
                    SequenceSuggestionsView (
                        topicViewModel: topicViewModel,
                        viewModel: dailyTopicViewModel,
                        planSelectedTab: $selectedTabPlan,
                        showSheet: $showUpdateTopicView,
                        showExitFlowAlert: $showExitFlowAlert,
                        retryAction: {
                            retryActionPlan()
                        }
                    )
                
                default:
                    NotificationsView(
                        leftAction: {
                            notificationsViewAction()
                        }, rightAction: {
                            notificationsViewAction()
                        }
                    )
              
                
            }//switch
            
        }//VStack
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .background {
            BackgroundPrimary(backgroundColor: backgroundColor)
            
        }
        .overlay {
            if selectedTab < 5 {
                getViewButton()
            }
            
        }
        .onAppear {
            setupView()
            
        }
        .onChange(of: expectationsScrollPosition) {
            if (expectationsScrollPosition == topic.topicExpectations.count - 1) {
                if disableButtonExpectations {
                    disableButtonExpectations = false
                }
            }
        }
        .onChange(of: feedbackScrollPosition) {
            if (feedbackScrollPosition == topic.topicFeedback.count - 1) {
                if disableButtonFeedback {
                    disableButtonFeedback = false
                }
            }
        }
        .alert("Exit retrospective?", isPresented: $showExitFlowAlert) {
            Button("Keep going", role: .cancel) {
                showExitFlowAlert = false
            }
            Button("Exit", role: .destructive) {
                exitFlow()
            }
        } message: {
            Text("You'll lose your progress on this step.")
        }
       
    }
    
    private func dismiss() {
        showUpdateTopicView = false
    }
    
    private func getViewButton() -> some View {
        VStack {
            //Next button
            RectangleButtonPrimary (
                buttonText: getButtonText(),
                action: {
                    getMainButtonAction()
                },
                showSkipButton: showSkipButton(),
                skipAction: {
                    skipButtonAction()
                },
                disableMainButton: disableButton(),
                buttonColor: .white
            )
        }
        .frame(maxHeight: .infinity, alignment: .bottom)
        .padding(.bottom)
        .ignoresSafeArea(getSafeAreaProperty(for: selectedQuestion))
    }
    
    private func getSafeAreaProperty(for index: Int) -> SafeAreaRegions {
        // Add bounds check
        guard !questions.isEmpty, index < questions.count else {
            return []
        }
        
        if QuestionType(rawValue: questions[index].questionType) != .open {
            return .keyboard
        }
        
        return []
    }
    
    private func getButtonText() -> String {
        switch selectedTab {
        case 0:
            return "Continue"
        case 1:
            return getButtonTextQuestionsView()
        case 2:
            return "Next: reflection"
            
        case 3:
            return getButtonTextRecapView()
        
        case 4:
            if topic.topicStatus == TopicStatusItem.completed.rawValue {
                return "Done"
                
            } else {
                return "Continue"
            }
        
        default:
            return "Continue"
        }
        
    }
    
    private func getButtonTextQuestionsView() -> String {
        switch selectedTabQuestions {
        case 0:
            return "Loading . . ."
        case 1 :
            if selectedQuestion < mainFlowQuestionsCount - 1 {
                return "Next question"
            } else if selectedQuestion == mainFlowQuestionsCount - 1 {
                return "Complete topic"
            } else {
                return "Continue"
            }
           
        default:
            return "Retry"
        }
    }
    
    private func getButtonTextRecapView() -> String {
        switch selectedTabRecap {
        case 0:
            return "Loading . . ."
        case 1 :
            return "Continue"
        default:
            return "Retry"
        }
    }
    
    private func getMainButtonAction() {
        switch selectedTab {
            case 0:
                goToQuestions()
                
            case 1:
                saveAnswer()
                
            case 2:
                updatePoints()
                
            case 3:
                completeFeedback()
            
            case 4:
                if topic.topicStatus == TopicStatusItem.completed.rawValue {
                    dismiss()
                } else {
                    selectedQuestion += 1
                    selectedTab = 1
                }
            
            default:
                selectedTab += 1
        
        }
    }
    
    private func showSkipButton() -> Bool {
        if selectedTab == 1 && questions.count > 0 && selectedQuestion < mainFlowQuestionsCount {
            if let answeredQuestionType =  QuestionType(rawValue: questions[selectedQuestion].questionType) {
                switch answeredQuestionType {
                case .open:
                    return answersOpen[selectedQuestion].isEmpty
                case .singleSelect:
                    return singleSelectAnswer.isEmpty
                case .multiSelect:
                    return multiSelectAnswers.isEmpty
                }
            }
        }
        
        return false
    }
    
    private func skipButtonAction() {
        let numberOfQuestions = questions.count
       
        if focusField != nil {
            focusField = nil
        }
        
        goToNextquestion(totalQuestions: numberOfQuestions)
        
        DispatchQueue.global(qos: .background).async {
            Mixpanel.mainInstance().track(event: "Skipped question")
        }
    }
    
    private func disableButton() -> Bool {
        switch selectedTab {
            
        case 0:
            return disableButtonExpectations
            
        case 1:
            if selectedTab == 1 && questions.count > 0 {
                return showSkipButton()
            } else if selectedTab == 1 && selectedTabQuestions == 0 {
                return true
            }
            return false
        
        case 2:
            return animationStage < 2
        case 3:
            if selectedTabRecap == 0 {
                return true
            } else {
                //                    if let feedback = topic.review?.reviewSummary {
                //                       return animatedText != feedback
                //                    } else {
                return false
                //                    }
            }
        default:
            return disableButtonFeedback
            
        }
        
    }
    
    private func goToQuestions() {
        updateQuestionVariables(count: questions.count)
        selectedTab += 1
    }
    
    private func saveAnswer() {
        //capture current state
        let answeredQuestionIndex = selectedQuestion
        
        let answeredQuestion = questions[answeredQuestionIndex]
        let numberOfQuestions = questions.count
        
        var answeredQuestionTopicText: String?
        var answeredQuestionSingleSelect: String?
        var answeredQuestionMultiSelect: [String]?
        var customItemsSingleSelect: [String]?
        var customItemsMultiSelect: [String]?
        
        if let answeredQuestionType =  QuestionType(rawValue: answeredQuestion.questionType){
            switch answeredQuestionType {
            case .open:
                if answeredQuestionIndex < numberOfQuestions - 1 {
                    let nextQuestion = questions[answeredQuestionIndex + 1]
                    if nextQuestion.questionType != QuestionType.open.rawValue {
                        focusField = nil
                    }
                }
                answeredQuestionTopicText = answersOpen[answeredQuestionIndex]
            case .singleSelect:
                answeredQuestionSingleSelect = singleSelectAnswer
                customItemsSingleSelect = singleSelectCustomItems
            case .multiSelect:
                answeredQuestionMultiSelect = multiSelectAnswers
                customItemsMultiSelect = multiSelectCustomItems
            }
        }
        
        
        //reset the value of @State vars managing answers, and custom answers for single and multi select
        if answeredQuestionIndex + 1 < numberOfQuestions {
            singleSelectAnswer = ""
            multiSelectAnswers = []
            singleSelectCustomItems = []
            multiSelectCustomItems = []
        }
        
        //move to next question
        DispatchQueue.main.async {
            goToNextquestion(totalQuestions: numberOfQuestions)
        }
        
        //save answers
        Task {
            
            await saveQuestionAnswer(
                question: answeredQuestion,
                topicText: answeredQuestionTopicText,
                singleSelectAnswer: answeredQuestionSingleSelect,
                multiSelectAnswers: answeredQuestionMultiSelect,
                singleSelectCustomItems: customItemsSingleSelect,
                multiSelectCustomItems: customItemsMultiSelect
            )
            
            await nextAction(question: answeredQuestion.questionContent)
            
            DispatchQueue.global(qos: .background).async {
                Mixpanel.mainInstance().track(event: "Answered question")
            }
        }
        
    }
    
    // accounts for every question except the last question in the flow
    private func goToNextquestion(totalQuestions: Int) {
        let staticQuestions = NewQuestion.questionsDailyTopic.count
        let mainFlowQuestions = totalQuestions - staticQuestions
        
        let currentQuestion = selectedQuestion + 1

        if currentQuestion < mainFlowQuestions || (currentQuestion > mainFlowQuestions + 2 && currentQuestion < totalQuestions) {
            selectedQuestion += 1
        } else if currentQuestion == mainFlowQuestions {
            completeMainFlow()
        } else if currentQuestion == mainFlowQuestions + 1 {
            selectedTab = 5
        }
        
        if selectedQuestion + 1 <= mainFlowQuestions {
            //add fill to progress bar
            withAnimation(.interpolatingSpring) {
                currentQuestionIndex += 1
            }
        }
        
        
    }
    
    private func saveQuestionAnswer(
        question: Question,
        topicText: String?,
        singleSelectAnswer: String?,
        multiSelectAnswers: [String]?,
        singleSelectCustomItems: [String]?,
        multiSelectCustomItems: [String]?
    ) async {
        
        if let questionType = QuestionType(rawValue: question.questionType) {
            switch questionType {
            case .open:
                if let newTopicText = topicText {
                    await dailyTopicViewModel.saveAnswer(
                        questionType: .open,
                        topic: topic,
                        questionId: question.questionId,
                        userAnswer: newTopicText
                    )
                }
            case .singleSelect:
                if let newSelectedValue = singleSelectAnswer {
                    await dailyTopicViewModel.saveAnswer(
                        questionType: .singleSelect,
                        topic: topic,
                        questionId: question.questionId,
                        userAnswer: newSelectedValue,
                        customItems: singleSelectCustomItems
                    )
                }
            case .multiSelect:
                if let newSelectedOptions = multiSelectAnswers {
                    await dailyTopicViewModel.saveAnswer(
                        questionType: .multiSelect,
                        topic: topic,
                        questionId: question.questionId,
                        userAnswer: newSelectedOptions,
                        customItems: multiSelectCustomItems
                    )
                }
            }
        }
    }
    
    private func nextAction(question: String) async {
        switch question {
        case NewQuestion.questionsDailyTopic[1].content:
            await markCompleteAndCreateNext()
            
            let notificationEnabled = await notificationManager.checkIfNotificationsAreScheduled()
            
            if notificationEnabled {
                await MainActor.run {
                    dismiss()
                }
            } else {
                selectedTab = 7
            }

        case NewQuestion.questionsDailyTopic[4].content:
            let notificationEnabled = await notificationManager.checkIfNotificationsAreScheduled()
            
            if notificationEnabled {
                await MainActor.run {
                    selectedTab = 6
                }
            } else {
                selectedTab = 7
            }
            await markCompleteAndCreateNext()

        case NewQuestion.questionsDailyTopic[3].content:
            await getPlans()

        default:
            break
        }
        
    }
    
    private func completeFeedback() {
        
        if dailyTopicViewModel.createTopicRecap == .retry {
            getRecapAndNextTopicQuestions()
            
        } else {
            
            selectedTab += 1
        }
    }
    
    private func completeMainFlow() {
        if focusField != nil {
            focusField = nil
        }
        
        if selectedTab < 3 {
            selectedTab += 1
        }
    }
    
    private func backButtonAction() {
        //capture current state
        let answeredQuestionIndex = selectedQuestion
        
        let answeredQuestion = questions[answeredQuestionIndex]
        
        var answeredQuestionTopicText: String?
        var answeredQuestionSingleSelect: String?
        var answeredQuestionMultiSelect: [String]?
        var customItemsSingleSelect: [String]?
        var customItemsMultiSelect: [String]?
        
        if let answeredQuestionType =  QuestionType(rawValue: answeredQuestion.questionType){
            switch answeredQuestionType {
            case .open:
                answeredQuestionTopicText = answersOpen[answeredQuestionIndex]
            case .singleSelect:
                answeredQuestionSingleSelect = singleSelectAnswer
                customItemsSingleSelect = singleSelectCustomItems
            case .multiSelect:
                answeredQuestionMultiSelect = multiSelectAnswers
                customItemsMultiSelect = multiSelectCustomItems
            }
        }
        
        //close keyboard if previous question is not open-ended
        let previousQuestionIndex = selectedQuestion - 1
        
        if let questionType = QuestionType(rawValue: questions[previousQuestionIndex].questionType), questionType != .open {
            if focusField != nil {
                focusField = nil
            }
        }
        
        //reset the value of @State vars managing answers, and custom answers for single and multi select
        singleSelectAnswer = ""
        multiSelectAnswers = []
        singleSelectCustomItems = []
        multiSelectCustomItems = []
        
        //go to previous question
        if selectedQuestion > 0 {
            selectedQuestion -= 1
        }
        
        //move progress bar back
        withAnimation(.interpolatingSpring) {
            currentQuestionIndex -= 1
        }
        
        Task {
            await saveQuestionAnswer(
                question: answeredQuestion,
                topicText: answeredQuestionTopicText,
                singleSelectAnswer: answeredQuestionSingleSelect,
                multiSelectAnswers: answeredQuestionMultiSelect,
                singleSelectCustomItems: customItemsSingleSelect,
                multiSelectCustomItems: customItemsMultiSelect
            )
        }
    }
    
    private func getRecapAndNextTopicQuestions() {
        dailyTopicViewModel.createTopicRecap = .loading
        
        Task {
            //generate recap
            do {
                try await dailyTopicViewModel.manageRun(selectedAssistant: .topicDailyRecap, topic: topic)
            } catch {
                await MainActor.run {
                    dailyTopicViewModel.createTopicRecap = .retry
                }
            }
            
        }
    }
    
    private func updateQuestionVariables(count: Int) {
        
        if count > 0 && answersOpen.count != count {
            answersOpen = Array(repeating: "", count: count)
            print("updated answer variables: \(count)")
        }
    }
    
    private func updatePoints() {
        selectedTab += 1
        Task {
            await dataController.updatePoints(newPoints: 1)
        }
    }
    
    private func markCompleteAndCreateNext() async {
        if !hasTopicForTomorrow {
            let _ = await dailyTopicViewModel.createDailyTopic(topicDate: getNextDayString())
        }
        
        await markDailyTopicComplete()
        
    }
    
    private func markDailyTopicComplete() async {
        
        await dailyTopicViewModel.completeTopic(topic: topic)
        
        DispatchQueue.global(qos: .background).async {
            Mixpanel.mainInstance().track(event: "Completed daily topic")
        }
            
    }
    
    //MARK: - Set up view
    private func setupView() {
        if topic.topicStatus == TopicStatusItem.completed.rawValue {
            selectedTab = 4
        } else {
            updateQuestionVariables(count: questions.count)
        }
    }
    
   // MARK: - Complete or go deeper
    private func completeFlowAction() {
        selectedQuestion += 1
        selectedTab = 1
    }
    
    private func diveDeeperAction() {
        selectedQuestion += 2
        selectedTab = 1
    }
    
    private func getPlans() async {
        
        // Create the category
        let savedCategory = await dataController.createSingleCategory()
        
        // Create new goal
        /// need to make sure questions are related to the right goal when saved
        let savedGoal = await dataController.createNewGoal(
            category: savedCategory,
            topic: topic
        )
        
        if let category = savedCategory, let goal = savedGoal {
            await createPlanSuggestions(
                category: category,
                goal: goal
            )
        }
        
        
    }
    
    private func createPlanSuggestions(category: Category, goal: Goal) async {
        
        do {
            try await dailyTopicViewModel.manageRun(selectedAssistant: .planSuggestion, category: category, goal: goal)
            
        } catch {
            await MainActor.run {
                dailyTopicViewModel.createPlanSuggestions = .retry
            }
        }
    
    }
    
    private func retryActionPlan() {
        selectedTabPlan = 0
        
        // reset var for managing when loading animation
        dailyTopicViewModel.completedLoadingAnimationPlan = false

        if let category = dailyTopicViewModel.currentCategory,
            let goal = dailyTopicViewModel.currentGoal {
            Task {
              await createPlanSuggestions(category: category, goal: goal)
            }
        }
        
    }
    
    // MARK: - Notifications
    private func notificationsViewAction() {
        if dailyTopicViewModel.startedPlanSuggestionsRun {
            selectedTab = 6
        } else {
            dismiss()
        }
    }
    
    // MARK: - Exit Flow
    private func exitFlow() {
        //close sheet
        dismiss()

        // cancel any active API calls
        cancelRun()
    }
    
    private func cancelRun() {
        Task {
            if dailyTopicViewModel.createTopicRecap == .loading || dailyTopicViewModel.createPlanSuggestions == .loading {
                try await dailyTopicViewModel.cancelCurrentRun()
            }
        }
    }
}



