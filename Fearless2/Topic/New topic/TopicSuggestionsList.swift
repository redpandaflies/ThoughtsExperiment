//
//  TopicSuggestionsList.swift
//  Fearless2
//
//  Created by Yue Deng-Wu on 10/3/24.
//
import Mixpanel
import SwiftUI


struct TopicSuggestionsList: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var dataController: DataController
    @ObservedObject var topicViewModel: TopicViewModel
    @State private var selectedTabSuggestionsList: Int = 0
    
    private let screenWidth = UIScreen.current.bounds.width
    
    @Binding var selectedTopic: Topic?
    @Binding var navigateToTopicDetailView: Bool
    @Binding var currentTabBar: TabBarType
    @Binding var focusAreasLimit: Int
    
    let category: Category
    
    var body: some View {
        VStack {
            
            Text("Choose your next topic")
                .multilineTextAlignment(.leading)
                .font(.system(size: 21, design: .serif))
                .foregroundStyle(AppColors.textPrimary)
                .padding(.bottom, 20)
                .padding(.horizontal)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack (alignment: .center, spacing: 15) {
                    switch selectedTabSuggestionsList {
                    case 0:
                        LoadingPlaceholderContent(contentType: .suggestions)
                            .frame(width: 260)
                    case 1:
                        suggestionsList()
                    default:
                        FocusAreaRetryView(action: {
                            retryTopicSuggestions()
                        })
                        .frame(width: 260)
                    }
                    
                }//Hstack
                .scrollTargetLayout()
                
            }//Scrollview
            .scrollClipDisabled(true)
            .scrollTargetBehavior(.viewAligned)
            .contentMargins(.horizontal, (screenWidth - 260)/2, for: .scrollContent)
            
            Spacer()
        }//VStack
        .onAppear {
            getTopicSuggestions()
        }
        .onChange(of: topicViewModel.topicSuggestions) {
            if !topicViewModel.topicSuggestions.isEmpty {
                selectedTabSuggestionsList = 1
            }
        }
        
    }
    
    private func suggestionsList() -> some View {
        ForEach(topicViewModel.topicSuggestions, id: \.self) { suggestion in
            
            TopicSuggestionBox(suggestion: suggestion, action: {
                selectTopic(suggestion: suggestion)
            })
            .frame(width: 260)
            .onTapGesture {
                selectTopic(suggestion: suggestion)
            }
            .scrollTransition { content, phase in
                content
                    .opacity(phase.isIdentity ? 1 : 0.8)
                    .scaleEffect(x: phase.isIdentity ? 1 : 0.95, y: phase.isIdentity ? 1 : 0.95)
            }
        }
    }
    
    private func getTopicSuggestions() {
        Task {
  
            do {
                try await topicViewModel.manageRun(selectedAssistant: .topicSuggestions, category: self.category)
            } catch {
                selectedTabSuggestionsList = 2
            }
                
        }
    }
    
    private func retryTopicSuggestions() {
        selectedTabSuggestionsList = 0
        getTopicSuggestions()
    }
    
    //MARK: Create selected topic and its first focus area
    private func selectTopic(suggestion: NewTopicSuggestion) {
        Task {
           
            
            let (topicId, focusArea) = await createTopic(suggestion: suggestion, category: self.category)
            
            await MainActor.run {
                topicViewModel.updatingfocusArea = true
                startNewTopic()
            }
            
            await createFocusArea(topicId: topicId, focusArea: focusArea)
        }
    }
    
    private func createTopic(suggestion: NewTopicSuggestion, category: Category) async -> (topicId: UUID?, focusArea: FocusArea?) {
        
        //save selected topic to coredata
        let (topicId, focusArea) = await dataController.createTopic(suggestion: suggestion, category: category)
        
        return (topicId, focusArea)
    }
    
    private func startNewTopic() {
        //close sheet
        dismiss()
        
        //set focus areas limit for new topic
        focusAreasLimit = FocusAreasLimitCalculator.calculatePaths(topicIndex: 0, totalTopics: category.categoryTopics.count)
        
        //navigate to new topic
        selectedTopic = dataController.newTopic
        dataController.newTopic = nil
        
        navigateToTopicDetailView = true
        withAnimation(.snappy(duration: 0.2)) {
            currentTabBar = .topic
        }
        
        guard let newTopicTitle = selectedTopic?.topicTitle else { return }
        
        DispatchQueue.global(qos: .background).async {
            Mixpanel.mainInstance().track(event: "Created new topic")
            Mixpanel.mainInstance().track(event: "Created new topic: \(newTopicTitle)")
        }
       
    }
    
    private func createFocusArea(topicId: UUID?, focusArea: FocusArea?) async {
       
        do {
            if let topicId = topicId, let focusArea = focusArea {
                
                try await topicViewModel.manageRun(selectedAssistant: .focusArea, topicId: topicId, focusArea: focusArea)
            }
        } catch {
            topicViewModel.focusAreaCreationFailed = true
        }
        
    }
    
    
   
}

struct TopicSuggestionBox: View {
   
    let suggestion: NewTopicSuggestion
    let action: () -> Void
    
    var body: some View {
        VStack (spacing: 10) {

            Text(suggestion.content)
                .multilineTextAlignment(.center)
                .font(.system(size: 21, design: .serif))
                .foregroundStyle(AppColors.textPrimary)
                .fixedSize(horizontal: false, vertical: true)

            
            Text(suggestion.reasoning)
                .multilineTextAlignment(.center)
                .font(.system(size: 15, weight: .light))
                .foregroundStyle(AppColors.textPrimary.opacity(0.8))
                .lineSpacing(1.4)
                .fixedSize(horizontal: false, vertical: true)
                .padding(.bottom, 30)
            
            SelectButtonRound(buttonAction: {
                action()
            })
        }
        .padding()
        .padding(.top, 10)
        .contentShape(Rectangle())
        .background {
            RoundedRectangle(cornerRadius: 25)
                .stroke(AppColors.whiteDefault.opacity(0.1), lineWidth: 0.5)
                .fill(AppColors.boxGrey1.opacity(0.3))
                .shadow(color: .black.opacity(0.05), radius: 15, x: 0, y: 3)
                .blendMode(.colorDodge)
        }
        
    }
}
