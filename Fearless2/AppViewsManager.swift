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

    
    @StateObject var transcriptionViewModel: TranscriptionViewModel
    @StateObject var understandViewModel: UnderstandViewModel
    @StateObject var topicViewModel: TopicViewModel
    
    @State private var selectedTab: TabBarItem = .topics
    @State private var showCreateNewTopicView: Bool = false
    @State private var selectedCategory: TopicCategoryItem = .personal
    @State private var selectedTopic: Topic? = nil
    @State private var showAskQuestionView: Bool = false
    @State private var askQuestionTab: Int = 0 //to control which view shows up when showAskQuestionView is true
    @State private var showUnderstandQuestionsList: Bool = false
     
    init(dataController: DataController, openAISwiftService: OpenAISwiftService) {

        let transcriptionViewModel = TranscriptionViewModel(openAISwiftService: openAISwiftService, dataController: dataController)
        let understandViewModel = UnderstandViewModel(openAISwiftService: openAISwiftService, dataController: dataController)
        
        _transcriptionViewModel = StateObject(wrappedValue: transcriptionViewModel)
        _understandViewModel = StateObject(wrappedValue: understandViewModel)
        
        let topicViewModel = TopicViewModel(openAISwiftService: openAISwiftService, dataController: dataController, transcriptionViewModel: transcriptionViewModel)
        _topicViewModel = StateObject(wrappedValue: topicViewModel)
        
        
    }

    var body: some View {
        NavigationStack {
            ZStack {
                switch selectedTab {
                case .topics:
                    ActiveTopicsView(topicViewModel: topicViewModel, transcriptionViewModel: transcriptionViewModel, showCreateNewTopicView: $showCreateNewTopicView, selectedTopic: $selectedTopic)
                case .understand:
                    UnderstandView(understandViewModel: understandViewModel, showAskQuestionView: $showAskQuestionView, showUnderstandQuestionsList: $showUnderstandQuestionsList, askQuestionTab: $askQuestionTab)
                }
                
                TabBar(selectedTab: $selectedTab)
                
            }
          
            .toolbarBackground(Color.black)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    getTopBarLeadingItem()
                }
                
                ToolbarItem(placement: .topBarTrailing) {
                    ProfileToolbarItem()
                }
            }
            .navigationBarTitleDisplayMode(.inline)
           
        }
        .environment(\.colorScheme, .dark)
        .tint(Color.black)
        .overlay  {
            if showCreateNewTopicView {
                CreateNewTopicView(topicViewModel: topicViewModel, showCreateNewTopicView: $showCreateNewTopicView, selectedCategory: selectedCategory)
            } else if showAskQuestionView {
                UnderstandAskQuestionView(understandViewModel: understandViewModel, showAskQuestionView: $showAskQuestionView, askQuestionTab: $askQuestionTab)
            }
        }
    }
    
    private func getTopBarLeadingItem() -> some View {
        Group {
            switch selectedTab {
            case .topics:
                ToolbarTitleItem(title: "Your Topics", regularSize: true)
            case .understand:
                UnderstandToolbarItem(action: {
                    showUnderstandQuestionsList = true
                })
            }
        }
    }
}



//#Preview {
//    AppViewsManager()
//}
