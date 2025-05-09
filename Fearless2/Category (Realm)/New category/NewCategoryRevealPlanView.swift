//
//  NewCategoryRevealPlanView.swift
//  Fearless2
//
//  Created by Yue Deng-Wu on 4/10/25.
//

import SwiftUI

struct NewCategoryRevealPlanView: View {
    @EnvironmentObject var dataController: DataController
    @ObservedObject var newCategoryViewModel: NewCategoryViewModel
    
    @State private var planSelectedTab: Int = 0
    @State private var suggestionsScrollPosition: Int?
    
    @Binding var showSheet: Bool
    
    let completeSequenceAction: () -> Void
    
    let screenWidth: CGFloat = UIScreen.current.bounds.width
    let frameWidth: CGFloat = 300
    
    let loadingTexts: [String] = [
        "Thinking through the best way forward for you.",
        "Putting the finishing touches on the plan.",
        "Making sure the plan is right for you."
    ]
    
    init(
        newCategoryViewModel: NewCategoryViewModel,
        showSheet: Binding<Bool>,
        completeSequenceAction: @escaping () -> Void = {}
    ) {
        self.newCategoryViewModel = newCategoryViewModel
        self._showSheet = showSheet
        self.completeSequenceAction = completeSequenceAction
    }
    
    var body: some View {
        VStack {
            switch planSelectedTab {
                
                case 0:
                    NewCategoryLoadingView(texts: loadingTexts)
                case 1:
                    getPlanSuggestions()
                    
                default:
                    FocusAreaRetryView(action: {
                        retryAction()
                    })
            }
            
        }
        .onAppear {
            if newCategoryViewModel.createPlanSuggestions == .ready && !newCategoryViewModel.newPlanSuggestions.isEmpty {
                planSelectedTab = 1
            } else if newCategoryViewModel.createPlanSuggestions == .retry {
                planSelectedTab = 2
            } else {
                planSelectedTab = 0
            }
        }
        .onChange(of: newCategoryViewModel.createPlanSuggestions) {
            
            switch newCategoryViewModel.createPlanSuggestions {
            case .ready:
                planSelectedTab = 1
            case .loading:
                if planSelectedTab != 0 {
                    planSelectedTab = 0
                }
            case .retry:
                planSelectedTab = 2
            
            }
        }
    }
    
    private func getPlanSuggestions() -> some View {
        VStack (alignment: .leading, spacing: 10) {
            Text("Choose one of these two personalized plans I created for you")
                .multilineTextAlignment(.leading)
                .font(.system(size: 19, design: .serif))
                .foregroundStyle(AppColors.textPrimary.opacity(0.8))
                .lineSpacing(1.5)
                .fixedSize(horizontal: false, vertical: true)
                .padding(.horizontal)
                .padding(.bottom, 20)
            
            ScrollView(.horizontal) {
                HStack (alignment: .center, spacing: 15) {
                    
                    ForEach(Array(newCategoryViewModel.newPlanSuggestions.enumerated()), id: \.element.self) { index, suggestion in
                        PlanSuggestionBox(suggestion: suggestion, index: index, frameWidth: frameWidth)
                            .id(index)
                            .scrollTransition { content, phase in
                                content
                                .opacity(phase.isIdentity ? 1 : 0.3)
                            }
                            .onTapGesture {
                                saveChosenPlan(plan: suggestion)
                            }
                    }
                }
                .scrollTargetLayout()
            }//Scrollview
            .scrollPosition(id: $suggestionsScrollPosition, anchor: .leading)
            .scrollClipDisabled(true)
            .scrollTargetBehavior(.viewAligned)
            .contentMargins(.horizontal, 16, for: .scrollContent)
            .scrollIndicators(.hidden)
        }
    
    }
    
    private func retryAction() {
        planSelectedTab = 0
        
        if let category = newCategoryViewModel.currentCategory, let goal = newCategoryViewModel.currentGoal {
            Task {
                await manageRun(category: category, goal: goal)
            }
        }
        
    }
    
    private func manageRun(category: Category, goal: Goal) async {
        
        Task {
           
            do {
                try await newCategoryViewModel.manageRun(selectedAssistant: .planSuggestion, category: category, goal: goal)
                
            } catch {
                newCategoryViewModel.createPlanSuggestions = .retry
            }
            
        }
        
    }
    
