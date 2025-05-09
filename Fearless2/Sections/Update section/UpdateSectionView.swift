//
//  UpdateSectionView.swift
//  Fearless2
//
//  Created by Yue Deng-Wu on 10/3/24.
//
import CoreData
import Mixpanel
import SwiftUI

struct UpdateSectionView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var dataController: DataController
    @ObservedObject var topicViewModel: TopicViewModel
    
    @State private var showProgressBar: Bool = true //for hiding progress bar when user is typing their answer for single-select question
    @State private var selectedTab: Int = 0
    @State private var showWarningSheet: Bool = false
    @State private var selectedQuestion: Int = 0
    @State private var topicText: String = ""//user's definition of the new topic
    @State private var singleSelectAnswer: String = "" //single-select answer
    @State private var multiSelectAnswers: [String] = [] //answers user choose for muti-select questions
    @State private var currentQuestionIndex: Int = 0 //for the progress bar
    @State private var singleSelectCustomItems: [String] = []//stores updated array when user inputs their own answer for single select
    @State private var multiSelectCustomItems: [String] = []//stores updated array when user inputs their own answer for multi select
    
    @Binding var selectedSectionSummary: SectionSummary?
    
    let topicId: UUID?
    let focusArea: FocusArea?
    let section: Section
    
    var questions: [Question] {
        return section.sectionQuestions.sorted { $0.questionNumber < $1.questionNumber }
    }
    
    @FocusState var isFocused: Bool
    
    init(topicViewModel: TopicViewModel, selectedSectionSummary: Binding<SectionSummary?>, topicId: UUID?, focusArea: FocusArea?, section: Section) {
        self.topicViewModel = topicViewModel
        self._selectedSectionSummary = selectedSectionSummary
        self.topicId = topicId
        self.focusArea = focusArea
        self.section = section
        
    }
    
    var body: some View {
        
        VStack {
            
            if showProgressBar {
                //Header
                QuestionsProgressBar(
                    currentQuestionIndex: $currentQuestionIndex,
                    totalQuestions: section.sectionQuestions.count,
                    showXmark: true,
                    xmarkAction: {
                        dismiss()
                    },
                    showBackButton: selectedQuestion > 0,
                    backAction: {
                        backButtonAction()
                    })
                    .transition(.opacity)
            }
            
            //Question
            switch selectedTab {
              
                case 0:
                    UpdateSectionBox(topicViewModel: topicViewModel, showProgressBar: $showProgressBar, selectedQuestion: $selectedQuestion, topicText: $topicText, singleSelectAnswer: $singleSelectAnswer, multiSelectAnswers: $multiSelectAnswers, singleSelectCustomItems: $singleSelectCustomItems, multiSelectCustomItems: $multiSelectCustomItems, isFocused: $isFocused, section: section, questions: questions)
                        .padding(.top)
                    
                default:
                    if let currentFocusArea = focusArea {
                        UpdateSectionCompleteView(focusArea: currentFocusArea)
                    }
                
            }//switch
                
        }//VStack
        .padding(.horizontal)
        .padding(.bottom)
        .background {
            if let category = focusArea?.category {
                BackgroundPrimary(backgroundColor: Realm.getBackgroundColor(forName: category.categoryName))
            } else {
                BackgroundPrimary(backgroundColor: AppColors.backgroundCareer)
            }
        }
        .overlay {
            getViewButton()
            
        }
        .environment(\.colorScheme, .dark)
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
                disableMainButton: showSkipButton()
            )
        }
        .frame(maxHeight: .infinity, alignment: .bottom)
        .padding(.bottom)
        .ignoresSafeArea(QuestionType(rawValue: questions[selectedQuestion].questionType) == .open ? [] : .keyboard)
    }
    
    private func getButtonText() -> String {
        switch selectedTab {
        case 0:
            if selectedQuestion < section.sectionQuestions.count - 1 {
                return "Next question"
            } else {
               
                return "Complete section"
            }
        default:
            return "Done"
        }
        
    }
    
    private func getMainButtonAction() {
        switch selectedTab {
        case 0:
            saveAnswer()
        default:
            completeSection()
        }
    }
    
    private func showSkipButton() -> Bool {
        if selectedTab == 0 {
            if let answeredQuestionType =  QuestionType(rawValue: questions[selectedQuestion].questionType) {
                switch answeredQuestionType {
                case .open:
                    return topicText.isEmpty
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
            submitForm()
        }
        
        goToNextquestion(totalQuestions: numberOfQuestions)
        
        Task {
            await completeSection(totalQuestions: numberOfQuestions, answeredQuestionIndex: answeredQuestionIndex)
            
            DispatchQueue.global(qos: .background).async {
                Mixpanel.mainInstance().track(event: "Skipped question")
            }
            
        }
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
                        isFocused = false
                    }
                }
                
                answeredQuestionTopicText = topicText
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
            topicText = ""
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
            
            print("SelectedQuestion: \(selectedQuestion)")
            
            DispatchQueue.global(qos: .background).async {
                Mixpanel.mainInstance().track(event: "Answered question")
            }
            
            await completeSection(totalQuestions: numberOfQuestions, answeredQuestionIndex: answeredQuestionIndex)
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
    
    private func completeSection(totalQuestions: Int, answeredQuestionIndex: Int) async {
        
        if answeredQuestionIndex + 1 == totalQuestions {
           
            await dataController.completeSection(section: section)
            
            print("Answered question index is \(answeredQuestionIndex), number of questions is \(totalQuestions)")
            
            await MainActor.run {
                submitForm()
                
                DispatchQueue.global(qos: .background).async {
                    Mixpanel.mainInstance().track(event: "Completed section")
                }
            }
        }
        
    }
    
    private func submitForm() {
        if isFocused {
            isFocused = false
        }
        
        if selectedTab < 1 {
            selectedTab += 1
        }
    }
    
    private func completeSection() {
        dismiss()
        let completedSections = focusArea?.focusAreaSections.filter { $0.completed == true }.count
        if completedSections == focusArea?.focusAreaSections.count {
            DispatchQueue.global(qos: .background).async {
                Mixpanel.mainInstance().track(event: "Completed path")
            }
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
                answeredQuestionTopicText = topicText
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
            if isFocused {
                isFocused = false
            }
        }
        
        //reset the value of @State vars managing answers, and custom answers for single and multi select
        topicText = ""
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
}

//#Preview {
//    UpdateSectionView()
//}

