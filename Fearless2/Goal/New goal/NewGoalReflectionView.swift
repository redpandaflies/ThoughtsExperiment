//
//  NewGoalReflectionView.swift
//  Fearless2
//
//  Created by Yue Deng-Wu on 4/10/25.
//
import Mixpanel
import SwiftUI

struct NewGoalReflectionView: View {
    @ObservedObject var newCategoryViewModel: NewCategoryViewModel
    @EnvironmentObject var dataController: DataController
    
    @State private var reflectionSelectedTab: Int = 0
    
    // text animation
    @State private var animator: TextAnimator?
    @State private var animatedText: String = ""
    @State private var animationCompletedText: Bool = false
    @State private var feedback: String = ""
    
    // marks loading animation complete
    @State private var animationCompletedLoading: Bool = false
    
    // LottieView
    @State private var animationSpeed: CGFloat = 1.0
    @State private var play: Bool = true
    
    @Binding var mainSelectedTab: Int
    @Binding var selectedQuestion: Int
    @Binding  var progressBarQuestionIndex: Int
    
    let loadingTexts: [String] = [
        "Going through your answers",
        "Understanding your situation",
        "Summarizing what you’ve told me"
    ]
  
    var body: some View {
        VStack {
            switch reflectionSelectedTab {
            case 0:
                //loading view
                NewGoalLoadingView(
                    texts: loadingTexts,
                    animationCompleted: $animationCompletedLoading
                )
                
            case 1:
                // reflection/summary view
                getReflection()
                    
                
           default:
                //retry
                FocusAreaRetryView(action: {
                    retryAction()
                })
            }
            
            
        }//VStack
        .onAppear {
            if reflectionSelectedTab != 0 {
                reflectionSelectedTab = 0
            }
        }
        .onChange(of: newCategoryViewModel.createNewCategorySummary) {
            if animationCompletedLoading {
                manageView()
            }
            
        }
        .onChange(of: animationCompletedLoading) {
            if animationCompletedLoading && newCategoryViewModel.createNewCategorySummary != .loading {
                manageView()
            }
        }
    }
    
   
    
    private func getReflection() -> some View {
        VStack (alignment: .leading, spacing: 10) {
            
            LottieView(
                loopMode: .playOnce,
                animationSpeed: $animationSpeed,
                play: $play
            )
            .aspectRatio(contentMode: .fit)
            .frame(width: 90, height: 90)
            .padding(.bottom, 30)
             
            
            Text("Here's what I heard:")
                .multilineTextAlignment(.leading)
                .font(.system(size: 25, design: .serif))
                .foregroundStyle(AppColors.textPrimary)
                .fixedSize(horizontal: false, vertical: true)
                .padding(.bottom, 5)
                .padding(.horizontal)

            Text(animatedText)
                .multilineTextAlignment(.leading)
                .font(.system(size: 19, design: .serif))
                .foregroundStyle(AppColors.textPrimary.opacity(0.9).opacity(0.9))
                .lineSpacing(2.0)
                .padding(.horizontal)
            
            Spacer()
            
            // next button
            RectangleButtonPrimary(
                buttonText: "That sounds right",
                action: {
                    nextAction()
                },
                disableMainButton: !animationCompletedText,
                buttonColor: .white
            )
            
            // back button
            RectangleButtonPrimary(
                buttonText: "Not quite right (go back)",
                action: {
                    backAction()
                },
                disableMainButton: !animationCompletedText,
                buttonColor: .clear
            )
            .padding(.bottom)
            
        }//VStack
//        .frame(maxWidth:.infinity, alignment: .leading)
    }
    
    private func manageView() {
        
        switch newCategoryViewModel.createNewCategorySummary {
        case .ready:
            feedback = newCategoryViewModel.newCategorySummary?.summary ?? ""
            
            if reflectionSelectedTab != 1 {
                reflectionSelectedTab = 1
            }
            
            // ensure animation vars are reset
            animatedText = ""
            animationCompletedText = false

            
            startReflectionAnimation()
            
        case .loading:
            if reflectionSelectedTab != 0 {
                reflectionSelectedTab = 0
            }
            
        case .retry:
            reflectionSelectedTab = 2
            
        }
    }
    
    private func startReflectionAnimation() {
        print("Starting animation, feedback: \(feedback)")
        
        animator = TextAnimator (
            text: feedback,
            animatedText: $animatedText,
            completedAnimation: $animationCompletedText,
            speed: 0.03
        )
        
        animator?.animate()
    }
    
    private func nextAction() {
        mainSelectedTab += 1
        DispatchQueue.global(qos: .background).async {
            Mixpanel.mainInstance().track(event: "Problem statement correct")
        }
    }
    
    private func backAction() {
        selectedQuestion = 2
        progressBarQuestionIndex = 2
        mainSelectedTab -= 1
        
        Task {
            await dataController.deleteIncompleteGoals()
           
            await newCategoryViewModel.cancelCurrentRun()
            DispatchQueue.global(qos: .background).async {
                Mixpanel.mainInstance().track(event: "Problem statement incorrect")
            }
           
        }
        
    }
    
    private func retryAction() {
        reflectionSelectedTab = 0
        animationCompletedLoading = false
        feedback = ""
         animatedText = ""
         animationCompletedText = false
        
        
        if let category = newCategoryViewModel.currentCategory, let goal = newCategoryViewModel.currentGoal {
            Task {
                await manageRun(category: category, goal: goal)
            }
        }
        
        
    }
    
    private func manageRun(category: Category, goal: Goal) async {
        
        Task {
            do {
                try await newCategoryViewModel.manageRun(selectedAssistant: .newCategory, category: category, goal: goal)
                
            } catch {
                newCategoryViewModel.createNewCategorySummary = .retry
            }
            
            do {
                try await newCategoryViewModel.manageRun(selectedAssistant: .planSuggestion, category: category, goal: goal)
                
            } catch {
                newCategoryViewModel.createPlanSuggestions = .retry
            }
            
        }
        
    }
    
}

//#Preview {
//    NewCategoryReflectionView()
//}
