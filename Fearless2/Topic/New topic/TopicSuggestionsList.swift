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
    
    let category: Category
    
    var body: some View {
        VStack {
            
            HStack {
                Text("Choose a topic you want to explore")
                    .multilineTextAlignment(.leading)
                    .font(.system(size: 25))
                    .foregroundStyle(AppColors.whiteDefault)
                    .padding(.bottom, 20)
                    .padding(.horizontal)
                
                Spacer()
            }
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack (alignment: .top, spacing: 15) {
                    switch selectedTabSuggestionsList {
                    case 0:
                        placeholder()
                    case 1:
                        suggestionsList()
                    default:
                        FocusAreaRetryView(action: {
                            retryTopicSuggestions()
                        })
                        .frame(width: screenWidth * 0.80)
                    }
                    
                }//Hstack
                .scrollTargetLayout()
                
            }//Scrollview
            .scrollClipDisabled(true)
            .scrollTargetBehavior(.viewAligned)
            .contentMargins(.horizontal, (screenWidth * 0.20)/2, for: .scrollContent)
            
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
            .frame(width: screenWidth * 0.80)
            .scrollTransition { content, phase in
                content
                    .opacity(phase.isIdentity ? 1 : 0.7)
                    .scaleEffect(y: phase.isIdentity ? 1 : 0.85)
            }
        }
    }
    
    private func placeholder() -> some View {
        ForEach(0..<2, id: \.self) { _ in
            LoadingPlaceholderContent(contentType: .suggestions)
                .scrollTransition { content, phase in
                    content
                        .opacity(phase.isIdentity ? 1 : 0.7)
                        .scaleEffect(y: phase.isIdentity ? 1 : 0.85)
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
        dismiss()
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
            
            Text(suggestion.emoji)
                .font(.system(size: 35))
                .padding(.bottom, 10)

            Text(suggestion.content)
                .multilineTextAlignment(.center)
                .font(.system(size: 17))
                .foregroundStyle(AppColors.whiteDefault)
                .fixedSize(horizontal: false, vertical: true)

            
            Text(suggestion.reasoning)
                .multilineTextAlignment(.center)
                .font(.system(size: 13))
                .foregroundStyle(AppColors.whiteDefault.opacity(0.7))
                .fixedSize(horizontal: false, vertical: true)
                .padding(.bottom, 40)
            
            RectangleButtonYellow(
                buttonText: "Choose",
                action: {
                    action()
                })
        }
        .padding()
        .padding(.top, 20)
        .contentShape(Rectangle())
        .background {
            RoundedRectangle(cornerRadius: 20)
                .stroke(AppColors.whiteDefault.opacity(0.1), lineWidth: 0.5)
                .fill(AppColors.black5)
                .shadow(color: .black.opacity(0.2), radius: 2, x: 0, y: 2)
        }
        
    }
}
