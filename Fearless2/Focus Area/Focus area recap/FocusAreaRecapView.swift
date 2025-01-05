//
//  FocusAreaRecapView.swift
//  Fearless2
//
//  Created by Yue Deng-Wu on 10/30/24.
//
import CoreData
import Pow
import SwiftUI

struct FocusAreaRecapView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var dataController: DataController
    @ObservedObject var topicViewModel: TopicViewModel
    @State private var selectedTab: Int = 0 // [0] loader, [1] feedback, [2] insights, [3] suggestions
    @State private var showSuggestions: Bool = false
    @State private var recapReady: Bool = false //manage the UI changes when recap is ready
    
    @Binding var focusArea: FocusArea?
    
    var body: some View {
        
        VStack (spacing: 10) {
            
            //Header
            FocusAreaRecapHeader(
                selectedTab: $selectedTab,
                focusAreaTitle: focusArea?.focusAreaTitle ?? "",
                xmarkAction: {
                    dismiss()
                },
                showSuggestions: showSuggestions
            )
            .padding(.bottom)
            .padding(.horizontal)
                    
            VStack (alignment: .leading, spacing: 5) {
                
                getHeading()
                    .padding(.horizontal)
                
                getTitle()
                    .padding(.bottom, 10)
                    .padding(.horizontal)
                
                getContent()
                    .padding(.horizontal, (selectedTab == 3) ? 0 : 16)
                    
            }
            .transition(.asymmetric(insertion: .move(edge: .trailing), removal: .identity))

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
            }
            
        }//VStack
        .padding(.bottom)
        .onAppear {
            createSummary()
        }
        .onChange(of: topicViewModel.focusAreaSummaryCreated) {
            if topicViewModel.focusAreaSummaryCreated {
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
            .font(.system(size: 14, weight: .light))
            .foregroundStyle(AppColors.yellow1)
            .textCase(.uppercase)
            
            Spacer()
        }
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
                Text("Choose the next section to keep exploring this topic")
            }
        }
        .multilineTextAlignment(.leading)
        .font(.system(size: 25, weight: .light))
        .foregroundStyle(AppColors.whiteDefault)
       
    }
    
    private func getContent() -> some View {
        switch selectedTab {
        
            case 0:
            guard let currentFocusArea = focusArea else { return AnyView(EmptyView())}
            
            return AnyView(FocusAreaLoadingView(topicViewModel: topicViewModel, recapReady: $recapReady, focusArea: currentFocusArea))
            
            case 1:
            return AnyView(feedbackView(focusArea?.summary?.summaryFeedback ?? ""))
            
            case 2:
               return AnyView(insightsView())
            
            default:
                return AnyView(FocusAreaSuggestionsList(topicViewModel: topicViewModel, suggestions: topicViewModel.focusAreaSuggestions, action: {
                        dismiss()
                    }, topic: focusArea?.topic))
        }
    }
    
    private func feedbackView(_ feedback: String) -> some View {
        Text(feedback)
            .font(.system(size: 17))
            .foregroundStyle(AppColors.whiteDefault)
            .lineSpacing(0.6)
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
            return recapReady ? "Section recap" : "Working on it..."
            
        case 1:
            return "Uncover insights"
            
        case 2:
            
            if showSuggestions {
                return "Choose next section"
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
            selectedTab = 1
        } else {
            Task {
                await topicViewModel.manageRun(selectedAssistant: .focusAreaSummary, focusArea: focusArea)
                await topicViewModel.manageRun(selectedAssistant: .focusAreaSuggestions, topicId: focusArea?.topic?.topicId)
            }
        }
    }
    
}






//#Preview {
//    SectionReflectionView()
//}
