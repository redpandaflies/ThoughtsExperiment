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
    @Binding var selectedFocusAreaSummary: FocusAreaSummary?
    
    @Binding var focusArea: FocusArea?
   

    var body: some View {
        
        ZStack {
           
            ScrollView(showsIndicators: false) {
                VStack (spacing: 5) {
                    Text("End of section")
                        .font(.system(size: 14))
                        .foregroundStyle(AppColors.whiteDefault)
                        .textCase(.uppercase)
                        .opacity(0.5)
                        .padding(.top)
                    
                    getTitle()
                        .padding(.bottom, 40)
                    
                    VStack (alignment: .leading, spacing: 15) {
                        
                        Text(getSubtitle())
                            .font(.system(size: 20))
                            .foregroundStyle(AppColors.yellow1)
                            .textCase(.uppercase)
                            .padding(.horizontal)
                        
                        getContent()
                            .padding(.horizontal, selectedTab == 3 ? 0 : 16)
                    }
                    .transition(.asymmetric(insertion: .move(edge: .trailing), removal: .identity))
                   
                }//VStack
                
            }
            .scrollDisabled(true)
            
            VStack (spacing: 20) {
                Spacer()

                if let button = getButton() {
                    button
                        .onTapGesture {
                            buttonAction()
                        }
                }
               
                getFootnote()
                               
            }
            .padding(.bottom, 50)
            .padding(.horizontal)
            
        }//ZStack
       
        .onAppear {
            createSummary()
        }
        .onChange(of: topicViewModel.focusAreaSummaryCreated) {
            if topicViewModel.focusAreaSummaryCreated {
                selectedFocusAreaSummary = focusArea?.summary
                withAnimation(.snappy(duration: 0.2)) {
                    showSuggestions = true
                    selectedTab += 1
                }
            }
        }
            
        
    }
    
    private func getTitle() -> some View {
        Group {
            switch selectedTab {
            case 3:
                Text("Continue your path")
                
            default:
                Text(focusArea?.focusAreaTitle ?? "")
            }
        }
        .multilineTextAlignment(.center)
        .font(.system(size: 20, weight: .regular))
        .foregroundStyle(AppColors.whiteDefault)
       
    }
    
    private func getSubtitle() -> String {
        switch selectedTab {
        case 0, 1:
            return "Your confidante says"
        case 2:
            return "Insights"
        default:
            return "Focus areas"
        }
    }
    
    private func getContent() -> some View {
        switch selectedTab {
        
            case 0:
                return AnyView(FocusAreaLoadingView())
            
            case 1:
                return AnyView(feedbackView(selectedFocusAreaSummary?.summaryFeedback ?? ""))
            
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
            .font(.system(size: 15))
            .foregroundStyle(AppColors.whiteDefault)
            .lineSpacing(0.5)
    }
    
    private func insightsView() -> some View {
        ForEach(selectedFocusAreaSummary?.summaryInsights ?? [], id: \.insightId) { insight in
            
            SummaryInsightBox(insight: insight)
        }
    }
    
    private func getButton() -> AnyView? {
        switch selectedTab {
        case 1, 2:
          return AnyView( RectangleButton(buttonImage: "arrow.right.circle.fill", buttonColor: AppColors.whiteDefault))
            
        default:
           return nil
        }
    }
    
    private func buttonAction() {
        switch selectedTab {
            case 1:
            selectedTab += 1
        case 2:
            if !showSuggestions {
                dismiss()
            } else {
                selectedTab += 1
            }
        default:
            break
        }
    }
    
    private func getFootnote() -> some View {
        Group {
            switch selectedTab {
                
            case 2:
                Text("Find your saved insights on the Insights tab of each topic.")
            case 3:
                Text("Paths help you explore your topics. Each path is unique.")
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
        if let _ = selectedFocusAreaSummary {
            selectedTab = 1
        } else {
            Task {
                await topicViewModel.manageRun(selectedAssistant: .focusAreaSummary, focusArea: focusArea)
                await topicViewModel.manageRun(selectedAssistant: .focusAreaSuggestions, topicId: focusArea?.topic?.topicId)
            }
        }
    }
    
}



struct FocusAreaLoadingView: View {
    @State private var enableAnimation: Bool = false
    @State private var animationEffect: Int = 0
    let timer = Timer.publish(every: 3, on: .main, in: .common).autoconnect()
    
    
    var body: some View {
        VStack (alignment: .leading, spacing: 10) {
            
            ForEach(0..<3) { index in
                HStack {
                    loadingBox()
                        .frame(width: CGFloat(100 - (index * 10)), height: 30)
                    Spacer()
                }
            }
            
        }
        
    }
    
    private func loadingBox() -> some View {
        
        RoundedRectangle(cornerRadius: 15)
            .stroke(AppColors.whiteDefault.opacity(0.2), lineWidth: 1)
            .fill(Color.black)
            .changeEffect (
                .shine.delay(0.2),
                value: animationEffect,
                isEnabled: enableAnimation
            )
            .onAppear {
                
                withAnimation(.easeIn(duration: 0.5)) {
                    enableAnimation = true
                    animationEffect += 1
                }
                
            }
            .onDisappear {
                
                timer.upstream.connect().cancel()
                                
            }
            .onReceive(timer) { time in

                animationEffect += 1
            }
    }
}



//#Preview {
//    SectionReflectionView()
//}
