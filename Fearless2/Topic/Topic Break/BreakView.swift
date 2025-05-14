//
//  BreakView.swift
//  Fearless2
//
//  Created by Yue Deng-Wu on 5/3/25.
//
import Mixpanel
import OSLog
import SwiftUI

struct BreakView: View {
    @EnvironmentObject var dataController: DataController
    @ObservedObject var topicViewModel: TopicViewModel
    
    @State private var breakScrollPosition: Int?
    @State private var disableButton: Bool = true
    @State private var selectedTabBreak: Int = 0
    
    @Binding var showTopicBreakView: Bool
    
    let topic: Topic?
    let goal: String
    let sequence: Sequence?
    let backgroundColor: Color
    
    let screenWidth = UIScreen.current.bounds.width
    
    var sortedBreakCards: [TopicBreak] {
        if let breakCards = topic?.topicBreaks {
            return breakCards.sorted { $0.orderIndex < $1.orderIndex }
        }
        
        return []
    }
    
    let logger = Logger.uiEvents
    
    var body: some View {
        
        VStack (alignment: .leading, spacing: 10) {
            
            getHeader(xmarkAction: {
                //dismiss
                showTopicBreakView = false
            })
            .padding(.bottom)
            
            Text(topic?.topicTitle ?? "")
                .multilineTextAlignment(.leading)
                .font(.system(size: 25, design: .serif))
                .foregroundStyle(AppColors.textPrimary)
                .fixedSize(horizontal: false, vertical: true)
                .padding(.bottom)
            
            
            switch selectedTabBreak {
            case 0:
                LoadingPlaceholderContent(contentType: .newTopic)
                    .frame(maxWidth: .infinity, alignment: .center)
                  
            case 1:
                CarouselView(
                    items: sortedBreakCards,
                    scrollPosition: $breakScrollPosition,
                    pagesCount: sortedBreakCards.count) { index, card in
                        
                        CarouselBox(orderIndex: index + 1, content: card.breakContent)
                    }
                    .padding(.horizontal, -1) //to hide the vertical edge of the previous box when view scrolls
                
            default:
                FocusAreaRetryView(action: {
                    getTopicBreak()
                })
                .frame(maxWidth: .infinity, alignment: .center)
               
            }
            Spacer()
            
            // MARK: Next button
            RectangleButtonPrimary(
                buttonText: "Continue",
                action: {
                    completeTopic()
                },
                disableMainButton: disableButton,
                buttonColor: .white)
            
        }//VStack
        .padding(.bottom)
        .padding(.horizontal)
        .frame(maxHeight: .infinity, alignment: .top)
        .background {
            BackgroundPrimary(backgroundColor: backgroundColor)
        }
        .onAppear {
            guard let topic = topic else {return}
            
            if topic.topicStatus == TopicStatusItem.completed.rawValue {
                selectedTabBreak = 1
                disableButton = false
            } else if topic.topicBreaks.isEmpty && topicViewModel.createTopicBreak == .ready {
                getTopicBreak()
            } else {
                switch topicViewModel.createTopicBreak {
                case .ready:
                    topicBreakReady()
                case .loading:
                    selectedTabBreak = 0
                case .retry:
                    selectedTabBreak = 2
                }
                
            }
        }
        .onChange(of: breakScrollPosition) {
            if (breakScrollPosition == sortedBreakCards.count - 1) && (topic?.topicStatus != TopicStatusItem.completed.rawValue) {
                if disableButton {
                    disableButton = false
                }
            }
        }
        .onChange(of: topicViewModel.createTopicBreak) {
            switch topicViewModel.createTopicBreak {
            case .ready:
                topicBreakReady()
            case .loading:
                selectedTabBreak = 0
            case .retry:
                selectedTabBreak = 2
            }
        }
    }
    
    
    private func getHeader(xmarkAction: @escaping () -> Void) -> some View {
        HStack (spacing: 0) {
            ToolbarTitleItem2(
                emoji: "",
                title: goal
            )
            
            Button {
                xmarkAction()
            } label: {
                
                Image(systemName: "xmark.circle.fill")
                    .font(.system(size: 25))
                    .foregroundStyle(AppColors.progressBarPrimary.opacity(0.3))
            }
    
        }//HStack
        .frame(maxWidth: .infinity)
        .padding(.top)
        .padding(.bottom, 15)
        
    }
    
    private func completeTopic() {
        Task {
            if let topic = topic, topic.topicStatus != TopicStatusItem.completed.rawValue {
                await dataController.completeTopic(topic: topic)
                
                DispatchQueue.global(qos: .background).async {
                    Mixpanel.mainInstance().track(event: "Completed break step")
                }
            }
            await MainActor.run {
                showTopicBreakView = false
                topicViewModel.completedNewTopic = true
            }
        }
    }
    
    private func getTopicBreak() {
        topicViewModel.createTopicBreak = .loading
        
        // get the next topic
        guard let sequenceTopics = sequence?.sequenceTopics else {
            logger.log("No sequence topics found")
            return
        }
        
        guard let topic = topic else {
            logger.log("No selected topic found")
            return
        }
        
        let nextTopicIndex = topic.orderIndex + 1
        
        let nextTopic = sequenceTopics
            .filter { $0.orderIndex == nextTopicIndex }
            
        
        Task {
            do {
               
                try await topicViewModel.manageRun(selectedAssistant: .topicBreak, topic: topic)
              
                
            } catch {
                topicViewModel.createTopicBreak = .retry
            }
            
            await getTopicQuestions(nextTopic: nextTopic.first)
            
        }
    }
    
    
    private func topicBreakReady() {
        selectedTabBreak = 1
        
        // get the next topic
        guard let sequenceTopics = sequence?.sequenceTopics else {
            logger.log("No sequence topics found")
            return
        }
        
        guard let topic = topic else {
            logger.log("No selected topic found")
            return
        }
        
        let nextTopicIndex = topic.orderIndex + 1
        
        let nextTopic = sequenceTopics
            .filter { $0.orderIndex == nextTopicIndex }
        
        Task {
            await getTopicQuestions(nextTopic: nextTopic.first)
        }
    }
    
    private func getTopicQuestions(nextTopic: Topic?) async {
        do {
           
            try await topicViewModel.manageRun(selectedAssistant: .topic, topic: nextTopic)
          
            
        } catch {
            topicViewModel.createTopicQuestions = .retry
        }

    }
  
}
