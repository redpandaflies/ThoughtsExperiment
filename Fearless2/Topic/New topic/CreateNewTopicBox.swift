//
//  CreateNewTopicBox.swift
//  Fearless2
//
//  Created by Yue Deng-Wu on 10/3/24.
//

import SwiftUI

struct CreateNewTopicBox: View {
    @EnvironmentObject var dataController: DataController
    @ObservedObject var topicViewModel: TopicViewModel
    @State private var selectedQuestion: Int = 0
    @State private var topicText: String = ""//user's definition of the new topic
    @State private var selectedValue: Double = 5.0 //value user selects on the slider
    @State private var selectedOptions: [String] = [] //answers user choose for muti-select questions
    @State private var currentQuestionIndex = 0 //for the progress bar
    @Binding var showCard: Bool
    @Binding var selectedTab: Int
    @FocusState var isFocused: Bool
    
    let selectedCategory: TopicCategoryItem
    
    var body: some View {
        
        VStack {
            VStack (alignment: .leading, spacing: 5) {
                
                Text(selectedCategory.getFullName())
                    .multilineTextAlignment(.leading)
                    .font(.system(size: 11, weight: .regular))
                    .foregroundStyle(selectedCategory.getCategoryColor())
                    .textCase(.uppercase)
                
                switch QuestionsNewTopic.questions[selectedQuestion].questionType {
                case .open:
                    QuestionOpenView(topicText: $topicText, selectedQuestion: $selectedQuestion, isFocused: $isFocused, question: QuestionsNewTopic.questions[selectedQuestion].content)
                case .scale:
                    if let minLabel = QuestionsNewTopic.questions[selectedQuestion].minLabel,
                       let maxLabel = QuestionsNewTopic.questions[selectedQuestion].maxLabel {
                        QuestionScaleView(selectedValue: $selectedValue, selectedCategory: selectedCategory, question: QuestionsNewTopic.questions[selectedQuestion].content, minLabel: minLabel, maxLabel: maxLabel)
                    }
                case .multiSelect:
                    if let options = QuestionsNewTopic.questions[selectedQuestion].options {
                        QuestionMultiSelectView(selectedOptions: $selectedOptions, question: QuestionsNewTopic.questions[selectedQuestion].content, items: options)
                    }
                }
                
                Spacer()
                
            }//VStack
            .padding()
            .padding(.top)
            .frame(height: 340)
            .background {
                RoundedRectangle(cornerRadius: 20)
                    .fill(AppColors.questionBoxBackground)
                    .shadow(color: .black.opacity(0.07), radius: 3, x: 0, y: 1)
            }
            
            QuestionsProgressBar(currentQuestionIndex: $currentQuestionIndex, questionCount: QuestionsNewTopic.questions.count, action: { saveAnswer()})
            
            
        }//VStack
        
    }
    
    private func saveAnswer() {
        //capture current state
        let answeredQuestionIndex = selectedQuestion
        let totalQuestions = QuestionsNewTopic.questions.count
        let answeredQuestion = QuestionsNewTopic.questions[answeredQuestionIndex]
        
        var answeredQuestionSelectedValue: Double?
        var answeredQuestionTopicText: String?
        var answeredQuestionSelectedOptions: [String]?
        
        switch answeredQuestion.questionType {
        case .open:
            isFocused = false
            answeredQuestionTopicText = topicText
        case .scale:
            answeredQuestionSelectedValue = selectedValue
        case .multiSelect:
            answeredQuestionSelectedOptions = selectedOptions
        }
        
        //move to next question
        if selectedQuestion + 1 < totalQuestions {
            selectedQuestion += 1
            currentQuestionIndex += 1
        } else {
            submitForm()
        }
        
        
        selectedValue = 5.0
        topicText = ""
        
        //save answers
        Task {
            switch answeredQuestion.questionType {
            case .open:
                if let newTopicText = answeredQuestionTopicText {
                    await dataController.saveAnswer(questionType: .open, questionContent: answeredQuestion.content, userAnswer: newTopicText)
                }
            case .scale:
                if let newSelectedValue = answeredQuestionSelectedValue {
                    
                    await dataController.saveAnswer(questionType: .scale, questionContent: answeredQuestion.content, userAnswer: newSelectedValue)
                }
            case .multiSelect:
                if let newSelectedOptions = answeredQuestionSelectedOptions {
                    if answeredQuestionIndex == 0 {
                        await dataController.createTopic(category: selectedCategory)
                    }
                    
                    await dataController.saveAnswer(questionType: .multiSelect, questionContent: answeredQuestion.content, userAnswer: newSelectedOptions)
                }
            }
            
            print("SelectedQuestion: \(selectedQuestion)")
            
            if answeredQuestionIndex + 1 == totalQuestions {
                await dataController.save()
                
                print("Answered question index is 6")
                if let topicId = dataController.newTopic?.topicId {
                    print("Creating new topic, sending to context assistant")
                    await topicViewModel.manageRun(selectedAssistant: .focusArea, category: selectedCategory, topicId: topicId)
                }
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
//    CreateNewTopicBox()
//}
