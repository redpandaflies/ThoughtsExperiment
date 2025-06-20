//
//  UpdateTopicQuestionsView.swift
//  Fearless2
//
//  Created by Yue Deng-Wu on 4/24/25.
//

import SwiftUI

struct UpdateTopicQuestionsView: View {
   
    @Binding var showProgressBar: Bool
    @Binding var selectedQuestion: Int
    @Binding var answersOpen: [String]
    @Binding var singleSelectAnswer: String
    @Binding var multiSelectAnswers: [String]
    @Binding var singleSelectCustomItems: [String]
    @Binding var multiSelectCustomItems: [String]

    @FocusState.Binding var focusField: DefaultFocusField?

    let topic: TopicRepresentable
    var questions: FetchedResults<Question>
    let isDailyTopic: Bool
    let mainFlowQuestionsCount: Int
    let placeholderTextSingleSelect: String
    
    /// in daily topics flow, need to know this so the heading doesn't show up for the static questions
//    var mainFlowQuestionsCount: Int {
//        let totalQuestions = questions.count
//        let staticQuestions = NewQuestion.questionsDailyTopic.count
//        return max(totalQuestions - staticQuestions, 0)
//    }

    init(
        showProgressBar: Binding<Bool>,
        selectedQuestion: Binding<Int>,
        answersOpen: Binding<[String]>,
        singleSelectAnswer: Binding<String>,
        multiSelectAnswers: Binding<[String]>,
        singleSelectCustomItems: Binding<[String]>,
        multiSelectCustomItems: Binding<[String]>,
        focusField: FocusState<DefaultFocusField?>.Binding,
        topic: TopicRepresentable,
        questions: FetchedResults<Question>,
        isDailyTopic: Bool = false,
        mainFlowQuestionsCount: Int = 0,
        placeholderTextSingleSelect: String = "Add your own"
    ) {
        self._showProgressBar = showProgressBar
        self._selectedQuestion = selectedQuestion
        self._answersOpen = answersOpen
        self._singleSelectAnswer = singleSelectAnswer
        self._multiSelectAnswers = multiSelectAnswers
        self._singleSelectCustomItems = singleSelectCustomItems
        self._multiSelectCustomItems = multiSelectCustomItems
        self._focusField = focusField
        self.topic = topic
        self.questions = questions
        self.isDailyTopic = isDailyTopic
        self.mainFlowQuestionsCount = mainFlowQuestionsCount
        self.placeholderTextSingleSelect = placeholderTextSingleSelect
    }
    
    var body: some View {
            
        VStack (alignment: .leading, spacing: 5) {
            
            
            if selectedQuestion < mainFlowQuestionsCount && isDailyTopic {
            
                HStack (spacing: 5) {

                    Text(topic.topicEmoji)
                        .multilineTextAlignment(.leading)
                        .font(.system(size: 19, weight: .light).smallCaps())

                    Text(topic.topicTitle)
                        .multilineTextAlignment(.leading)
                        .font(.system(size: 19, weight: .light).smallCaps())
                        .fontWidth(.condensed)
                        .foregroundStyle(AppColors.textPrimary.opacity(0.8))
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            
            if let questionType = QuestionType(rawValue: questions[selectedQuestion].questionType) {
               
                let currentQuestion = questions[selectedQuestion]
                
                switch questionType {
                    
                    case .singleSelect:
                        let optionsString = currentQuestion.questionSingleSelectOptions
                        let optionsArray = optionsString.components(separatedBy: ";")
                    QuestionSingleSelectView(singleSelectAnswer: $singleSelectAnswer, customItems: $singleSelectCustomItems, showProgressBar: $showProgressBar, question: currentQuestion.questionContent, items: optionsArray, answer: currentQuestion.questionAnswerSingleSelect, itemsEdited: currentQuestion.editedSingleSelect, placeholderText: placeholderTextSingleSelect)
                        
                    case .multiSelect:
                        let optionsString = currentQuestion.questionMultiSelectOptions
                        let optionsArray = optionsString.components(separatedBy: ";")
                    QuestionMultiSelectView(
                        multiSelectAnswers: $multiSelectAnswers,
                        customItems: $multiSelectCustomItems,
                        showProgressBar: $showProgressBar,
                        question: currentQuestion.questionContent,
                        items: optionsArray,
                        answers: currentQuestion.questionAnswerMultiSelect,
                        itemsEdited: currentQuestion.editedMultiSelect
                    )
                    
                    default:
                    QuestionOpenView2 (
                        topicText: $answersOpen[selectedQuestion],
                        focusField: $focusField,
                        focusValue: .question(selectedQuestion),
                        question: currentQuestion.questionContent,
                        placeholderText: "Type your answer",
                        answer: currentQuestion.questionAnswerOpen
                    )
                }
            }
            
            
            
        }//VStack
        .frame(maxHeight: .infinity, alignment: .topLeading)
        
    }
}

