//
//  UpdateTopicBox.swift
//  Fearless2
//
//  Created by Yue Deng-Wu on 10/3/24.
//

import SwiftUI

struct UpdateTopicBox: View {
    @EnvironmentObject var dataController: DataController
    @ObservedObject var topicViewModel: TopicViewModel
    @State private var selectedQuestion: Int = 0
    @State private var topicText: String = ""//user's definition of the new topic
    @State private var selectedValue: Double = 5.0 //value user selects on the slider
    @State private var selectedOptions: [String] = [] //answers user choose for muti-select questions
    @Binding var showCard: Bool
    @Binding var selectedTab: Int
    @FocusState var isFocused: Bool

    let selectedCategory: TopicCategoryItem
    let section: Section?
    let questions: [Question]
    
    var body: some View {
        VStack (alignment: .leading, spacing: 10) {
            HStack {
                BubblesCategory(selectedCategory: selectedCategory, useFullName: true)
                
                Spacer()
            }
            
            Text(section?.sectionTitle ?? "")
                .multilineTextAlignment(.leading)
                .font(.system(size: 13))
                .fontWeight(.regular)
                .foregroundStyle(AppColors.blackDefault)
                .padding(.bottom, 5)
            
            Divider()
            
            if let questionType = QuestionType(rawValue: questions[selectedQuestion].questionType) {
                let currentQuestion = questions[selectedQuestion]
                switch questionType {
                    
                case .open:
                    QuestionOpenView(topicText: $topicText, selectedQuestion: $selectedQuestion, isFocused: $isFocused, selectedCategory: selectedCategory, question: currentQuestion.questionContent)
                    
                case .scale:
                    let minLabel = currentQuestion.questionMinLabel
                    let maxLabel = currentQuestion.questionMaxLabel
                    QuestionScaleView(selectedValue: $selectedValue, question: currentQuestion.questionContent, minLabel: minLabel, maxLabel: maxLabel)
                    
                case .multiSelect:
                    let optionsString = currentQuestion.questionMultiSelectOptions
                    let optionsArray = optionsString.components(separatedBy: ",")
                    QuestionMultiSelectView(selectedOptions: $selectedOptions, question: currentQuestion.questionContent, items: optionsArray)
                    
                }
            }
            
            HStack {
                
                Spacer()
                
                Button {
                    
                    saveAnswer()
                    
                } label: {
                    Image(systemName: "arrow.right.circle.fill")
                        .font(.system(size: 40))
                        .foregroundStyle(AppColors.blackDefault)
                }
            }
        }
        .padding()
        .background {
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.white)
                .shadow(color: .black.opacity(0.07), radius: 3, x: 0, y: 1)
              
        }
        
    }
    
    private func saveAnswer() {
        //capture current state
        guard let currentSection = section else { return }
        let answeredQuestionIndex = selectedQuestion
        let answeredQuestion = questions[answeredQuestionIndex]
        let numberOfQuestions = questions.count
        
        var answeredQuestionSelectedValue: Double?
        var answeredQuestionTopicText: String?
        var answeredQuestionSelectedOptions: [String]?
        
        if let answeredQuestionType =  QuestionType(rawValue: answeredQuestion.questionType){
            switch answeredQuestionType {
            case .open:
                isFocused = false
                answeredQuestionTopicText = topicText
            case .scale:
                answeredQuestionSelectedValue = selectedValue
            case .multiSelect:
                answeredQuestionSelectedOptions = selectedOptions
            }
        }
       
        
        //move to next question
        if selectedQuestion + 1 < numberOfQuestions {
            selectedQuestion += 1
        } else {
           submitForm()
        }
        
        selectedValue = 5.0
        topicText = ""
        
        //save answers
        Task {
            
            if let answeredQuestionType =  QuestionType(rawValue: answeredQuestion.questionType){
                switch answeredQuestionType {
                case .open:
                    if let newTopicText = answeredQuestionTopicText {
                        await dataController.saveAnswer(questionType: .open, questionId: answeredQuestion.questionId, userAnswer: newTopicText)
                    }
                case .scale:
                    if let newSelectedValue = answeredQuestionSelectedValue {
                        await dataController.saveAnswer(questionType: .scale, questionId: answeredQuestion.questionId, userAnswer: newSelectedValue)
                    }
                case .multiSelect:
                    if let newSelectedOptions = answeredQuestionSelectedOptions {
                        await dataController.saveAnswer(questionType: .multiSelect, questionId: answeredQuestion.questionId, userAnswer: newSelectedOptions)
                    }
                }
            }
            
            print("SelectedQuestion: \(selectedQuestion)")
            
            if answeredQuestionIndex + 1 == numberOfQuestions {
                print("Answered question index is \(answeredQuestionIndex), number of questions is \(numberOfQuestions)")
                await topicViewModel.manageRun(selectedAssistant: .sectionSummary, category: selectedCategory, section: currentSection)
            }
        }
            
    }
    
    private func submitForm() {
        isFocused = false
        
        withAnimation(.snappy(duration: 0.2)) {
            self.showCard = false
        }
        selectedTab += 1

    }
    
}

//#Preview {
//    UpdateTopicBox()
//}
