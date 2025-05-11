//
//  TopicExpectationsView.swift
//  Fearless2
//
//  Created by Yue Deng-Wu on 4/14/25.
//
import OSLog
import SwiftUI

struct TopicExpectationsView: View {
    @EnvironmentObject var dataController: DataController
    @ObservedObject var topicViewModel: TopicViewModel
    
    @State private var expectationsScrollPosition: Int?
    @State private var disableButton: Bool = true
    
    @Binding var showTopicExpectationsSheet: Bool
    
    let topic: Topic?
    let goal: String
    let sequence: Sequence?
    let expectations: [TopicExpectation]
    let backgroundColor: Color
    
    let screenWidth = UIScreen.current.bounds.width
    
    var sortedExpectations: [TopicExpectation] {
        return expectations.sorted { $0.orderIndex < $1.orderIndex }
    }
    
    let logger = Logger.uiEvents
    
    var body: some View {
        
        VStack (alignment: .leading, spacing: 10) {
            
            getHeader(xmarkAction: {
                //dismiss
                showTopicExpectationsSheet = false
            })
            .padding(.bottom)
            
            Text("What to expect")
                .multilineTextAlignment(.leading)
                .font(.system(size: 25, design: .serif))
                .foregroundStyle(AppColors.textPrimary)
                .fixedSize(horizontal: false, vertical: true)
                .padding(.bottom)
                .padding(.horizontal)
            
            CarouselView(items: sortedExpectations, scrollPosition: $expectationsScrollPosition, pagesCount: sortedExpectations.count) { index, expectation in
                CarouselBox(orderIndex: index + 1, content: expectation.expectationContent)
            }
            .padding(.horizontal, 15)
            
            Spacer()
            
            // MARK: Next button
            RectangleButtonPrimary(
                buttonText: "Continue",
                action: {
                    completeTopic()
                },
                disableMainButton: disableButton,
                buttonColor: .white)
                .padding(.horizontal)
            
        }//VStack
        .padding(.bottom)
        .frame(maxHeight: .infinity, alignment: .top)
        .background {
            BackgroundPrimary(backgroundColor: backgroundColor)
        }
        .onAppear {
            if let topic = topic, topic.topicStatus == TopicStatusItem.completed.rawValue {
                disableButton = false
            } else {
                getTopicQuestions()
            }
        }
        .onChange(of: expectationsScrollPosition) {
            if (expectationsScrollPosition == sortedExpectations.count - 1) && (topic?.topicStatus != TopicStatusItem.completed.rawValue) {
                if disableButton {
                    disableButton = false
                }
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
            }
            await MainActor.run {
                showTopicExpectationsSheet = false
                topicViewModel.completedNewTopic = true
            }
        }
    }
    
    private func getTopicQuestions() {
        topicViewModel.createTopicQuestions = .loading
        
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
                try await topicViewModel.manageRun(selectedAssistant: .topic, topic: nextTopic.first)
                
            } catch {
                topicViewModel.createTopicQuestions = .retry
            }
            
        }
        
    }
}


