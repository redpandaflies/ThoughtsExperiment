//
//  TopicsListView.swift
//  Fearless2
//
//  Created by Yue Deng-Wu on 1/22/25.
//

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
    @State private var selectedCategory: TopicCategoryItem = .personal
    @State private var showCreateNewTopicView: Bool = false
    @State private var topicsList: TopicsList = .active
    
    @Binding var selectedTopic: Topic?
    @Binding var currentTabBar: TabBarType
    @Binding var selectedTabTopic: TopicPickerItem
    @Binding var navigateToTopicDetailView: Bool
    
    
    var body: some View {
        NavigationStack {
            VStack {
                switch topicsList {
                case .active:
                    ActiveTopicsView(topicViewModel: topicViewModel, transcriptionViewModel: transcriptionViewModel, showCreateNewTopicView: $showCreateNewTopicView, selectedTopic: $selectedTopic, currentTabBar: $currentTabBar, selectedTabTopic: $selectedTabTopic, navigateToTopicDetailView: $navigateToTopicDetailView)
                case .archived:
                    ArchivedTopicsView(topicViewModel: topicViewModel, transcriptionViewModel: transcriptionViewModel, selectedTopic: $selectedTopic, currentTabBar: $currentTabBar, selectedTabTopic: $selectedTabTopic, navigateToTopicDetailView: $navigateToTopicDetailView)
                }
                
                
            }//VStack
            .background(AppColors.black4)
            .ignoresSafeArea(.keyboard)
            .toolbarBackground(Color.black)
            .fullScreenCover(isPresented: $showCreateNewTopicView, onDismiss: {
                showCreateNewTopicView = false
            }) {
                NewTopicView(topicViewModel: topicViewModel, selectedTopic: $selectedTopic, navigateToTopicDetailView: $navigateToTopicDetailView, currentTabBar: $currentTabBar)
                    .presentationBackground(AppColors.black4)
            }
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    topBarLeading()
                }
                
                //                ToolbarItem(placement: .topBarTrailing) {
                //                    ProfileToolbarItem()
                //                }
            }
            .navigationBarTitleDisplayMode(.inline)
        }
        .environment(\.colorScheme, .dark)
    }
    
    
    private func topBarLeading() -> some View {
        HStack (spacing: 15) {
            ToolbarTitleItem(title: "Top of mind")
                .opacity(topicsList == .active ? 1 : 0.7)
                .onTapGesture {
                    topicsList = .active
                }
            
            
            ToolbarTitleItem(title: "Archived")
                .opacity(topicsList == .archived ? 1 : 0.7)
                .onTapGesture {
                    topicsList = .archived
                }
        }
    }
}


