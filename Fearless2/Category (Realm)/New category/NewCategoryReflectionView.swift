//
//  NewCategoryReflectionView.swift
//  Fearless2
//
//  Created by Yue Deng-Wu on 4/10/25.
//

import SwiftUI

struct NewCategoryReflectionView: View {
    @ObservedObject var newCategoryViewModel: NewCategoryViewModel
    @EnvironmentObject var dataController: DataController
    
    @State private var reflectionSelectedTab: Int = 0
    @State private var animator: TextAnimator?
    @State private var animatedText: String = ""
    @State private var feedback: String = ""
    
    @Binding var mainSelectedTab: Int
    @Binding var selectedQuestion: Int
    @Binding  var progressBarQuestionIndex: Int
    
    let loadingTexts: [String] = [
        "Give me a few seconds while I go through your answers.",
        "I'm trying to really understand what you're dealing with.",
        "I should then be able to offer a couple of options for you to explore."
    ]
  
    var body: some View {
        VStack {
            switch reflectionSelectedTab {
            case 0:
                //loading view
                NewCategoryLoadingView(texts: loadingTexts)
                
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
            print("New category summary ready")
            switch newCategoryViewModel.createNewCategorySummary {
            case .ready:
                feedback = newCategoryViewModel.newCategorySummary?.summary ?? ""
                
                reflectionSelectedTab = 1
                startReflectionAnimation()
                
            case .loading:
                if reflectionSelectedTab != 0 {
                    reflectionSelectedTab = 0
                }
                
                
            case .retry:
                reflectionSelectedTab = 2
                
            }
            
        }
    }
    
   
    
    private func getReflection() -> some View {
        VStack (alignment: .leading, spacing: 25) {
            
            Text("Here is what I heard:")
                .multilineTextAlignment(.leading)
                .font(.system(size: 23, design: .serif))
                .foregroundStyle(AppColors.textPrimary)
                .fixedSize(horizontal: false, vertical: true)

            Text(animatedText)
                .multilineTextAlignment(.leading)
                .font(.system(size: 19, design: .serif))
                .foregroundStyle(AppColors.textPrimary.opacity(0.9).opacity(0.8))
                .lineSpacing(1.7)
            
            Spacer()
            
            // next button
            RectangleButtonPrimary(
                buttonText: "That sounds right",
                action: {
                    nextAction()
                },
                disableMainButton: animatedText != feedback,
                buttonColor: .white
            )
            
            // back button
            RectangleButtonPrimary(
                buttonText: "Not quite right (go back)",
                action: {
                    backAction()
                },
                disableMainButton: animatedText != feedback,
                buttonColor: .clear
            )
            
            
        }//VStack
//        .frame(maxWidth:.infinity, alignment: .leading)
    }
    
    private func startReflectionAnimation() {
        if animator == nil {
            animator = TextAnimator(text: feedback, animatedText: $animatedText, speed: 0.02)
        }
        animator?.animate()
    }
    
    private func nextAction() {
        mainSelectedTab += 1
    }
    
    private func backAction() {
        selectedQuestion = 2
        progressBarQuestionIndex = 2
        mainSelectedTab -= 1
        
        Task {
            await dataController.deleteLastGoal()
        }
        
    }
    
    private func retryAction() {
        reflectionSelectedTab = 0
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
