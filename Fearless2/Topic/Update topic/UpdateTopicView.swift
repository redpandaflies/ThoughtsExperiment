//
//  UpdateTopicView.swift
//  Fearless2
//
//  Created by Yue Deng-Wu on 10/3/24.
//
import CoreData
import Mixpanel
import SwiftUI

struct UpdateTopicView: View {
    @EnvironmentObject var dataController: DataController
    @ObservedObject var topicViewModel: TopicViewModel
    
    @State private var showProgressBar: Bool = true //for hiding progress bar when user is typing their answer for single-select question
    @State private var selectedTab: Int = 0
    @State private var showWarningSheet: Bool = false
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
    @State private var recapSelectedTab: Int = 0 //manage the UI changes when recap is ready
    
    /// for feedback view
    @State private var feedbackScrollPosition: Int?
    @State private var disableButtonFeedback: Bool = true
    
    @Binding var showUpdateTopicView: Bool //dismiss sheet
    
    let topic: Topic
    let sequence: Sequence
    let backgroundColor: Color
    
    @FetchRequest var questions: FetchedResults<Question>
    
    @FocusState var focusField: DefaultFocusField?
    
    init(topicViewModel: TopicViewModel,
         showUpdateTopicView: Binding<Bool>,
         topic: Topic,
         sequence: Sequence,
         backgroundColor: Color
    ) {
        self.topicViewModel = topicViewModel
        self._showUpdateTopicView = showUpdateTopicView
        self.topic = topic
        self.sequence = sequence
        self.backgroundColor = backgroundColor
        
        let request: NSFetchRequest<Question> = Question.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: "questionNumber", ascending: true)]
        request.predicate = NSPredicate(format: "topic == %@", topic)
        self._questions = FetchRequest(fetchRequest: request)
        
    }
    
    var body: some View {
        
        VStack {
            
            if selectedTab == 2 && showProgressBar {
                //Header
                QuestionsProgressBar (
                    currentQuestionIndex: $currentQuestionIndex,
                    totalQuestions: questions.count,
                    showXmark: true,
                    xmarkAction: {
                        dismiss()
                    },
                    showBackButton: selectedQuestion > 0,
                    backAction: {
                        backButtonAction()
                    })
                .transition(.opacity)
                
            } else if selectedTab != 2 {
                SheetHeader(
                    title: selectedTab > 0 ? sequence.sequenceTitle : "",
                    xmarkAction: {
                        dismiss()
                    })
            }
            
            //Question
            switch selectedTab {
                case 0:
                    UpdateTopicIntroView(
                        topicViewModel: topicViewModel,
                        selectedTabTopicsList: $selectedTabTopicsList,
                        topic: topic,
                        sequence: sequence,
                        questions: questions,
                        getQuestions: {
                            Task {
                                await getTopicQuestions(topic: topic, updateVariables: true)
                            }
                        },
                        updateQuestionVariables: { count in
                            updateQuestionVariables(count: count)
                        }
                        
                    )
                    .padding(.horizontal)
                    .padding(.top)
                
                case 1:
                    UpdateTopicCarouselView(
                        title: topic.topicTitle,
                        items:  topic.topicExpectations
                            .sorted { $0.orderIndex < $1.orderIndex },
                        scrollPosition: $expectationsScrollPosition,
                        extractContent: { $0.expectationContent })
                    
                case 2:
                    UpdateTopicQuestionsView(
                        showProgressBar: $showProgressBar,
                        selectedQuestion: $selectedQuestion,
                        answersOpen: $answersOpen,
                        singleSelectAnswer: $singleSelectAnswer,
                        multiSelectAnswers: $multiSelectAnswers,
                        singleSelectCustomItems: $singleSelectCustomItems,
                        multiSelectCustomItems: $multiSelectCustomItems,
                        focusField: $focusField,
                        topic: topic,
                        questions: questions
                    )
                    .padding(.top)
                    .padding(.horizontal)
                    
                case 3:
                    RecapCelebrationView (
                        animationStage: $animationStage,
                        title: topic.topicTitle,
                        text: "For completing",
                        points: "+1"
                    )
                    .padding(.horizontal)
                    .padding(.top, 80)
                    
                    
                case 4:
                    UpdateTopicRecapView(
                       viewModel: topicViewModel,
                       recapSelectedTab: $recapSelectedTab,
                        topic: topic,
                        retryAction: {
                            Task {
                              await getRecapAndNextTopicQuestions()
                            }
                        }
                    )
                
                case 5:
                    UpdateTopicCarouselView(
                        title: "Here's what I think",
                        items: topic.topicFeedback
                            .sorted { $0.orderIndex < $1.orderIndex },
                        scrollPosition: $feedbackScrollPosition,
                        extractContent: { $0.feedbackContent }
                    )
                
                default:
                    UpdateTopicEndView(
                        topicViewModel: topicViewModel,
                        selectedTabTopicsList: $selectedTabTopicsList,
                        sequence: sequence,
                        questions: questions
                    )
                    .padding(.horizontal)
                    .padding(.top)
                
            }//switch
            
        }//VStack
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .background {
            BackgroundPrimary(backgroundColor:backgroundColor)
            
        }
        .overlay {
            getViewButton()
            
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
        .sheet(isPresented: $showWarningSheet, onDismiss: {
            showWarningSheet = false
        }) {
            WarningLostProgress(quitAction: {
                dismiss()
            })
            .presentationCornerRadius(20)
            .presentationBackground(AppColors.black3)
            .presentationDetents([.medium])
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
        if questions.isEmpty {
            return []
        } else if QuestionType(rawValue: questions[selectedQuestion].questionType) != .open {
            return .keyboard
        }
        
        return []
    }
    
    private func getButtonText() -> String {
        switch selectedTab {
        case 0:
            return "Start"
        case 1:
            return "Continue"
        case 2:
            if selectedQuestion < questions.count - 1 {
                return "Next question"
            } else {
                return "Complete topic"
            }
        case 3:
            return "Next: reflection"
            
        case 4:
            return getButtonTextRecapView()
            
        case 5:
            return "Continue"
            
        default:
            return "Complete session"
        }
        
    }
    
    private func getButtonTextRecapView() -> String {
        switch topicViewModel.createTopicRecap {
        case .ready:
            return "Continue"
        case .loading:
            return "Loading . . ."
        case .retry:
            return "Retry"
        }
    }
    
    private func getMainButtonAction() {
        switch selectedTab {
            case 0:
                startFlow()
            
            case 1:
                goToQuestions()
                
            case 2:
                saveAnswer()
                
            case 3:
                updatePoints()
                
            case 4:
                completeTopic()
            
            case 6:
                dismiss()
        
            default:
                selectedTab += 1
        }
    }
    
    private func showSkipButton() -> Bool {
        if selectedTab == 2 {
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
        let answeredQuestionIndex = selectedQuestion
        let numberOfQuestions = questions.count
        
        if answeredQuestionIndex + 1 == numberOfQuestions {
            completeQuestions()
            Task {
                await getRecapAndNextTopicQuestions()
            }
        }
        
        goToNextquestion(totalQuestions: numberOfQuestions)
        
        DispatchQueue.global(qos: .background).async {
            Mixpanel.mainInstance().track(event: "Skipped question")
        }
    }
    
    private func disableButton() -> Bool {
        switch selectedTab {
            
        case 0:
            return selectedTabTopicsList != 1
            
        case 1:
            return disableButtonExpectations
            
        case 2:
            return showSkipButton()
        
        case 3:
            return animationStage < 2
        case 4:
            if topicViewModel.createTopicRecap == .loading {
                return true
            } else {
                //                    if let feedback = topic.review?.reviewSummary {
                //                       return animatedText != feedback
                //                    } else {
                return false
                //                    }
            }
        case 5:
            return disableButtonFeedback
        default:
            return false
            
        }
        
    }
    
    private func startFlow() {
        if !topic.topicExpectations.isEmpty {
            selectedTab += 1
        } else {
            selectedTab += 2
        }
    }
    
    private func goToQuestions() {
        let count = topic.topicQuestions.count
        answersOpen = Array(repeating: "", count: count)
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
            
            if numberOfQuestions == answeredQuestionIndex + 1 {
                
                await MainActor.run {
                    completeQuestions()
                }
                
                await getRecapAndNextTopicQuestions()
            }
            
            DispatchQueue.global(qos: .background).async {
                Mixpanel.mainInstance().track(event: "Answered question")
            }
        }
        
    }
    
    private func goToNextquestion(totalQuestions: Int) {
        
        if selectedQuestion + 1 < totalQuestions {
            selectedQuestion += 1
        }
        
        //add fill to progress bar
        withAnimation(.interpolatingSpring) {
            currentQuestionIndex += 1
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
                    await topicViewModel.saveAnswer(
                        questionType: .open,
                        topic: topic,
                        questionId: question.questionId,
                        userAnswer: newTopicText
                    )
                }
            case .singleSelect:
                if let newSelectedValue = singleSelectAnswer {
                    await topicViewModel.saveAnswer(
                        questionType: .singleSelect,
                        topic: topic,
                        questionId: question.questionId,
                        userAnswer: newSelectedValue,
                        customItems: singleSelectCustomItems
                    )
                }
            case .multiSelect:
                if let newSelectedOptions = multiSelectAnswers {
                    await topicViewModel.saveAnswer(
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
    
    private func completeTopic() {
        
        if topicViewModel.createTopicRecap == .retry {
            Task {
                await getRecapAndNextTopicQuestions()
            }
            
        } else {
            
            selectedTab += 1
            
            Task {
                
                await dataController.completeTopic(topic: topic)
                
                await MainActor.run {
                    topicViewModel.completedNewTopic = true
                }
                
                DispatchQueue.global(qos: .background).async {
                    Mixpanel.mainInstance().track(event: "Completed guided step")
                }
                
            }
        }
    }
    
    private func completeQuestions() {
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
    
    private func getRecapAndNextTopicQuestions() async {
        topicViewModel.createTopicRecap = .loading
        
        //get the next topic
        let nextTopicIndex = topic.orderIndex + 1
        let nextTopic = sequence.sequenceTopics.filter { $0.orderIndex == nextTopicIndex }
       
        //generate recap
        do {
            try await topicViewModel.manageRun(selectedAssistant: .topicOverview, topic: topic)
        } catch {
            topicViewModel.createTopicRecap = .retry
        }
        
        // get content for next topic
        if let newTopic = nextTopic.first, let questType = QuestTypeItem(rawValue: newTopic.topicQuestType) {
            
            switch questType {
                
            case .context, .guided:
                await  getTopicQuestions(topic: newTopic, updateVariables: false)
                
            case .retro:
                break
            default:
              
                await getTopicBreak(topic: newTopic)
                
            }
            
        }
            
       
    }
    
    private func getTopicBreak(topic: Topic) async {
        do {
            
            try await topicViewModel.manageRun(selectedAssistant: .topicBreak, topic: topic)
            
            
        } catch {
            topicViewModel.createTopicBreak = .retry
        }
    }
    
    private func getTopicQuestions(topic: Topic, updateVariables: Bool) async {
        
        await MainActor.run {
            topicViewModel.createTopicQuestions = .loading
        }
        
        do {
            try await topicViewModel.manageRun(selectedAssistant: .topic, topic: topic)
            
            if updateVariables {
                await MainActor.run {
                    updateQuestionVariables(count: topic.topicQuestions.count)
                }
            }
        } catch {
            topicViewModel.createTopicQuestions = .retry
        }
      
    }
    
    private func updateQuestionVariables(count: Int) {
        answersOpen = Array(repeating: "", count: count)
        
        print("updated answer variables: \(count)")
    }
    
    private func updatePoints() {
        selectedTab += 1
        Task {
            await dataController.updatePoints(newPoints: 1)
        }
    }
}



