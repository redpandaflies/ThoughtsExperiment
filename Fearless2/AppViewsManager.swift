//
//  AppViewsManager.swift
//  Fearless2
//
//  Created by Yue Deng-Wu on 9/30/24.
//

import SwiftUI

struct AppViewsManager: View {
    
    @EnvironmentObject var dataController: DataController
    @EnvironmentObject var openAISwiftService: OpenAISwiftService
    
    @StateObject var topicViewModel: TopicViewModel
    
    @State private var selectedTab: TabBarItem = .topics
    @State private var showFocusAreasView: Bool = false
    @State private var showCreateNewTopicView: Bool = false
    @State private var selectedCategory: TopicCategoryItem = .personal
    @State private var selectedQuestion: String = "" //question the user is answering when updating a topic
    @State private var selectedTopic: Topic? = nil
    
    init(dataController: DataController, openAISwiftService: OpenAISwiftService) {
        
        let topicViewModel = TopicViewModel(openAISwiftService: openAISwiftService, dataController: dataController)
        
        _topicViewModel = StateObject(wrappedValue: topicViewModel)
    }
    
    
    var body: some View {
        NavigationStack {
            ZStack {
                switch selectedTab {
                case .topics:
                    ActiveTopicsView(topicViewModel: topicViewModel, showCreateNewTopicView: $showCreateNewTopicView, selectedTopic: $selectedTopic, showFocusAreasView: $showFocusAreasView)
                case .lifeChart:
                    EmptyView()
                }
                
                TabBar(selectedTab: $selectedTab)
                
            }
            .ignoresSafeArea(.all)
            .ignoresSafeArea(.keyboard)
            .background {
                Color.black
                    .ignoresSafeArea(.all)
            }
        }
        .environment(\.colorScheme, .dark)
        .overlay  {
            if showCreateNewTopicView {
                CreateNewTopicView(topicViewModel: topicViewModel, showCreateNewTopicView: $showCreateNewTopicView, selectedCategory: selectedCategory)
            } else if showFocusAreasView {
                FocusAreasView(topicViewModel: topicViewModel, showFocusAreasView: $showFocusAreasView, selectedCategory: $selectedCategory, topicId: selectedTopic?.topicId)
            }
        }
    }
}

//#Preview {
//    AppViewsManager()
//}
