//
//  TopicsListView.swift
//  Fearless2
//
//  Created by Yue Deng-Wu on 1/22/25.
//
import CoreData
import SwiftUI

enum TopicsList {
    case active
    case archived
}

struct TopicsListView: View {
    
    @ObservedObject var topicViewModel: TopicViewModel
    @ObservedObject var transcriptionViewModel: TranscriptionViewModel
    
    @State private var showSectionRecapView: Bool = false
    
    @State private var selectedSection: Section? = nil
    @State private var showCreateNewTopicView: Bool = false
//    @State private var topicsList: TopicsList = .active
    @State private var topicScrollPosition: Int?
    
    @Binding var selectedTopic: Topic?
    @Binding var currentTabBar: TabBarType
    @Binding var selectedTabTopic: TopicPickerItem
    @Binding var navigateToTopicDetailView: Bool
    @Binding var categoriesScrollPosition: Int?
    
    @ObservedObject var category: Category
    @ObservedObject var points: Points
    
    var topics: [Topic] {
        return category.categoryTopics.sorted { $0.topicCreatedAt > $1.topicCreatedAt }
    }
    
    var pageCount: Int {
        return topics.count + 1
    }
    
    var body: some View {

            VStack (spacing: 12) {
//                switch topicsList {
//                case .active:
                    ActiveTopicsView(topicViewModel: topicViewModel, transcriptionViewModel: transcriptionViewModel, showCreateNewTopicView: $showCreateNewTopicView, selectedTopic: $selectedTopic, currentTabBar: $currentTabBar, selectedTabTopic: $selectedTabTopic, navigateToTopicDetailView: $navigateToTopicDetailView,
                        topicScrollPosition: $topicScrollPosition, categoriesScrollPosition: $categoriesScrollPosition,
                        topics: topics,
                        points: points
                    )
//                case .archived:
//                    ArchivedTopicsView(topicViewModel: topicViewModel, transcriptionViewModel: transcriptionViewModel, selectedTopic: $selectedTopic, currentTabBar: $currentTabBar, selectedTabTopic: $selectedTabTopic, navigateToTopicDetailView: $navigateToTopicDetailView)
//                }
                
                if pageCount > 1 {
                    PageIndicatorView(scrollPosition: $topicScrollPosition, pagesCount: pageCount)
                }
                
            }//VStack
            .sheet(isPresented: $showCreateNewTopicView, onDismiss: {
                showCreateNewTopicView = false
            }) {
                NewTopicView(topicViewModel: topicViewModel, selectedTopic: $selectedTopic, navigateToTopicDetailView: $navigateToTopicDetailView, currentTabBar: $currentTabBar, category: category)
                    .presentationBackground(.thinMaterial)
                    .presentationDetents([.fraction(0.6)])
                    .presentationCornerRadius(30)
                
            }

    }
    
    
//    private func topBarLeading() -> some View {
//        HStack (spacing: 15) {
//            ToolbarTitleItem(title: "Top of mind")
//                .opacity(topicsList == .active ? 1 : 0.7)
//                .onTapGesture {
//                    topicsList = .active
//                }
//            
//            
//            ToolbarTitleItem(title: "Archived")
//                .opacity(topicsList == .archived ? 1 : 0.7)
//                .onTapGesture {
//                    topicsList = .archived
//                }
//        }
//    }
}


