//
//  OnboardingQuestionsView.swift
//  Fearless2
//
//  Created by Yue Deng-Wu on 2/25/25.
//
import Mixpanel
import SwiftUI

enum NewCategoryFocusField: Hashable {
    case none
    case question(Int)
}

struct OnboardingQuestionsView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var dataController: DataController
    
    @State private var selectedQuestion: Int = 0
    @State private var progressBarQuestionIndex: Int = 0
    @State private var answerSingleSelect: String = ""
    @State private var questions: [QuestionsNewCategory] = QuestionsNewCategory.initialQuestionsOnboarding
    
    // Array to store all open question answers
    @State private var answersOpen: [String] = Array(repeating: "", count: 4)
    
    @Binding var selectedCategory: String
    @Binding var selectedIntroPage: Int
    @Binding var imagesScrollPosition: Int?
    
    var currentQuestion: QuestionsNewCategory {
        return questions[selectedQuestion]
    }
    
    @FocusState var focusField: NewCategoryFocusField?
    
    var body: some View {
        VStack (spacing: 10){
            // MARK: Header
            QuestionsProgressBar(
                currentQuestionIndex: $progressBarQuestionIndex, 
                totalQuestions: 4, 
                showBackButton: selectedQuestion > 0,
                backAction: handleBackButton
            )
                
            // MARK: Title
            getTitle()
               
            // MARK: Question
            switch currentQuestion.questionType {
                case .open:
                
                    NewCategoryQuestionOpenView(
                        topicText: $answersOpen[selectedQuestion],
                        focusField: $focusField,
                        focusValue: .question(selectedQuestion),
                        question: currentQuestion.content,
                        placeholderText: selectedQuestion == 0 ? "Enter your name" : "For best results, be very specific.",
                        disableNewLine: selectedQuestion == 0
                    )
                                
                
                default:
                    if selectedQuestion == 1 {
                        QuestionSingleSelectView(singleSelectAnswer: $selectedCategory, question: currentQuestion.content, items: currentQuestion.options ?? [])
                           
                    } else {
                        QuestionSingleSelectView(singleSelectAnswer: $answerSingleSelect, question: currentQuestion.content, items: currentQuestion.options ?? [])
                            
                    }
            }
           
            
            Spacer()
            
            // MARK: Next button
            RectangleButtonPrimary(
                buttonText: "Continue",
                action: {
                    nextButtonAction()
                },
                disableMainButton: disableButton(),
                buttonColor: .white
            )
        }
        .padding(.horizontal)
        .padding(.bottom)
        .background {
            BackgroundPrimary(backgroundColor: AppColors.backgroundOnboardingIntro)
        }
    }
    
    private func getTitle() -> some View {
        HStack (spacing: 5){
            
            switch selectedQuestion {
            case 0:
                Text("👀")
                    .font(.system(size: 40, design: .serif))
            case 1:
                Text("🛌")
                    .font(.system(size: 40, design: .serif))
            default:
                Text(Realm.getEmoji(forLifeArea: selectedCategory))
                    .font(.system(size: 19, weight: .light))
                    .fontWidth(.condensed)
                
                Text(selectedCategory)
                    .font(.system(size: 19, weight: .light).smallCaps())
                    .fontWidth(.condensed)
                    .foregroundStyle(AppColors.textPrimary.opacity(0.7))
            }
           
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        
    }
    
    private func disableButton() -> Bool {
      
        switch currentQuestion.questionType {
        case .open:
            return answersOpen[selectedQuestion].isEmpty
        default:
            if selectedQuestion == 1 {
                return selectedCategory.isEmpty
            } else {
                return answerSingleSelect.isEmpty
            }
        }
    }
    

    
    // MARK: - Next question
    private func nextButtonAction() {
        // Capture current state
        let answeredQuestionIndex = selectedQuestion
        let answeredQuestion = currentQuestion
        
        var answeredQuestionOpen: String?
        
        switch answeredQuestion.questionType {
        case .open:
            answeredQuestionOpen = answersOpen[answeredQuestionIndex]
          
        default:
            break
        }
        
        // Process the answer based on question index
        Task {
            await processAnswerForQuestion(index: answeredQuestionIndex, openAnswer: answeredQuestionOpen)
        }
        
        // Update UI state and navigation
        handleUIAndNavigation(answeredQuestionIndex: answeredQuestionIndex)
        
        // Track analytics
        trackAnalyticsForQuestionCompletion(questionIndex: answeredQuestionIndex)
    }

    private func processAnswerForQuestion(index: Int, openAnswer: String? = nil) async {
        if index == 0 {
            await dataController.saveUserName(name: openAnswer ?? "")
        } else if index == 3 {
            await saveAnswersForCategory()
        }
    }

   
    private func saveAnswersForCategory() async {
        // Create category
        let savedCategory = await dataController.createSingleCategory(lifeArea: selectedCategory)
        
        if let category = savedCategory {
            
            // Save the answers for questions about the category selected
            for (index, answer) in answersOpen.enumerated() where !answer.isEmpty {
                // Skip the single-select question (index 1)
                if index != 1 && index > 0 {
                    await dataController.saveAnswerOnboarding(
                        questionType: .open,
                        question: questions[index],
                        userAnswer: answer,
                        categoryLifeArea: selectedCategory,
                        category: category
                    )
                }
            }
            // Create first set of topics for the realm based on a quest map
            await dataController.createTopics(questMap: QuestMapItem.questMap1, category: category)
        }
    }

    private func handleUIAndNavigation(answeredQuestionIndex index: Int) {
        if index < 3 {
            clearCurrentAnswerIfNeeded(answeredQuestionIndex: index)
            navigateToNextQuestion()
            updateFocusState(answeredQuestionIndex: index)
        } else {
            finishOnboarding()
        }
    }

    private func clearCurrentAnswerIfNeeded(answeredQuestionIndex index: Int) {
        if index == 0 {
            focusField = nil
        }
    }

    private func navigateToNextQuestion() {
        selectedQuestion += 1
        withAnimation(.interpolatingSpring) {
            progressBarQuestionIndex += 1
        }
    }

    private func updateFocusState(answeredQuestionIndex index: Int) {
        if index >= 2 {
            focusField = .question(index + 1)
        }
    }

    private func finishOnboarding() {
        focusField = nil
        
        dismiss()
        
        withAnimation {
            selectedIntroPage += 1
            imagesScrollPosition = (imagesScrollPosition ?? 0) + 1
        }
    }

    private func trackAnalyticsForQuestionCompletion(questionIndex index: Int) {
        if index == 3 {
            DispatchQueue.global(qos: .background).async {
                Mixpanel.mainInstance().track(event: "Completed onboarding questions")
                Mixpanel.mainInstance().track(event: "Discovered new realm: \(selectedCategory)")
            }
        } else if index == 0 {
            let mixpanelService = MixpanelService(dataController: dataController)
            Task {
                await mixpanelService.setupMixpanelTracking()
                Mixpanel.mainInstance().track(event: "Finished static onboarding")
            }
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
