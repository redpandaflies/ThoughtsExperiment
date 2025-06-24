//
//  NewGoalReflectionView.swift
//  Fearless2
//
//  Created by Yue Deng-Wu on 4/10/25.
//
import Combine
import Mixpanel
import SwiftUI

struct NewGoalReflectionView: View {
    @ObservedObject var newGoalViewModel: NewGoalViewModel
    @EnvironmentObject var dataController: DataController
    
    @State private var reflectionSelectedTab: Int = 0
    
    // text animation
    @State private var animator: TextAnimator?
    @State private var animatedText: String = ""
    @State private var animationCompletedText: Bool = false
    @State private var startedTextAnimation: Bool = false
    
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
                LoadingViewChecklist(
                    texts: loadingTexts,
                    onComplete: {
                        newGoalViewModel.completedLoadingAnimationSummary = true
                    }
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
            
            if let _ = newGoalViewModel.newCategorySummary {
                /// when user moves back to this view
                reflectionSelectedTab = 1
            } else {
                /// when user sees the new reflection for the first time
                if reflectionSelectedTab != 0 {
                    reflectionSelectedTab = 0
                }
                
                //reset state vars
                resetVars()
            }
        }
        .onReceive(
          Publishers.CombineLatest(
            newGoalViewModel.$createNewCategorySummary,
            newGoalViewModel.$completedLoadingAnimationSummary
          )
          .filter { summary, loaded in
            summary != .loading && loaded
          }
          .receive(on: DispatchQueue.main)
          .eraseToAnyPublisher()
        ) { _ in
          manageView()
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
                buttonColor: .clearStroke
            )
            .padding(.bottom)
            
        }//VStack
//        .frame(maxWidth:.infinity, alignment: .leading)
    }
    
    private func manageView() {
        
        switch newGoalViewModel.createNewCategorySummary {
        case .ready:
            
            if reflectionSelectedTab != 1 {
                reflectionSelectedTab = 1
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                startReflectionAnimation()
            }
            
        case .loading:
            if reflectionSelectedTab != 0 {
                reflectionSelectedTab = 0
            }
            
        case .retry:
            reflectionSelectedTab = 2
            
        }
    }
    
    private func startReflectionAnimation() {
        
        guard !startedTextAnimation else { return }
        
        startedTextAnimation = true
        
        if let feedback = newGoalViewModel.newCategorySummary?.summary {
            print ("New goal feedback: \(feedback)")
            animator = TextAnimator (
                text: feedback,
                animatedText: $animatedText,
                completedAnimation: $animationCompletedText,
                speed: 0.03
            )
            
            animator?.animate()
        }
    }
    
    private func nextAction() {
        mainSelectedTab = 0
        selectedQuestion += 1
        
        withAnimation(.interpolatingSpring) {
            progressBarQuestionIndex += 1
        }
        
        DispatchQueue.global(qos: .background).async {
            Mixpanel.mainInstance().track(event: "Problem statement correct")
        }
    }
    
    private func backAction() {
        selectedQuestion = 2
        progressBarQuestionIndex = 2
        mainSelectedTab -= 1
        
        resetVars()
        
        Task {
            await dataController.deleteIncompleteGoals()
           
            try await newGoalViewModel.cancelCurrentRun()
            DispatchQueue.global(qos: .background).async {
                Mixpanel.mainInstance().track(event: "Problem statement incorrect")
            }
           
        }
        
    }
    
    private func retryAction() {
        reflectionSelectedTab = 0
        resetVars()
        
        if let category = newGoalViewModel.currentCategory, let goal = newGoalViewModel.currentGoal {
            Task {
                do {
                    try await newGoalViewModel.manageRun(selectedAssistant: .newGoal, category: category, goal: goal)
                    
                } catch {
                    await MainActor.run {
                        newGoalViewModel.createNewCategorySummary = .retry
                    }
                }
            }
        }
        
        
    }
    
    
    
    private func resetVars() {
        //reset state vars
        animatedText = ""
        startedTextAnimation = false
        animationCompletedText = false
        
        newGoalViewModel.completedLoadingAnimationSummary = false
        newGoalViewModel.newCategorySummary = nil
    }
    
}

//#Preview {
//    NewCategoryReflectionView()
//}
