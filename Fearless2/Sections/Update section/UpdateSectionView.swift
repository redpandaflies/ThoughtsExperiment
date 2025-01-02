//
//  UpdateSectionView.swift
//  Fearless2
//
//  Created by Yue Deng-Wu on 10/3/24.
//
import CoreData
import SwiftUI

struct UpdateSectionView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var dataController: DataController
    @ObservedObject var topicViewModel: TopicViewModel
    
    @State private var selectedTab: Int = 0
    @State private var showWarningSheet: Bool = false
    @State private var selectedQuestion: Int = 0
    @State private var topicText: String = ""//user's definition of the new topic
    @State private var singleSelectAnswer: String = "" //single-select answer
    @State private var multiSelectAnswers: [String] = [] //answers user choose for muti-select questions
    @State private var currentQuestionIndex: Int = 0 //for the progress bar
    
    @Binding var selectedSectionSummary: SectionSummary?
    
    let topicId: UUID?
    let section: Section
    
    var questions: [Question] {
        return section.sectionQuestions.sorted { $0.questionNumber < $1.questionNumber }
    }
    
    @FocusState var isFocused: Bool
    
    init(topicViewModel: TopicViewModel, selectedSectionSummary: Binding<SectionSummary?>, topicId: UUID?, section: Section) {
        self.topicViewModel = topicViewModel
        self._selectedSectionSummary = selectedSectionSummary
        self.topicId = topicId
        self.section = section
        
        
    }
    
    var body: some View {
        
        VStack {
            
            //Header
            QuestionsProgressBar(currentQuestionIndex: $currentQuestionIndex, totalQuestions: section.sectionQuestions.count, xmarkAction: {
                dismiss()
            })
         
            
            //Question
            switch selectedTab {
            case 0:
                UpdateSectionBox(topicViewModel: topicViewModel, selectedQuestion: $selectedQuestion, topicText: $topicText, singleSelectAnswer: $singleSelectAnswer, multiSelectAnswers: $multiSelectAnswers, isFocused: $isFocused, section: section, questions: questions)
                    .padding(.top)
                    .transition(.move(edge: .bottom))
                
            default:
                LoadingAnimation()
                
            }//switch
            
            //Next button
            RectangleButtonYellow(buttonText: "Next question", action: {
                saveAnswer()
            }, showChevron: true)
            
                
        }//VStack
        .padding()
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
    
    private func saveAnswer() {
        //capture current state
        let answeredQuestionIndex = selectedQuestion
        
        let answeredQuestion = questions[answeredQuestionIndex]
        let numberOfQuestions = questions.count
        
        var answeredQuestionTopicText: String?
        var answeredQuestionSingleSelect: String?
        var answeredQuestionMultiSelect: [String]?
        
        if let answeredQuestionType =  QuestionType(rawValue: answeredQuestion.questionType){
            switch answeredQuestionType {
            case .open:
                isFocused = false
                answeredQuestionTopicText = topicText
            case .singleSelect:
                answeredQuestionSingleSelect = singleSelectAnswer
            case .multiSelect:
                answeredQuestionMultiSelect = multiSelectAnswers
            }
        }
        
        //move to next question
        if selectedQuestion + 1 < numberOfQuestions {
            selectedQuestion += 1
            currentQuestionIndex += 1
        } else {
           submitForm()
        }
        
        //reset the value of @State vars managing answers
        topicText = ""
        singleSelectAnswer = ""
        multiSelectAnswers = []
        
        //save answers
        Task {
            
            if let answeredQuestionType =  QuestionType(rawValue: answeredQuestion.questionType){
                switch answeredQuestionType {
                case .open:
                    if let newTopicText = answeredQuestionTopicText {
                        await dataController.saveAnswer(questionType: .open, questionId: answeredQuestion.questionId, userAnswer: newTopicText)
                    }
                case .singleSelect:
                    if let newSelectedValue = answeredQuestionSingleSelect {
                        await dataController.saveAnswer(questionType: .singleSelect, questionId: answeredQuestion.questionId, userAnswer: newSelectedValue)
                    }
                case .multiSelect:
                    if let newSelectedOptions = answeredQuestionMultiSelect {
                        await dataController.saveAnswer(questionType: .multiSelect, questionId: answeredQuestion.questionId, userAnswer: newSelectedOptions)
                    }
                }
            }
            
            print("SelectedQuestion: \(selectedQuestion)")
            
            if answeredQuestionIndex + 1 == numberOfQuestions {
                section.completed = true
                await dataController.save()
                
                print("Answered question index is \(answeredQuestionIndex), number of questions is \(numberOfQuestions)")
            }
        }
            
    }
    
    private func submitForm() {
        if isFocused {
            isFocused = false
        }
        
        dismiss()

    }
}

//#Preview {
//    UpdateSectionView()
//}
