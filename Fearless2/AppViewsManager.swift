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
    
    @State private var currentTabBar: TabBarType = .home
    @State private var selectedTabHome: TabBarItemHome = .topics
    @State private var selectedTabTopic: TopicPickerItem = .explore
    @State private var navigateToTopicDetailView: Bool = false
   
    @State private var selectedTopic: Topic? = nil
    @State private var showAskQuestionView: Bool = false
    @State private var askQuestionTab: Int = 0 //to control which view shows up when showAskQuestionView is true

     
    init(dataController: DataController, openAISwiftService: OpenAISwiftService) {

        let transcriptionViewModel = TranscriptionViewModel(openAISwiftService: openAISwiftService, dataController: dataController)
        let understandViewModel = UnderstandViewModel(openAISwiftService: openAISwiftService, dataController: dataController)
        
        _transcriptionViewModel = StateObject(wrappedValue: transcriptionViewModel)
        _understandViewModel = StateObject(wrappedValue: understandViewModel)
        
        let topicViewModel = TopicViewModel(openAISwiftService: openAISwiftService, dataController: dataController, transcriptionViewModel: transcriptionViewModel)
        _topicViewModel = StateObject(wrappedValue: topicViewModel)
        
        
    }

    var body: some View {
      
            ZStack {
                switch selectedTabHome {
                default:
                    CategoryView(topicViewModel: topicViewModel, transcriptionViewModel: transcriptionViewModel, selectedTopic: $selectedTopic, currentTabBar: $currentTabBar, selectedTabTopic: $selectedTabTopic, navigateToTopicDetailView: $navigateToTopicDetailView)
                    //                case .understand:
                    //                    UnderstandView(understandViewModel: understandViewModel, showAskQuestionView: $showAskQuestionView, askQuestionTab: $askQuestionTab)
                }
                
                
                TabBar(transcriptionViewModel: transcriptionViewModel, currentTabBar: $currentTabBar, selectedTabHome: $selectedTabHome, selectedTabTopic: $selectedTabTopic, navigateToTopicDetailView: $navigateToTopicDetailView, topic: selectedTopic)
                    .transition(.move(edge: .bottom))
                
            } //ZStack
            .ignoresSafeArea(.all)
       
//        .overlay  {
//           if showAskQuestionView {
//                UnderstandAskQuestionView(understandViewModel: understandViewModel, showAskQuestionView: $showAskQuestionView, askQuestionTab: $askQuestionTab)
//            }
//        }
        
    }
    
}



//#Preview {
//    AppViewsManager()
//}
