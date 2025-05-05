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
            
            if selectedTab == 1 && showProgressBar {
                //Header
                QuestionsProgressBar (
                    currentQuestionIndex: $currentQuestionIndex,
                    totalQuestions: topic.topicQuestions.count,
                    showXmark: true,
                    xmarkAction: {
                        dismiss()
                    },
                    showBackButton: selectedQuestion > 0,
                    backAction: {
                        backButtonAction()
                    })
                .transition(.opacity)
                
            } else if selectedTab != 1 {
                SheetHeader(
                    emoji: topic.topicEmoji,
                    title: topic.topicTitle,
                    xmarkAction: {
                        dismiss()
                    })
            }
            
            //Question
            switch selectedTab {
            case 0:
                UpdateTopicIntroView(
                    topicViewModel: topicViewModel,
                    answersOpen: $answersOpen,
                    topic: topic,
                    sequence: sequence,
                    questions: questions
                )
                .padding(.horizontal)
                
            case 1:
                UpdateTopicQuestionsView(
                    topicViewModel: topicViewModel,
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
                
            case 2:
                RecapCelebrationView(title: topic.topicTitle, text: "For completing", points: "+1")
                    .padding(.horizontal)
                    .padding(.top, 80)
                    .onAppear {
                        getRecapAndNextTopicQuestions()
                    }
                
            default:
                UpdateTopicRecapView(
                    topicViewModel: topicViewModel,
                    topic: topic,
                    retryAction: {
                        getRecapAndNextTopicQuestions()
                    })
                
            }//switch
            
        }//VStack
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .background {
            BackgroundPrimary(backgroundColor:backgroundColor)
            
        }
        .overlay {
            getViewButton()
            
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
    
    private func getSafeAreaProperty(for index: Int) ->  SafeAreaRegions {
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
            if selectedQuestion < questions.count - 1 {
                return "Next question"
            } else {
                return "Complete topic"
            }
        case 2:
            return "Next: Reflection"
            
        default:
            return getButtonTextRecapView()
        }
        
    }
    
    private func getButtonTextRecapView() -> String {
        switch topicViewModel.createTopicOverview {
        case .ready:
            return "Done"
        case .loading:
            return "Loading . . ."
        case .retry:
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
            
        default:
            completeTopic()
        }
    }
    
    private func showSkipButton() -> Bool {
        if selectedTab == 1 {
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
        }
        
        goToNextquestion(totalQuestions: numberOfQuestions)
        
        DispatchQueue.global(qos: .background).async {
            Mixpanel.mainInstance().track(event: "Skipped question")
        }
    }
    
    private func disableButton() -> Bool {
        switch selectedTab {
        case 1:
            return showSkipButton()
            
        case 3:
            if topicViewModel.createTopicOverview == .loading {
                return true
            } else {
                //                    if let feedback = topic.review?.reviewSummary {
                //                       return animatedText != feedback
                //                    } else {
                return false
                //                    }
            }
            
        default:
            return false
            
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
            
            DispatchQueue.global(qos: .background).async {
                Mixpanel.mainInstance().track(event: "Answered question")
            }
            
            if numberOfQuestions == answeredQuestionIndex + 1 {
                await MainActor.run {
                    completeQuestions()
                }
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
                    await dataController.saveAnswer(
                        questionType: .open,
                        questionId: question.questionId,
                        userAnswer: newTopicText
                    )
                }
            case .singleSelect:
                if let newSelectedValue = singleSelectAnswer {
                    await dataController.saveAnswer(
                        questionType: .singleSelect,
                        questionId: question.questionId,
                        userAnswer: newSelectedValue,
                        customItems: singleSelectCustomItems
                    )
                }
            case .multiSelect:
                if let newSelectedOptions = multiSelectAnswers {
                    await dataController.saveAnswer(
                        questionType: .multiSelect,
                        questionId: question.questionId,
                        userAnswer: newSelectedOptions,
                        customItems: multiSelectCustomItems
                    )
                }
            }
        }
    }
    
    private func completeTopic() {
        
        if topicViewModel.createTopicOverview == .retry {
            getRecapAndNextTopicQuestions()
            
        } else {
            
            dismiss()
            
            Task {
                
                await dataController.completeTopic(topic: topic)
                
                DispatchQueue.global(qos: .background).async {
                    Mixpanel.mainInstance().track(event: "Completed section")
                }
                
            }
        }
    }
    
    private func completeQuestions() {
        if focusField != nil {
            focusField = nil
        }
        
        if selectedTab < 2 {
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
        topicViewModel.createTopicOverview = .loading
        
        //get the next topic
        let nextTopicIndex = topic.orderIndex + 1
        let nextTopic = sequence.sequenceTopics.filter { $0.orderIndex == nextTopicIndex }
        
        Task {
            //generate recap
            do {
                try await topicViewModel.manageRun(selectedAssistant: .topicOverview, topic: topic)
            } catch {
                topicViewModel.createTopicOverview = .retry
            }
            
            // get content for next topic
            if let newTopic = nextTopic.first, let questType = QuestTypeItem(rawValue: newTopic.topicQuestType) {
                
                switch questType {
                    
                case .break1:
                    await getTopicBreak(topic: newTopic)
                    
                case .retro:
                    break
                default:
                  await  getTopicQuestions(topic: newTopic)
                    
                }
                
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
    
    private func getTopicQuestions(topic: Topic) async {
        do {
            try await topicViewModel.manageRun(selectedAssistant: .topic, topic: topic)
            
            
        } catch {
            topicViewModel.createTopicQuestions = .retry
        }
    }
    
    private func updatePoints() {
        selectedTab += 1
        Task {
            await dataController.updatePoints(newPoints: 1)
        }
    }
}