    private func saveChosenPlan(plan: NewPlan) {
        Task {
            if let category = newCategoryViewModel.currentCategory, let goal = newCategoryViewModel.currentGoal {
                await dataController.saveSelectedPlan(plan: plan, category: category, goal: goal)
                
                await MainActor.run {
                    showSheet = false
                }
            }
        }
        
        // mark sequence and topic as complete
        completeSequenceAction()
    }
    
}

struct PlanSuggestionBox: View {
    
    let suggestion: NewPlan
    let index: Int
    
    let frameWidth: CGFloat
    
    var body: some View {
        VStack (alignment: .leading, spacing: 5) {
            
            Text("Plan \(index + 1)")
                .multilineTextAlignment(.leading)
                .font(.system(size: 17, weight: .light).smallCaps())
                .fontWidth(.condensed)
                .foregroundStyle(AppColors.textPrimary.opacity(0.8))
                .padding(.bottom, 15)
            
            
            Text(suggestion.title)
                .multilineTextAlignment(.leading)
                .font(.system(size: 20, weight: .medium, design: .serif))
                .foregroundStyle(AppColors.textPrimary)
                .fixedSize(horizontal: false, vertical: true)
                .lineSpacing(1.3)
            
            Text(suggestion.intent)
                .multilineTextAlignment(.leading)
                .font(.system(size: 15, weight: .light))
                .foregroundStyle(AppColors.textPrimary.opacity(0.8))
                .fixedSize(horizontal: false, vertical: true)
                .lineSpacing(1.4)
                .padding(.bottom, 25)
            
            getObjectivesList()
            
            Spacer()
            
            RectangleButtonPrimary(
                buttonText: "Choose this plan",
                action: {
                    
                },
                buttonColor: .white
            )
            .disabled(true)
            
        }
        .frame(width: frameWidth, height: 450)
        .padding(.horizontal, 20)
        .padding(.top, 20)
        .padding(.bottom, 20)
        .contentShape(Rectangle())
        .background {
            RoundedRectangle(cornerRadius: 25)
                .stroke(AppColors.whiteDefault.opacity(0.1), lineWidth: 0.5)
                .fill(AppColors.boxGrey4.opacity(0.3))
                .shadow(color: .black.opacity(0.05), radius: 15, x: 0, y: 3)
                .blendMode(.colorDodge)
        }
    }
    
    private func getObjectivesList() -> some View {
        
        VStack (alignment: .leading, spacing: 15) {
        
//            VStack(alignment: .leading, spacing: 3) {
                
                ForEach(Array(suggestion.explore.enumerated()), id: \.element.self) { index, content in
                        checklistItem(text: content)
                    }
                
//            }
//            .padding()
//            .mask(
//                LinearGradient(
//                    gradient: Gradient(stops: [
//                        .init(color: .white.opacity(0.4), location: 0.0),
//                        .init(color: .white.opacity(0.8), location: 0.65),
//                        .init(color: .white, location: 1)
//                    ]),
//                    startPoint: .bottom,
//                    endPoint: .top
//                )
//            )
        }
        .padding(20)
        .background {
            getRectangle()
        }
        
    }
    
    private func checklistItem(text: String) -> some View {
        HStack(alignment: .firstTextBaseline, spacing: 10) {
           
           Image(systemName: "checkmark")
               .font(.system(size: 15, weight: .light))
               .fontWidth(.condensed)
               .foregroundStyle(AppColors.textPrimary)
               
        
           Text(text)
               .multilineTextAlignment(.leading)
               .font(.system(size: 15, weight: .light))
               .fontWidth(.condensed)
               .foregroundStyle(AppColors.textPrimary)
               .lineSpacing(1.3)
            
       }
       .frame(alignment: .leading)
      
   }
    
    private func getRectangle() -> some View {
        RoundedRectangle(cornerRadius: 15)
            .foregroundStyle(
                AppColors.boxGrey3.opacity(0.25)
                    .blendMode(.multiply)
                    .shadow(.inner(color: .black.opacity(0.5), radius: 5, x: 0, y: 2))
                    .shadow(.drop(color: .white.opacity(0.2), radius: 0, x: 0, y: 1))
            )
    }
    
}
