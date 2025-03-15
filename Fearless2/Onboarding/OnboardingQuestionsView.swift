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
    @State private var answerOpen: String = ""
    @State private var answerSingleSelect: String = ""
    @State private var questions: [QuestionsNewCategory] = QuestionsNewCategory.initialQuestionOnboarding
    
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
            QuestionsProgressBar(currentQuestionIndex: $progressBarQuestionIndex, totalQuestions: 4)
                
            // MARK: Title
            getTitle()
               
            // MARK: Question
            switch currentQuestion.questionType {
                case .open:
                QuestionOpenView(topicText: $answerOpen, isFocused: $isFocused, question: currentQuestion.content, placeholderText: selectedQuestion == 0 ? "Enter your name" : "For best results, be very specific.")
                      
                default:
                    if selectedQuestion == 1 {
                        QuestionSingleSelectView(singleSelectAnswer: $selectedCategory, question: currentQuestion.content, items: currentQuestion.options ?? [])
                           
                    } else {
                        QuestionSingleSelectView(singleSelectAnswer: $answerSingleSelect, question: currentQuestion.content, items: currentQuestion.options ?? [])
                            
                    }
            }
           
            
            Spacer()
            
            // MARK: Next button
            RectangleButtonPrimary(buttonText: "Continue", action: {
                nextButtonAction()
            }, disableMainButton: disableButton(), buttonColor: .white)
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
                return answerOpen.isEmpty
            default:
                if selectedQuestion == 1 {
                    return selectedCategory.isEmpty
                } else {
                    return answerSingleSelect.isEmpty
                }
            }
        
    
    }
    
    private func nextButtonAction() {
        //capture current state
        let answeredQuestionIndex = selectedQuestion
        let answeredQuestion = currentQuestion
        
        var answeredQuestionOpen: String?
//        var answeredQuestionSingleSelect: String?
        
        switch answeredQuestion.questionType {
        case .open:
            answeredQuestionOpen = answerOpen
        default:
//            if answeredQuestionIndex == 1 {
//                answeredQuestionSingleSelect = selectedCategory
//            } else {
//                answeredQuestionSingleSelect = answerSingleSelect
//            }
            break
        }
        
        switch answeredQuestionIndex {
        case 0:
            if isFocused {
                isFocused = false
            }
            
        case 3:
            if isFocused {
                isFocused = false
            }
            
            dismiss()
            
            withAnimation {
                selectedIntroPage += 1
                imagesScrollPosition = (imagesScrollPosition ?? 0) + 1
            }
            
            
        default:
            break
        }
        
        DispatchQueue.main.async {
            answerOpen = ""
            
            if selectedQuestion < 3 {
                
                selectedQuestion += 1
                withAnimation(.interpolatingSpring) {
                    progressBarQuestionIndex += 1
                }
            }
        }
        
        //Save question answer
        if answeredQuestionIndex != 1 {
            Task {
                switch answeredQuestion.questionType {
                
                case .open:
                    
                    if answeredQuestionIndex == 0 {
                        await dataController.saveUserName(name: answeredQuestionOpen ?? "")
                    } else {
                        await dataController.saveAnswerOnboarding(questionType: answeredQuestion.questionType, question: answeredQuestion, userAnswer: answeredQuestionOpen ?? "", categoryLifeArea: selectedCategory)
                    }
                
                default:
//                    await dataController.saveAnswerOnboarding(questionType: answeredQuestion.questionType, question: answeredQuestion, userAnswer: answeredQuestionSingleSelect ?? "", categoryLifeArea: selectedCategory)
                    break
                }
                
            }
        } else {
            //add the selected category to coredata
            Task {
                await dataController.createSingleCategory(lifeArea: selectedCategory)
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
