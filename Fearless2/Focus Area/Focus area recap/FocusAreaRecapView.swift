//
//  FocusAreaRecapView.swift
//  Fearless2
//
//  Created by Yue Deng-Wu on 10/30/24.
//
import CoreData
import Mixpanel
import Pow
import SwiftUI

struct FocusAreaRecapView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var dataController: DataController
    @ObservedObject var topicViewModel: TopicViewModel
    @State private var selectedTab: Int = 1 // [0] celebration, [1] feedback, [2] suggestions
    @State private var selectedTabSuggestionsList: Int = 1 //manages whether suggestions, loading view or retry is shown on suggestions list
    @State private var showSuggestions: Bool = false
    @State private var recapReady: Bool = false //manage the UI changes when recap is ready
    @State private var animationValue: Bool = false//manages animation of the ellipsis animation on loading view
    @State private var animatedText = ""
    
    @Binding var focusArea: FocusArea?
    @Binding var focusAreaScrollPosition: Int?
    
    let totalFocusAreas: Int
    let focusAreasLimit: Int
    
    var lastFocusArea: Bool {
        return focusAreaScrollPosition == totalFocusAreas - 1
    }
    
    private let screenWidth = UIScreen.current.bounds.width
    
    var body: some View {
        NavigationStack {
            
            ZStack {
                
                ScrollView {
                    VStack (alignment: (selectedTab == 0) ? .center : .leading, spacing: 5) {
                        
                        getTitle()
                            .padding(.bottom, (selectedTab == 2) ? 15 : 10)
                            .padding(.horizontal)
                        
                        getContent()
                            .padding(.horizontal, (selectedTab == 2) ? 0 : 16)
                        
                    }
                    .padding(.top, 30)
                    
                }
                .scrollIndicators(.hidden)
                .scrollDisabled(true)
                .safeAreaInset(edge: .bottom, content: {
                    Rectangle()
                        .fill(Color.clear)
                        .frame(height: 120)
                })
                
                
                VStack {
                    
                    Spacer()
                    
                    
                    if selectedTab != 2 {
                        RectangleButtonPrimary(
                            buttonText: getButtonText(),
                            action: {
                                buttonAction()
                            },
                            disableMainButton: disableButton(),
                            buttonColor: .white
                        )
                        .padding(.bottom, 10)
                        .padding(.horizontal)
                        
                    }
                    
                }//VStack
            }//ZStack
            .background {
                if let category = focusArea?.category {
                    BackgroundPrimary(backgroundColor: Realm.getBackgroundColor(forName: category.categoryName))
                } else {
                    BackgroundPrimary(backgroundColor: AppColors.backgroundCareer)
                }
            }
            .onAppear {
                getRecap()
            }
            .onChange(of: topicViewModel.createFocusAreaSummary) {
                if topicViewModel.createFocusAreaSummary == .ready {
                    animationValue = false
                    withAnimation (.snappy(duration: 0.2)) {
                        recapReady = true
                    }
                }
            }
            .toolbar {
               
                ToolbarItem(placement: .principal) {
                    ToolbarTitleItem2(emoji: focusArea?.category?.categoryEmoji ?? "", title: "Path complete")
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    XmarkToolbarItem()
                }
                
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackgroundVisibility(.hidden)
            
            
        }//NavigationStack
    }
 
    
    private func getTitle() -> some View {
        
        HStack {
            Group {
                switch selectedTab {
                case 0:
                    Text("")
                case 1:
                    Text("Reflection")
                    
                case 2:
                    Text("Where should I go next?")
                    
                default:
                    Text("")
                }
            }
            .multilineTextAlignment(.leading)
            .font(.system(size: 25, design: .serif))
            .foregroundStyle(AppColors.textPrimary)
            
            Spacer()
        }
       
    }
    
    @ViewBuilder
    private func getContent() -> some View {
        switch selectedTab {
        case 0:
            if let currentFocusArea = focusArea {
                RecapCelebrationView(title: currentFocusArea.focusAreaTitle, text: "For exploring", points: "+1")
                    .padding(.top, 80)
            }
            
        case 1:
            FocusAreaRecapReflectionView(
                topicViewModel: topicViewModel,
                recapReady: $recapReady,
                animatedText: $animatedText,
                feedback: focusArea?.summary?.summaryFeedback ?? "",
                focusArea: focusArea
            )
            
        case 2:
            FocusAreaRecapSuggestionsView(
                topicViewModel: topicViewModel,
                selectedTabSuggestionsList: $selectedTabSuggestionsList,
                focusArea: $focusArea
            )
            
        default:
            FocusAreaRetryView(action: {
                generateNewRecap(isRetry: true)
            })
        }
    }
    
   
    
    private func insightsView() -> some View {
        ForEach(focusArea?.summary?.summaryInsights ?? [], id: \.insightId) { insight in
            
            SummaryInsightBox(insight: insight)
                .padding(.bottom, 5)
        }
    }
    
    private func getButtonText() -> String {
        switch selectedTab {
            case 0:
                return "Next: A small reflection"
                
            case 1:
                if showSuggestions && (totalFocusAreas < focusAreasLimit) {
                    return topicViewModel.createFocusAreaSummary == .loading ? "Loading..." : "Next: Choose next path"
                } else {
                    return topicViewModel.createFocusAreaSummary == .loading ? "Loading..." : "Next: Restore lost fragment"
                }
                
            default:
                return "Retry"
        }
    }
    
    private func buttonAction() {
        switch selectedTab {
       
        case 0:
            updatePoints()
            
        case 1:
            
            if showSuggestions && (totalFocusAreas < focusAreasLimit){
                selectedTab += 1
                completeFocusArea()
            } else {
                completeFocusArea()
                createEndOfTopicFocsAreaIfNeeded()
            }
            
        case 2:
            break
            
        default:
            generateNewRecap(isRetry: true)
            
        }
    }
    
    private func disableButton() -> Bool {
        switch selectedTab {
            case 1:
                if topicViewModel.createFocusAreaSummary == .loading {
                    return true
                } else {
                    if let feedback = focusArea?.summary?.summaryFeedback {
                       return animatedText != feedback
                    } else {
                        return false
                    }
                }
            default:
                return false
            
        }
        
    }
    
    //create or show focus area summary
    private func getRecap() {
        
        if let currentFocusArea = focusArea, let topic = currentFocusArea.topic, currentFocusArea.completed {
            
            print("This is the last focus area: \(lastFocusArea)")
            
            if lastFocusArea && (topic.topicStatus != TopicStatusItem.archived.rawValue) && (totalFocusAreas < focusAreasLimit){
                showSuggestions = true
            }
            
        } else {
            
            generateNewRecap(isRetry: false)
        }
    }
    
    private func gradientBackground(fill: LinearGradient, height: CGFloat, header: Bool) -> some View {
        ZStack {
            VStack {
                
                if !header {
                    Spacer()
                }
                
                Rectangle()
                    .fill(AppColors.black4)
                    .frame(width: screenWidth, height: 20)
                
                if header {
                    Spacer()
                }
            }
            
            Rectangle()
                .fill(fill)
                .blur(radius: 3)
                .frame(width: screenWidth, height: height)
               
        }
        .frame(width: screenWidth, height: height)
    }
    
    private func generateNewRecap(isRetry: Bool) {
        selectedTab = isRetry ? 1 : 0
        showSuggestions = true
        
        let topicId = focusArea?.topic?.topicId
        
        Task {
            do {
                try await topicViewModel.manageRun(selectedAssistant: .focusAreaSummary, topicId: topicId, focusArea: focusArea)
            } catch {
                await MainActor.run {
                    selectedTab = 3
                }
            }
            
            if totalFocusAreas < focusAreasLimit {
                do {
                    try await topicViewModel.manageRun(selectedAssistant: .focusAreaSuggestions, topicId: topicId)
                } catch {
                    await MainActor.run {
                        topicViewModel.createFocusAreaSuggestions = .retry
                    }
                }
            }
            DispatchQueue.global(qos: .background).async {
                Mixpanel.mainInstance().track(event: "Revealed reflection")
            }
        }
    }
    
    private func updatePoints() {
        selectedTab += 1
        Task {
            await dataController.updatePoints(newPoints: 1)
        }
    }
    
    private func completeFocusArea() {
        Task {
            if let focusArea = focusArea {
                await dataController.completeFocusArea(focusArea: focusArea)
            }
        }
    }
    
    
    private func createEndOfTopicFocsAreaIfNeeded() {
        dismiss()
        
        if totalFocusAreas == focusAreasLimit {
            
            Task {
                //mark focusArea.choseSuggestion as true since suggestions won't be needed
                if let focusArea = focusArea {
                    await dataController.updateFocusArea(focusArea: focusArea)
                }
                
                if let topic = focusArea?.topic {
                    await dataController.addEndOfTopicFocusArea(topic: topic)
                }
            }
        }
    }
}


