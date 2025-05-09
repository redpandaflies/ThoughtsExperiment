//
//  MainAppManager.swift
//  Fearless2
//
//  Created by Yue Deng-Wu on 2/27/25.
//

import SwiftUI

struct MainAppManager: View {
 
    @StateObject var topicViewModel: TopicViewModel
    
    @State private var currentTabBar: TabBarType = .home
    @State private var selectedTabHome: TabBarItemHome = .topics
    @State private var selectedTabTopic: TopicPickerItem = .paths
    @State private var navigateToTopicDetailView: Bool = false
   
    @State private var selectedTopic: Topic? = nil
    @State private var showAskQuestionView: Bool = false
    @State private var askQuestionTab: Int = 0 //to control which view shows up when showAskQuestionView is true
    
    init(
        topicViewModel: TopicViewModel
    ) {
        _topicViewModel = StateObject(wrappedValue: topicViewModel)
    }
    
    var body: some View {
        ZStack {
            switch selectedTabHome {
            default:
                GoalsView(topicViewModel: topicViewModel, selectedTopic: $selectedTopic, currentTabBar: $currentTabBar, selectedTabTopic: $selectedTabTopic)
            }
            
            
//            TabBar(currentTabBar: $currentTabBar, selectedTabHome: $selectedTabHome, selectedTabTopic: $selectedTabTopic, navigateToTopicDetailView: $navigateToTopicDetailView, topic: selectedTopic)
//                .transition(.move(edge: .bottom))
            
        } //ZStack
        .ignoresSafeArea(.all)
    }
}

//#Preview {
//    MainAppManager()
//}
