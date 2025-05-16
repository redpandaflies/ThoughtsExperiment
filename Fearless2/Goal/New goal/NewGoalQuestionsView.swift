//
//  NewGoalQuestionsView.swift
//  Fearless2
//
//  Created by Yue Deng-Wu on 3/5/25.
//
import Mixpanel
import SwiftUI

struct NewGoalQuestionsView: View {
    @EnvironmentObject var dataController: DataController
    @ObservedObject var newGoalViewModel: NewGoalViewModel
    
    // Manage when to show alert for exiting create new category flow
    @State private var showExitFlowAlert: Bool = false
    @State private var showProgressBar: Bool = true
    
    @Binding var mainSelectedTab: Int
    @Binding var selectedQuestion: Int
    @Binding  var progressBarQuestionIndex: Int
    @Binding var questions: [QuestionNewCategory]
    // Array to store all open question answers
    @Binding var answersOpen: [String]
    // Array to store all single-select question answers
    @Binding var answersSingleSelect: [String]
    @Binding var multiSelectAnswers: [String]
    @Binding var multiSelectCustomItems: [String]
    
    @FocusState.Binding var focusField: DefaultFocusField?
    
    let exitFlowAction: () -> Void
    
    var currentQuestion: QuestionNewCategory {
        return questions[selectedQuestion]
    }
    
    var body: some View {
        VStack (spacing: 10){
            // MARK: Header
            if showProgressBar {
                QuestionsProgressBar(
                    currentQuestionIndex: $progressBarQuestionIndex,
                    totalQuestions: 5,
                    showXmark: true,
                    xmarkAction: {
                        manageDismissButtonAction()
                    },
                    showBackButton: selectedQuestion > 0,
                    backAction: handleBackButton
                )
            }
            // MARK: Title
            if selectedQuestion > 0 {
                getTitle()
            }
               
            // MARK: Question
            switch currentQuestion.questionType {
                case .open:
                    QuestionOpenView2(
                        topicText: $answersOpen[selectedQuestion],
                        focusField: $focusField,
                        focusValue: .question(selectedQuestion),
                        question: currentQuestion.content,
                        placeholderText: "For best results, be very specific."
                    )
                
                case .multiSelect:
                    QuestionMultiSelectView(
                        multiSelectAnswers: $multiSelectAnswers,
                        customItems: $multiSelectCustomItems,
                        showProgressBar: $showProgressBar,
                        question: currentQuestion.content,
                        items: currentQuestion.options ?? [],
                        itemsEdited: !multiSelectCustomItems.isEmpty
                    )
       
                default:
                    QuestionSingleSelectView(
                        singleSelectAnswer: $answersSingleSelect[selectedQuestion],
                        showProgressBar: $showProgressBar,
                        question: currentQuestion.content,
                        items: currentQuestion.options ?? [],
                        subTitle: selectedQuestion == 0 ? "Choose your primary goal" : "",
                        showSymbol: selectedQuestion == 0 ? true : false
                    )
                    
            }
            
        }//VStack
        .padding(.bottom)
        .alert("Discard new topic?", isPresented: $showExitFlowAlert) {
            Button("Cancel", role: .cancel) {}
            Button("Yes", role: .destructive) {
                if focusField != nil {
                    focusField = nil
                }
                exitFlowAction()
            }
        } message: {
            Text("You'll lose your progress.")
        }
    }
    
    private func getTitle() -> some View {
        HStack (spacing: 5){
            Text(answersSingleSelect[0])
                .font(.system(size: 19, weight: .light).smallCaps())
                .fontWidth(.condensed)
                .foregroundStyle(AppColors.textPrimary.opacity(0.7))
            
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        
    }

    private func manageDismissButtonAction() {
        if !answersOpen[1].isEmpty {
            showExitFlowAlert = true
        } else {
            if focusField != nil {
                focusField = nil
            }
            
            exitFlowAction()
        }
        
        DispatchQueue.global(qos: .background).async {
            Mixpanel.mainInstance().track(event: "Closed new topic flow")
        }
    }
    
    // MARK: - Handle the back button action
    private func handleBackButton() {
        let answeredQuestionIndex = selectedQuestion
        
        if answeredQuestionIndex > 0 {
            // Go back one question
            navigateToPreviousQuestion()
        }
    }
    
    
    private func navigateToPreviousQuestion() {
        focusField = nil
        selectedQuestion -= 1
        withAnimation(.interpolatingSpring) {
            progressBarQuestionIndex -= 1
        }
    }

}

//#Preview {
//    NewCategoryQuestionsView()
//}