struct FocusAreaRecapReflectionView: View {
    @ObservedObject var topicViewModel: TopicViewModel
    @State private var animationValue: Bool = false
    @State private var animator: TextAnimator?
    @State private var startedAnimation: Bool = false
    
    @Binding var recapReady: Bool
    @Binding var animatedText: String
    
    let feedback: String
    let focusArea: FocusArea?
    
    var body: some View {
        
        Group {
            if recapReady {
                Text(animatedText)
                    .font(.system(size: 19, design: .serif))
                    .foregroundStyle(AppColors.textPrimary.opacity(0.9))
                    .lineSpacing(1.5)
                
            } else {
                HStack {
                    Image(systemName: "ellipsis")
                        .font(.system(size: 25, weight: .regular))
                        .foregroundStyle(AppColors.textPrimary.opacity(0.9))
                        .symbolEffect(.wiggle.byLayer, options: animationValue ? .repeating : .nonRepeating, value: animationValue)
                    
                    Spacer()
                }
                .transition(.asymmetric(insertion: .opacity, removal: .identity))
                .onAppear {
                    animationValue = true
                }
                .onDisappear {
                    animationValue = false
                }
            }
        }
        .onAppear {
            if animator == nil {
                    animator = TextAnimator(text: feedback, animatedText: $animatedText, speed: 0.04)
                }
            
            if topicViewModel.createFocusAreaSummary == .ready {
                if let focusArea = focusArea, focusArea.completed {
                    animatedText = feedback //no animation if use has already seen the feedback once
                    startedAnimation = true //prevent triggering animation when recapReady is set to true
                    recapReady = true
                } else {
                    startedAnimation = true
                    recapReady = true
                    animator?.animate()
                }
            } else {
                recapReady = false
            }
        }
        .onChange(of: recapReady) {
            if recapReady && !startedAnimation {
                print("recap ready, starting typewriter animation")
                if animator == nil {
                    animator = TextAnimator(text: feedback, animatedText: $animatedText, speed: 0.02)
                } else {
                    animator?.updateText(feedback)
                }
                animator?.animate()
            }
        }
    }

}

struct FocusAreaRecapSuggestionsView: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var topicViewModel: TopicViewModel
    
    @Binding var selectedTabSuggestionsList: Int
    
    @Binding var focusArea: FocusArea?
    
    var body: some View {
        VStack (spacing: 20) {
            
            FocusAreaRecapTimelineView(topic: focusArea?.topic)
            
            FocusAreaSuggestionsList(topicViewModel: topicViewModel, selectedTabSuggestionsList: $selectedTabSuggestionsList, suggestions: getSuggestions(), action: {
                    dismiss()
            }, topic: focusArea?.topic, focusArea: focusArea, useCase: .recap)
        }
    }
    
    private func getSuggestions()  -> [any SuggestionProtocol] {
        if let topic = focusArea?.topic {
            print("found topic")
            let suggestions = topic.topicSuggestions
            print("Topic suggestions: \(suggestions)")
            return suggestions.map { $0 as (any SuggestionProtocol) }
        } else {
            print("failed to find topic")
            return []
        }
      
    }
}



//#Preview {
//    SectionReflectionView()
//}
