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
    @Binding var showCard: Bool
    @Binding var selectedTab: Int
    @FocusState var isFocused: Bool

    let selectedCategory: TopicCategoryItem
    
    var body: some View {
        VStack (alignment: .leading, spacing: 10) {
            HStack {
                BubblesCategory(selectedCategory: selectedCategory, useFullName: true)
                
                Spacer()
            }
            
            Text(selectedCategory.getDescription())
                .multilineTextAlignment(.leading)
                .font(.system(size: 13))
                .fontWeight(.regular)
                .foregroundStyle(AppColors.blackDefault)
                .padding(.bottom, 5)
            
            Divider()
            
            switch QuestionsNewDecision.questions[selectedQuestion].questionType {
            case .open:
                QuestionOpenView(topicText: $topicText, selectedQuestion: $selectedQuestion, isFocused: $isFocused, selectedCategory: selectedCategory)
            case .scale:
                if let minLabel = QuestionsNewDecision.questions[selectedQuestion].minLabel,
                   let maxLabel = QuestionsNewDecision.questions[selectedQuestion].maxLabel {
                    QuestionScaleView(selectedValue: $selectedValue, question: QuestionsNewDecision.questions[selectedQuestion].content, minLabel: minLabel, maxLabel: maxLabel)
                }
            case .multiSelect:
                if let options = QuestionsNewDecision.questions[selectedQuestion].options {
                    QuestionMultiSelectView(selectedOptions: $selectedOptions, question: QuestionsNewDecision.questions[selectedQuestion].content, items: options)
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
        let answeredQuestionIndex = selectedQuestion
        let answeredQuestion = QuestionsNewDecision.questions[answeredQuestionIndex]
        
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
        if selectedQuestion < 6 {
            selectedQuestion += 1
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
                    await dataController.createTopic(userAnswer: newTopicText)
                }
            case .scale:
                if let newSelectedValue = answeredQuestionSelectedValue {
                    await dataController.saveAnswer(questionType: .scale, questionContent: answeredQuestion.content, userAnswer: newSelectedValue)
                }
            case .multiSelect:
                if let newSelectedOptions = answeredQuestionSelectedOptions {
                    await dataController.saveAnswer(questionType: .multiSelect, questionContent: answeredQuestion.content, userAnswer: newSelectedOptions)
                }
            }
            
            print("SelectedQuestion: \(selectedQuestion)")
            
            if answeredQuestionIndex == 6 {
                print("Answered question index is 6")
                if let topicId = dataController.newTopic?.topicId {
                    print("Creating new topic, sending to context assistant")
                    await topicViewModel.manageRun(selectedAssistant: .context, category: selectedCategory, topicId: topicId)
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
