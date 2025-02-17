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
    
    @Binding var focusArea: FocusArea?
    @Binding var focusAreaScrollPosition: Int?
    
    let totalFocusAreas: Int
    
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
                        RectangleButtonYellow(
                            buttonText: getButtonText(),
                            action: {
                                buttonAction()
                            },
                            buttonColor: .white
                        )
                        .padding(.bottom, 10)
                        .padding(.horizontal)
                        
                    }
                    
                }//VStack
            }//ZStack
            .background {
                if let category = focusArea?.category {
                    AppBackground(backgroundColor: Realm.getBackgroundColor(forName: category.categoryName))
                } else {
                    AppBackground(backgroundColor: AppColors.backgroundCareer)
                }
            }
            .onAppear {
                getRecap()
            }
            .onChange(of: topicViewModel.createFocusAreaSummary) {
                if topicViewModel.createFocusAreaSummary == .ready {
                    animationValue = false
                    showSuggestions = true
                    withAnimation (.snappy(duration: 0.2)) {
                        recapReady = true
                    }
                }
            }
            .toolbar {
               
                ToolbarItem(placement: .principal) {
                    ToolbarTitleItem2(emoji: focusArea?.category?.categoryEmoji ?? "", title: focusArea?.focusAreaTitle ?? "")
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
    
    private func getContent() -> some View {
        switch selectedTab {
        
            case 0:
            guard let currentFocusArea = focusArea else { return AnyView(EmptyView())}
            return AnyView(FocusAreaRecapCelebrationView(focusAreaTitle: currentFocusArea.focusAreaTitle))
            
            case 1:
            return AnyView(FocusAreaRecapReflectionView(topicViewModel: topicViewModel, recapReady: $recapReady, feedback: focusArea?.summary?.summaryFeedback ?? ""))
            
            case 2:
            return AnyView(FocusAreaRecapSuggestionsView(topicViewModel: topicViewModel, selectedTabSuggestionsList: $selectedTabSuggestionsList, focusArea: $focusArea))
            
            default:
                return AnyView(FocusAreaRetryView(action: {
                    generateNewRecap()
                }))
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
                if showSuggestions {
                    return "Next: Choose next path"
                } else {
                    return "End recap review"
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
            if showSuggestions {
                selectedTab += 1
            } else {
                dismiss()
            }
            
        case 2:
            break
            
        default:
            generateNewRecap()
            
        }
    }
    
    //create or show focus area summary
    private func getRecap() {
        
        if let currentFocusArea = focusArea, let topic = currentFocusArea.topic, currentFocusArea.completed {
            
            print("This is the last focus area: \(lastFocusArea)")
            
            if lastFocusArea && (topic.topicStatus != TopicStatusItem.archived.rawValue) {
                showSuggestions = true
            }
            
        } else {
            
            generateNewRecap()
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
    
    private func generateNewRecap() {
        selectedTab = 0
        
        let topicId = focusArea?.topic?.topicId
        
        Task {
            do {
                try await topicViewModel.manageRun(selectedAssistant: .focusAreaSummary, topicId: topicId, focusArea: focusArea)
            } catch {
                await MainActor.run {
                    selectedTab = 3
                }
            }
            
            do {
                try await topicViewModel.manageRun(selectedAssistant: .focusAreaSuggestions, topicId: topicId)
            } catch {
                await MainActor.run {
                    topicViewModel.createFocusAreaSuggestions = .retry
                }
            }
            

            DispatchQueue.global(qos: .background).async {
                Mixpanel.mainInstance().track(event: "Generated recap")
            }
        }
    }
    
    private func updatePoints() {
        selectedTab += 1
        Task {
            await dataController.updatePoints(newPoints: 1)
        }
    }
}


struct FocusAreaRecapCelebrationView: View {
    
    let focusAreaTitle: String?
    
    var body: some View {

        VStack {
            Spacer()
            
            LaurelItem(size: 50, points: "+1")
                .padding(.bottom, 20)
            
            Text("For exploring")
                .font(.system(size: 25, weight: .light).smallCaps())
                .fontWidth(.condensed)
                .foregroundStyle(AppColors.textPrimary.opacity(0.5))
            
            Text(focusAreaTitle ?? "")
                .multilineTextAlignment(.center)
                .font(.system(size: 25, design: .serif))
                .foregroundStyle(AppColors.textPrimary)
                .padding(.bottom, 20)
            
            Spacer()
        }

    }
        
}


struct FocusAreaRecapReflectionView: View {
    @ObservedObject var topicViewModel: TopicViewModel
    @State private var animationValue: Bool = false
    
    @Binding var recapReady: Bool
    
    let feedback: String
    
    var body: some View {
        
        Group {
            if recapReady {
                Text(feedback)
                    .font(.system(size: 19, design: .serif))
                    .foregroundStyle(AppColors.textPrimary)
                    .lineSpacing(1.3)
                
            } else {
                HStack {
                    Image(systemName: "ellipsis")
                        .font(.system(size: 25, weight: .regular))
                        .foregroundStyle(AppColors.textPrimary)
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
            if topicViewModel.createFocusAreaSummary == .ready {
                recapReady = true
            } else {
                recapReady = false
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
                }, topic: focusArea?.topic, useCase: .recap)
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
