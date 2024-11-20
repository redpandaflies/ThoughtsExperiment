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
    @StateObject var transcriptionViewModel: TranscriptionViewModel
    
    @State private var selectedTab: TabBarItem = .topics
    @State private var showCreateNewTopicView: Bool = false
    @State private var selectedCategory: TopicCategoryItem = .personal
    @State private var selectedQuestion: String = "" //question the user is answering when updating a topic
    @State private var selectedTopic: Topic? = nil
    
    init(dataController: DataController, openAISwiftService: OpenAISwiftService) {

        let transcriptionViewModel = TranscriptionViewModel(openAISwiftService: openAISwiftService, dataController: dataController)
        _transcriptionViewModel = StateObject(wrappedValue: transcriptionViewModel)
        
        let topicViewModel = TopicViewModel(openAISwiftService: openAISwiftService, dataController: dataController, transcriptionViewModel: transcriptionViewModel)
        _topicViewModel = StateObject(wrappedValue: topicViewModel)
    }
    
    
    var body: some View {
        NavigationStack {
            ZStack {
                switch selectedTab {
                case .topics:
                    ActiveTopicsView(topicViewModel: topicViewModel, transcriptionViewModel: transcriptionViewModel, showCreateNewTopicView: $showCreateNewTopicView, selectedTopic: $selectedTopic)
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
        .tint(.black)
        .environment(\.colorScheme, .dark)
        .overlay  {
            if showCreateNewTopicView {
                CreateNewTopicView(topicViewModel: topicViewModel, showCreateNewTopicView: $showCreateNewTopicView, selectedCategory: selectedCategory)
            }
        }
    }
}



//#Preview {
//    AppViewsManager()
//}
