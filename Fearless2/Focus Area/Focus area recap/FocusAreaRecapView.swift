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
    @State private var selectedTab: Int = 1 // [0] loader, [1] feedback, [2] insights, [3] suggestions
    @State private var showSuggestions: Bool = false
    @State private var recapReady: Bool = false //manage the UI changes when recap is ready
    @State private var animationValue: Bool = false//manages animation of the ellipsis animation on loading view
    
    @Binding var focusArea: FocusArea?
    
    let lastFocusArea: Bool
    
    private let screenWidth = UIScreen.current.bounds.width
    
    var body: some View {
        
        ZStack {
            
            ScrollView {
                VStack (alignment: .leading, spacing: 5) {
                    
                    getHeading()
                        .padding(.horizontal)
                    
                    getTitle()
                        .padding(.bottom, (selectedTab == 3) ? 20 : 10)
                        .padding(.horizontal)
                    
                    getContent()
                        .padding(.horizontal, (selectedTab == 3) ? 0 : 16)
                    
                }
                .padding(.top, 90)
                
            }
            .scrollIndicators(.hidden)
            .scrollClipDisabled()
            .scrollDisabled((selectedTab == 1) ? false : true)
            .safeAreaInset(edge: .bottom, content: {
                Rectangle()
                    .fill(Color.clear)
                    .frame(height: 120)
            })
            
            VStack {
                
                gradientBackground(fill:
                    LinearGradient(
                    stops: [
                        Gradient.Stop(color: AppColors.black4, location: 0.75),
                        Gradient.Stop(color: AppColors.black4.opacity(0.1), location: 1.0)
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                    ), height: 130, header: true)
                
                Spacer()
                
                gradientBackground(fill:
                    LinearGradient(
                    stops: [
                        Gradient.Stop(color: AppColors.black4.opacity(0.05), location: 0.0),
                        Gradient.Stop(color: AppColors.black4, location: 0.3)
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                    ), height: 180, header: false)
                
            }
            .ignoresSafeArea()
            
            
            VStack {
                //Header
                FocusAreaRecapHeader(
                    selectedTab: $selectedTab,
                    topicTitle: focusArea?.topic?.topicTitle ?? "",
                    xmarkAction: {
                        closeView()
                    },
                    showSuggestions: showSuggestions
                )
                .padding(.bottom)
                .padding(.horizontal)
                
                Spacer()
                
                
                if selectedTab < 3 {
                    RectangleButtonYellow(
                        buttonText: getButtonText(),
                        action: {
                            buttonAction()
                        },
                        showChevron: chevronStatus(),
                        showBackButton: (selectedTab == 2),
                        backAction: {
                            selectedTab -= 1
                        },
                        disableMainButton: disableButton()
                    )
                    .padding(.bottom, 10)
                    .padding(.horizontal)
                    
                    getFootnote()
                        .padding(.bottom)
                }
                
            }//VStack
        }//ZStack
       
        .onAppear {
            createSummary()
        }
        .onChange(of: topicViewModel.focusAreaSummaryCreated) {
            if topicViewModel.focusAreaSummaryCreated {
                animationValue = false
                showSuggestions = true
                recapReady = true
            }
        }
    }

    private func getHeading() -> some View {
        HStack {
            Group {
                switch selectedTab {
                case 0:
                    Text("")
                case 1, 2:
                    Text("Recap")
                default:
                    Text("Next up")
                }
            }
            .multilineTextAlignment(.leading)
            .font(.system(size: 16, weight: .light).smallCaps())
            .fontWidth(.condensed)
            .foregroundStyle(AppColors.yellow1)
            
            Spacer()
        }
    }
    
    private func closeView() {
        dismiss()
    }
    
    private func getTitle() -> some View {
        Group {
            switch selectedTab {
            case 0:
                Text("")
            case 1:
                Text("Feedback")
                
            case 2:
                Text("Save insights")
            
            default:
                Text("Choose the next path to keep exploring this topic")
            }
        }
        .multilineTextAlignment(.leading)
        .font(.system(size: 25))
        .foregroundStyle(AppColors.whiteDefault)
       
    }
    
    private func getContent() -> some View {
        switch selectedTab {
        
            case 0:
                guard let currentFocusArea = focusArea else { return AnyView(EmptyView())}
                
                return AnyView(FocusAreaLoadingView(topicViewModel: topicViewModel, recapReady: $recapReady, animationValue: $animationValue, focusArea: currentFocusArea))
            
            case 1:
                return AnyView(feedbackView(focusArea?.summary?.summaryFeedback ?? ""))
            
            case 2:
               return AnyView(insightsView())
            
            default:
                return AnyView(FocusAreaSuggestionsList(topicViewModel: topicViewModel, suggestions: getSuggestions(), action: {
                            closeView()
                }, topic: focusArea?.topic, useCase: .recap))
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
    
    private func feedbackView(_ feedback: String) -> some View {
        Text(feedback)
            .font(.system(size: 17, weight: .light))
            .foregroundStyle(AppColors.whiteDefault.opacity(0.9))
            .lineSpacing(1.4)
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
            return recapReady ? "Start recap" : "Working on it..."
            
        case 1:
            return "Uncover insights"
            
        case 2:
            if showSuggestions {
                return "Choose next path"
            } else {
                return "End recap review"
            }
            
        default:
           return ""
        }
    }
    
    private func buttonAction() {
        switch selectedTab {
        case 2:
            if showSuggestions {
                selectedTab += 1
            } else {
                dismiss()
            }
            
        case 3:
            break
        default:
            selectedTab += 1
        }
    }
    
    private func chevronStatus() -> Bool {
        switch selectedTab {
        case 0:
            return recapReady
        default:
            return false
        }
    }
    
    private func disableButton() -> Bool {
        switch selectedTab {
        case 0:
            return !recapReady
        default:
            return false
        }
    }
    
    private func getFootnote() -> some View {
        Group {
            switch selectedTab {
                
            case 2:
                Text("Find your saved insights on the **Review** tab of each topic.")
           
            default:
                Text("")
            }
        }
        .font(.system(size: 12))
        .foregroundStyle(AppColors.whiteDefault)
        .opacity(0.5)
    }
    
    //create focus area summary
    private func createSummary() {
        if let currentFocusArea = focusArea, currentFocusArea.completed {
            
            print("This is the last focus area: \(lastFocusArea)")
            
            if lastFocusArea {
                showSuggestions = true
            }
            
        } else {
            
            selectedTab = 0
            
            let topicId = focusArea?.topic?.topicId
            
            Task {

                await topicViewModel.manageRun(selectedAssistant: .focusAreaSummary, topicId: topicId, focusArea: focusArea)
                await topicViewModel.manageRun(selectedAssistant: .focusAreaSuggestions, topicId: topicId)

                DispatchQueue.global(qos: .background).async {
                    Mixpanel.mainInstance().track(event: "Generated recap")
                }
            }
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
}






//#Preview {
//    SectionReflectionView()
//}
