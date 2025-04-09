//
//  MainAppManager.swift
//  Fearless2
//
//  Created by Yue Deng-Wu on 2/27/25.
//

import SwiftUI

struct MainAppManager: View {
 
    @ObservedObject var understandViewModel: UnderstandViewModel
    @ObservedObject var topicViewModel: TopicViewModel
    
    @State private var currentTabBar: TabBarType = .home
    @State private var selectedTabHome: TabBarItemHome = .topics
    @State private var selectedTabTopic: TopicPickerItem = .paths
    @State private var navigateToTopicDetailView: Bool = false
   
    @State private var selectedTopic: Topic? = nil
    @State private var showAskQuestionView: Bool = false
    @State private var askQuestionTab: Int = 0 //to control which view shows up when showAskQuestionView is true
    
    var body: some View {
        ZStack {
            switch selectedTabHome {
            default:
                CategoryView(topicViewModel: topicViewModel, selectedTopic: $selectedTopic, currentTabBar: $currentTabBar, selectedTabTopic: $selectedTabTopic, navigateToTopicDetailView: $navigateToTopicDetailView)
                //                case .understand:
                //                    UnderstandView(understandViewModel: understandViewModel, showAskQuestionView: $showAskQuestionView, askQuestionTab: $askQuestionTab)
            }
            
            
            TabBar(currentTabBar: $currentTabBar, selectedTabHome: $selectedTabHome, selectedTabTopic: $selectedTabTopic, navigateToTopicDetailView: $navigateToTopicDetailView, topic: selectedTopic)
                .transition(.move(edge: .bottom))
            
        } //ZStack
        .ignoresSafeArea(.all)
        .environment(\.colorScheme, .dark)
    }
}

//#Preview {
//    MainAppManager()
//}
