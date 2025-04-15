//
//  NewTopicPreviewBox.swift
//  Fearless2
//
//  Created by Yue Deng-Wu on 10/3/24.
//
import Mixpanel
import SwiftUI


struct NewTopicPreviewBox: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var dataController: DataController
    @ObservedObject var topicViewModel: TopicViewModel
    @State private var selectedTabSuggestionsList: Int = 0
    @State private var playHapticEffect: Int = 0
    
    private let screenWidth = UIScreen.current.bounds.width
    
    @Binding var selectedTopic: Topic?
    @Binding var navigateToTopicDetailView: Bool
    @Binding var currentTabBar: TabBarType
    
    let category: Category
    let frameWidth: CGFloat = 310
    
    var body: some View {
        VStack {
            
            Image(systemName: "arrow.triangle.branch")
                .multilineTextAlignment(.center)
                .font(.system(size: 50, weight: .light))
                .foregroundStyle(AppColors.textPrimary)
                .padding(.bottom, 5)
            
            Text("Choose your next quest")
                .multilineTextAlignment(.center)
                .font(.system(size: 25, design: .serif))
                .foregroundStyle(AppColors.textPrimary)
                .padding(.bottom, 40)
                .padding(.horizontal)
              
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack (alignment: .center, spacing: 10) {
                    switch selectedTabSuggestionsList {
                    case 0:
                        LoadingPlaceholderContent(contentType: .newTopic)
                            .frame(width: frameWidth)
                    case 1:
                        if let topic = selectedTopic, let suggestion = topicViewModel.topicGenerated {
                            newTopic(topic: topic, suggestion: suggestion)
                        }
                    default:
                        FocusAreaRetryView(action: {
                            retryTopicSuggestions()
                        })
                        .frame(width: frameWidth)
                    }
                    
                }//Hstack
                .scrollTargetLayout()
                
            }//Scrollview
            .scrollClipDisabled(true)
            .scrollTargetBehavior(.viewAligned)
            .contentMargins(.horizontal, (screenWidth - frameWidth)/2, for: .scrollContent)
            
            Spacer()
        }//VStack
        .onAppear {
            getNewTopic()
        }
        .onChange(of: topicViewModel.topicGenerated) {
            if let _ = topicViewModel.topicGenerated {
                selectedTabSuggestionsList = 1
            }
            
            DispatchQueue.global(qos: .background).async {
                Mixpanel.mainInstance().track(event: "Generated new quests")
            }
        }
        
    }
    
    private func newTopic(topic: Topic, suggestion: NewTopicSuggestion) -> some View {
       
        TopicSuggestionBox(topic: topic, suggestion: suggestion, frameWidth: frameWidth, action: {
                selectTopic(suggestion: suggestion)
            })
            .onTapGesture {
                playHapticEffect += 1
                selectTopic(suggestion: suggestion)
            }
            .sensoryFeedback(.selection, trigger: playHapticEffect)
            .scrollTransition { content, phase in
                content
                    .opacity(phase.isIdentity ? 1 : 0.8)
                    .scaleEffect(x: phase.isIdentity ? 1 : 0.95, y: phase.isIdentity ? 1 : 0.95)
            }
        
    }
    
    private func getNewTopic() {
        guard let existingTopicId = selectedTopic?.topicId else {
            print("No selected topic found. Failed to save topic updates")
            return
        }
        
        Task {
  
            do {
                try await topicViewModel.manageRun(selectedAssistant: .topic, topicId: existingTopicId)
            } catch {
                selectedTabSuggestionsList = 2
            }
            
        }
    }
    
    private func retryTopicSuggestions() {
        selectedTabSuggestionsList = 0
        getNewTopic()
    }
    
    //MARK: Create selected topic and its first focus area
    private func selectTopic(suggestion: NewTopicSuggestion) {
        Task {
           
            
            let (topicId, focusArea) = await createTopic(suggestion: suggestion, category: self.category)
            
            await MainActor.run {
                topicViewModel.createNewFocusArea = .loading
                startNewTopic()
            }
            
            await createFocusArea(topicId: topicId, focusArea: focusArea)

        }
    }
    
    private func createTopic(suggestion: NewTopicSuggestion, category: Category) async -> (topicId: UUID?, focusArea: FocusArea?) {
        
        guard let existingTopicId = selectedTopic?.topicId else {
            print("No selected topic found. Failed to save topic updates")
            selectedTabSuggestionsList = 2
            return (nil, nil)
        }
        
        //save selected topic to coredata
        let (topicId, focusArea) = await dataController.createTopic(suggestion: suggestion, topicId: existingTopicId, category: category)
  
        return (topicId, focusArea)
    }
    
    private func startNewTopic() {
        //close sheet
        dismiss()
        
        //navigate to new topic
        selectedTopic = dataController.newTopic
        dataController.newTopic = nil
        
        navigateToTopicDetailView = true
        withAnimation(.snappy(duration: 0.2)) {
            currentTabBar = .topic
        }
        
        DispatchQueue.global(qos: .background).async {
            Mixpanel.mainInstance().track(event: "Chose new quest")
        }
       
    }
    
    private func createFocusArea(topicId: UUID?, focusArea: FocusArea?) async {
       
        do {
            if let topicId = topicId, let focusArea = focusArea {
                
                try await topicViewModel.manageRun(selectedAssistant: .focusArea, topicId: topicId, focusArea: focusArea)
            }
        } catch {
            topicViewModel.createNewFocusArea = .retry
        }
        
    }
    
    
   
}

