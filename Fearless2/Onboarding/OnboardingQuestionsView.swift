//
//  OnboardingQuestionsView.swift
//  Fearless2
//
//  Created by Yue Deng-Wu on 2/25/25.
//
import Mixpanel
import SwiftUI

struct OnboardingQuestionsView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var dataController: DataController
    
    @State private var selectedQuestion: Int = 0
    @State private var progressBarQuestionIndex: Int = 0
    @State private var answerOpenQ1: String = ""
    @State private var answerOpenQ2: String = ""
    @State private var answerSingleSelect: String = ""
    @State private var questions: [QuestionsNewCategory] = QuestionsNewCategory.initialQuestionsOnboarding
    
    // Track answers for each question
    @State private var savedAnswers: [Int: String] = [:]
    
    @Binding var selectedCategory: String
    @Binding var selectedIntroPage: Int
    @Binding var imagesScrollPosition: Int?
    
    var currentQuestion: QuestionsNewCategory {
        return questions[selectedQuestion]
    }
    
    @FocusState var isFocused: Bool
    
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
                QuestionOpenView(
                    topicText: selectedQuestion == 3 ? $answerOpenQ2 : $answerOpenQ1,
                    isFocused: $isFocused,
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
                return selectedQuestion == 3 ? answerOpenQ2.isEmpty : answerOpenQ1.isEmpty
            default:
                if selectedQuestion == 1 {
                    return selectedCategory.isEmpty
                } else {
                    return answerSingleSelect.isEmpty
                }
            }
        
    
    }
    
    // Handle the back button action
    private func handleBackButton() {
        let answeredQuestionIndex = selectedQuestion
        
        if answeredQuestionIndex > 0 {
            // Save current answer before going back
            saveCurrentAnswer(index: answeredQuestionIndex)
            
            // Go back one question
            if isFocused {
                isFocused = false
            }
            selectedQuestion -= 1
            withAnimation(.interpolatingSpring) {
                progressBarQuestionIndex -= 1
            }
            
            // Restore previous answer
            restorePreviousAnswer()
        }
    }
    
    // Save the current answer to our in-memory dictionary
    private func saveCurrentAnswer(index: Int) {
        switch currentQuestion.questionType {
        case .open:
            if selectedQuestion == 2 {
                savedAnswers[index] = answerOpenQ2
            } else {
                savedAnswers[index] = answerOpenQ1
            }
        case .singleSelect, .multiSelect:
            if selectedQuestion == 1 {
                savedAnswers[index] = selectedCategory
            } else {
                savedAnswers[index] = answerSingleSelect
            }
        }
    }
    
    // Restore a previously saved answer
    private func restorePreviousAnswer() {
        // Get the answer for the current question (after moving back)
        if let savedAnswer = savedAnswers[selectedQuestion] {
            switch questions[selectedQuestion].questionType {
            case .open:
                if selectedQuestion == 3 {
                    answerOpenQ2 = savedAnswer
                } else {
                    answerOpenQ1 = savedAnswer
                }
                
            case .singleSelect, .multiSelect:
                if selectedQuestion == 1 {
                    selectedCategory = savedAnswer
                } else {
                    answerSingleSelect = savedAnswer
                }
            }
        }
    }
    
    private func nextButtonAction() {
        //capture current state
        let answeredQuestionIndex = selectedQuestion
        let answeredQuestion = currentQuestion
        
        var answeredQuestionOpen: String?
        
        switch answeredQuestion.questionType {
        case .open:
            
            if selectedQuestion == 3 {
                answeredQuestionOpen = answerOpenQ2
            } else {
                answeredQuestionOpen = answerOpenQ1
            }
          
        default:
            break
        }
        
        // Save the current answer to in-memory dictionary
        saveCurrentAnswer(index: answeredQuestionIndex)

        //Save question answer
        Task {
            if answeredQuestionIndex == 0 {
                await dataController.saveUserName(name: answeredQuestionOpen ?? "")
            }
    
            //add the selected category to coredata
            if answeredQuestionIndex == 3 {
                //create category
                let savedCategory = await dataController.createSingleCategory(lifeArea: selectedCategory)
                
//                print("Saved answers: \(savedAnswers)")
                
                //save the answers for questions about the category selected
                for (key, value) in savedAnswers where key > 1 {
                    if let category = savedCategory {
                        await dataController.saveAnswerOnboarding(
                            questionType: .open,
                            question: questions[key],
                            userAnswer: value,
                            categoryLifeArea: selectedCategory,
                            category: category
                        )
                    }
                }
            }
            
        }
        
        // Only clear answerOpen if we're not restoring a previously saved answer
        if selectedQuestion < 3 {
            
            if answeredQuestionIndex == 0 {
                if isFocused {
                    isFocused = false
                }
            }
            
            answerOpenQ1 = ""
            answerOpenQ2 = ""
            
            //navigate to the next question
            selectedQuestion += 1
            withAnimation(.interpolatingSpring) {
                progressBarQuestionIndex += 1
            }
            
            restorePreviousAnswer()
            
            if selectedQuestion == 2 {
                isFocused = true
            }
   
        } else {
            
            if isFocused {
                isFocused = false
            }
            
            dismiss()
            
            withAnimation {
                selectedIntroPage += 1
                imagesScrollPosition = (imagesScrollPosition ?? 0) + 1
            }
            
        }
        
        if answeredQuestionIndex == 3 {
            DispatchQueue.global(qos: .background).async {
                Mixpanel.mainInstance().track(event: "Completed onboarding questions")
                Mixpanel.mainInstance().track(event: "Discovered new realm: \(selectedCategory)")
            }
        }
        
        if answeredQuestionIndex == 0 {
            let mixpanelService = MixpanelService(dataController: dataController)
            Task {
                await mixpanelService.setupMixpanelTracking()
                Mixpanel.mainInstance().track(event: "Finished static onboarding") //this is here & not earlier in the onboarding flow because we need to create the user profile for mixpanel before sending an event
            }
        }
    }
}
