//
//  NewTopicView.swift
//  Fearless2
//
//  Created by Yue Deng-Wu on 10/1/24.
//

import SwiftUI

struct NewTopicView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var dataController: DataController
    @ObservedObject var topicViewModel: TopicViewModel
    @State private var selectedTab: Int = 0
    @State private var selectedQuestion: Int = 0
    @State private var topicText: String = ""//user's definition of the new topic
    @State private var answer1: String = ""//user's answer to the first question
    @State private var singleSelectAnswer: String = "" //single-select answer
    @State private var multiSelectAnswers: [String] = [] //answers user choose for muti-select questions
    @State private var activeIndex: Int? = nil //controls the state of the loading view
    
    @FocusState var isFocused: Bool
    
    @Binding var selectedTopic: Topic?
    @Binding var navigateToTopicDetailView: Bool
    @Binding var currentTabBar: TabBarType
    
    var body: some View {
        VStack {
            
            NewTopicHeader(xmarkAction: {
                cancelEntry()
            })
           
            switch selectedTab {
                case 0:
                    NewTopicBox(selectedQuestion: $selectedQuestion, topicText: $topicText, singleSelectAnswer: $singleSelectAnswer, multiSelectAnswers: $multiSelectAnswers, isFocused: $isFocused)
                        .padding(.top)
        
                case 1:
                    NewTopicLoadingView(activeIndex: $activeIndex)
                    
                default:
                    NewTopicReadyView()
                
            }
           
            
            RectangleButtonYellow(
                buttonText: getButtonText(),
                action: {
                    getMainButtonAction()
                },
                showChevron: (selectedTab == 2),
                showBackButton: (selectedTab == 0 && selectedQuestion == 1),
                backAction: {
                    backButtonAction()
                },
                disableMainButton: (selectedTab == 1)
            )
            
        }
        .padding()
        .environment(\.colorScheme, .dark)
        .onChange(of: topicViewModel.topicUpdated) {
            if topicViewModel.topicUpdated {
                if activeIndex == 1 {
                    activeIndex = 2
                } else {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                        activeIndex = 2
                    }
                }
                
                withAnimation(.snappy(duration: 0.2)) {
                    selectedTab += 1
                }
            }
        }
    }
    
    private func cancelEntry() {
        Task {
            if let topicId = dataController.newTopic?.topicId {
                await self.dataController.deleteTopic(id: topicId)
            }
        }
        
        dismiss()
    }
    
    private func getButtonText() -> String {
        switch selectedTab {
        case 0:
            if selectedQuestion == 0 {
                return "Continue"
            } else {
                return "Start new topic"
            }
        case 1:
            return "Working on it..."
        default:
            return "Choose a starting point"
            
        }
        
    }
    
    private func getMainButtonAction() {
        switch selectedTab {
        case 0:
            saveAnswer()
        case 1:
            break
        default:
            startNewTopic()
        }
    }
    
    private func startNewTopic() {
        dismiss()
        selectedTopic = dataController.newTopic
        navigateToTopicDetailView = true
        withAnimation(.snappy(duration: 0.2)) {
            currentTabBar = .topic
        }
        dataController.newTopic = nil
    }
    
    private func backButtonAction() {
        selectedQuestion -= 1
        topicText = answer1
    }
    
    
    private func saveAnswer() {
        //capture current state
        let answeredQuestionIndex = selectedQuestion
        let totalQuestions = QuestionsNewTopic.questions.count
        let answeredQuestion = QuestionsNewTopic.questions[answeredQuestionIndex]
        
        var answeredQuestionTopicText: String?
        var answeredQuestionSingleSelect: String?
        var answeredQuestionMultiSelect: [String]?
        
        switch answeredQuestion.questionType {
            case .open:
                answeredQuestionTopicText = topicText
                if answeredQuestionIndex == 0 {
                    answer1 = topicText
                }
        case .singleSelect:
            answeredQuestionSingleSelect = singleSelectAnswer
            case .multiSelect:
            answeredQuestionMultiSelect = multiSelectAnswers
        }
        
        //move to next question
        if selectedQuestion + 1 < totalQuestions {
            selectedQuestion += 1
        } else {
            submitForm()
        }
        
        //reset the value of @State vars managing answers
        topicText = ""
        singleSelectAnswer = ""
        multiSelectAnswers = []
        
        //save answers
        Task {
            switch answeredQuestion.questionType {
            case .open:
                if let newTopicText = answeredQuestionTopicText {
                    if answeredQuestionIndex == 0 {
                        await dataController.createTopic()
                    }
                    
                    await dataController.saveAnswer(questionType: .open, questionContent: answeredQuestion.content, userAnswer: newTopicText)
                }
            case .singleSelect:
                if let newSelectedValue = answeredQuestionSingleSelect {
                    
                    await dataController.saveAnswer(questionType: .singleSelect, questionContent: answeredQuestion.content, userAnswer: newSelectedValue)
                }
            case .multiSelect:
                if let newSelectedOptions = answeredQuestionMultiSelect {
                    await dataController.saveAnswer(questionType: .multiSelect, questionContent: answeredQuestion.content, userAnswer: newSelectedOptions)
                }
            }
            
            print("SelectedQuestion: \(selectedQuestion)")
            
            if answeredQuestionIndex + 1 == totalQuestions {
                await dataController.save()
                
                if let topicId = dataController.newTopic?.topicId {
                    print("Creating new topic, sending to context assistant")
                    await topicViewModel.manageRun(selectedAssistant: .topic, topicId: topicId)
                }
            }
        }
        
    }
    
    private func submitForm() {
        if isFocused {
            isFocused = false
        }
        selectedTab = 1
    }
}


struct NewTopicReadyView: View {
    var body: some View {
        VStack (alignment: .leading, spacing: 15){
            Spacer()
            
            Text("Ready to go.")
                .font(.system(size: 25, weight: .semibold))
                .foregroundStyle(AppColors.whiteDefault)
            
            Text("Start exploring your new topic by\nchoosing a starting point.")
                .font(.system(size: 20))
                .foregroundStyle(AppColors.whiteDefault)
            
            Spacer()
        }
    }
}


//#Preview {
//    CreateNewTopicView(selectedCategory: .decision)
//}