struct TopicSuggestionBox: View {
    let topic: Topic
    let suggestion: NewTopicSuggestion
    let frameWidth: CGFloat
    let action: () -> Void
    
    var totalFocusAreas: Int {
        return suggestion.focusAreas.count
    }
    
    var body: some View {
        VStack (spacing: 20) {
            
            Text(topic.topicEmoji)
                .multilineTextAlignment(.center)
                .font(.system(size: 40))
                .foregroundStyle(AppColors.textPrimary)
              
            
            Text(topic.topicDefinition)
                .multilineTextAlignment(.center)
                .font(.system(size: 21, weight: .semibold, design: .serif))
                .foregroundStyle(AppColors.textPrimary)
                .fixedSize(horizontal: false, vertical: true)
                .lineSpacing(1.3)
                .padding(.horizontal)
                .padding(.bottom, 10)

            getFocusAreasList()
                .padding(.horizontal)
            
            Spacer()
            
            RoundButton(buttonImage: "arrow.forward", size: 20, frameSize: 70, buttonAction: {
                action()
            })
           
        }
        .frame(width: frameWidth, height: 420)
        .padding(.top, 30)
        .padding(.bottom, 40)
        .contentShape(Rectangle())
        .background {
            RoundedRectangle(cornerRadius: 25)
                .stroke(AppColors.whiteDefault.opacity(0.1), lineWidth: 0.5)
                .fill(AppColors.boxGrey4.opacity(0.3))
                .shadow(color: .black.opacity(0.05), radius: 15, x: 0, y: 3)
                .blendMode(.colorDodge)
        }
        
    }
    
    private func getFocusAreasList() -> some View {
        
        VStack (alignment: .leading, spacing: 0) {
            ScrollView {
                VStack(alignment: .leading, spacing: 3) {
                    
                    
                    ForEach(Array(suggestion.focusAreas.enumerated()), id: \.element.focusAreaNumber) { index, focusArea in
                        timelineItem(number: index, text: focusArea.content)
                        
                        if index < totalFocusAreas - 1 {
                            connectingLine()
                        }
                    }
                    
                }
                .padding()
                .mask(
                    LinearGradient(
                        gradient: Gradient(stops: [
                            .init(color: .white.opacity(0.4), location: 0.0),
                            .init(color: .white.opacity(0.8), location: 0.65),
                            .init(color: .white, location: 1)
                        ]),
                        startPoint: .bottom,
                        endPoint: .top
                    )
                )
                
            }
            .scrollIndicators(.hidden)
            .frame(height: totalFocusAreas < 3 ? 90 : 130)
           
        }
        .background {
            getRectangle()
        }
        
    }
    
    private func timelineItem(number: Int, text: String) -> some View {
       HStack(spacing: 10) {
           
           Image(systemName: "\(number + 1).circle.fill")
               .font(.system(size: 15))
               .foregroundStyle(AppColors.textPrimary)
               
            
           HStack (spacing: 3) {
               Text(text)
                   .font(.system(size: 15, weight: .light))
                   .fontWidth(.condensed)
                   .foregroundStyle(AppColors.textPrimary)
               
               if number == totalFocusAreas {
               Image(systemName: "arrow.turn.right.down")
                   .font(.system(size: 19, weight: .light))
                   .fontWidth(.condensed)
                   .foregroundStyle(AppColors.textPrimary)
               }
           }
           
           Spacer()
            
       }
      
   }
       
   private func connectingLine() -> some View {
       RoundedRectangle(cornerRadius: 30)
           .fill(Color.white.opacity(0.8))
           .frame(width: 1, height: 15)
           .padding(.leading, 8.5)
           
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
