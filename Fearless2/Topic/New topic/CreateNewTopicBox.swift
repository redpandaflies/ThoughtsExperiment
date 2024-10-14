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

    let selectedCategory: CategoryItem
    
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
                    QuestionScaleView(selectedValue: $selectedValue, question: QuestionsNewDecision.questions[selectedQuestion].question, minLabel: minLabel, maxLabel: maxLabel)
                }
            case .multiSelect:
                if let options = QuestionsNewDecision.questions[selectedQuestion].options {
                    QuestionMultiSelectView(selectedOptions: $selectedOptions, question: QuestionsNewDecision.questions[selectedQuestion].question, items: options)
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
            answeredQuestionSelectedValue = selectedValue
        case .scale:
            answeredQuestionTopicText = topicText
            
        default:
            answeredQuestionSelectedOptions = selectedOptions
        }
        
        //move to next question
        if selectedQuestion < 6 {
            selectedQuestion += 1
        } else {
            // Handle completion if needed
            
        }
        selectedValue = 5.0
        topicText = ""
        
        //save answers
        Task {
            switch answeredQuestion.questionType {
            case .open:
                if let topicText = answeredQuestionTopicText {
                    await dataController.createTopic(userAnswer: topicText)
                }
            case .scale:
                if let selectedValue = answeredQuestionSelectedValue {
                    await dataController.saveScaleAnswer(question: answeredQuestion.question, userAnswer: selectedValue)
                }
            case .multiSelect:
                if let selectedOptions = answeredQuestionSelectedOptions {
                    await dataController.saveMultiSelectAnswer(question: answeredQuestion.question, userAnswers: selectedOptions)
                }
            }
        
        }
            
    }
    
    func submitForm() async {
        isFocused = false
        
        withAnimation(.snappy(duration: 0.2)) {
            self.showCard = false
        }
        selectedTab += 1
       
       await topicViewModel.manageRun(selectedAssistant: .topic, category: selectedCategory, userInput: topicText)
    }
}

//#Preview {
//    CreateNewTopicBox()
//}
