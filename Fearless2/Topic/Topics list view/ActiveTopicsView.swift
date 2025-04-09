//
//  ActiveTopicsView.swift
//  Fearless2
//
//  Created by Yue Deng-Wu on 11/7/24.
//
import CoreData
import SwiftUI

struct ActiveTopicsView: View {
    @ObservedObject var topicViewModel: TopicViewModel
    @Binding var showCreateNewTopicView: Bool
    @Binding var selectedTopic: Topic?
    @Binding var currentTabBar: TabBarType
    @Binding var selectedTabTopic: TopicPickerItem
    @Binding var navigateToTopicDetailView: Bool
    @Binding var topicScrollPosition: Int?
    @Binding var categoriesScrollPosition: Int?
    
    let topics: FetchedResults<Topic>
    @ObservedObject var points: Points
    let totalCategories: Int
   
    
    let frameWidth: CGFloat = 270
    var safeAreaPadding: CGFloat {
        return (UIScreen.main.bounds.width - frameWidth)/2
    }
    
    @AppStorage("currentCategory") var currentCategory: Int = 0
    
    var body: some View {
        ScrollView (.horizontal) {
            TopicsListContent(
                topicViewModel: topicViewModel,
                topics: topics,
                onTopicTap: { index ,topic in
                    onTopicTap(index: index, topic: topic)
                },
                showAddButton: true,
                onAddButtonTap: {
                    createNewTopic()
                }, frameWidth: frameWidth
            )
            .scrollTargetLayout()
            .navigationDestination(isPresented: $navigateToTopicDetailView) {
                if let topic = selectedTopic {
                    TopicDetailView(topicViewModel: topicViewModel, points: points, selectedTabTopic: $selectedTabTopic, topic: topic, totalCategories: totalCategories)
                        .toolbarRole(.editor) //removes the word "back" in the back button
                        
                }
            }
        }//Scrollview
        .scrollPosition(id: $topicScrollPosition, anchor: .center)
        .contentMargins(.horizontal, safeAreaPadding, for: .scrollContent)
        .scrollClipDisabled(true)
        .scrollTargetBehavior(.viewAligned)
        .scrollIndicators(.hidden)
        .onAppear {
            withAnimation(.snappy(duration: 0.2)) {
                currentTabBar = .home
            }
            if topicViewModel.scrollToAddTopic {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    withAnimation(.smooth(duration: 0.2)) {
                        topicScrollPosition = topics.count
                    }
                    topicViewModel.scrollToAddTopic = false
                }
            }
        }
        
        .onDisappear {
            if navigateToTopicDetailView {
                
                withAnimation(.snappy(duration: 0.2)) {
                    currentTabBar = .topic
                }
            }
        }
        
        
    }
    
    private func onTopicTap(index: Int, topic: Topic) {
        //set selected topic ID so that delete topic works
        selectedTopic = topic
        
        if let scrollPosition = categoriesScrollPosition {
            currentCategory = scrollPosition
        }
        navigateToTopicDetailView = true
        
        //change footer
        withAnimation(.snappy(duration: 0.2)) {
            currentTabBar = .topic
        }
    }
    
    private func createNewTopic() {
        if let scrollPosition = categoriesScrollPosition {
            currentCategory = scrollPosition
        }
        showCreateNewTopicView = true
    }
}

//#Preview {
//    ActiveTopicsView()
//}
