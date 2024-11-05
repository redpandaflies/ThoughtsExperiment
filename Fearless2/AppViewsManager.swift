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
    
    @State private var showCreateNewTopicView: Bool = false
    @State private var showUpdateTopicView: Bool? = nil
    @State private var showSectionRecapView: Bool = false
    @State private var selectedCategory: TopicCategoryItem = .personal
    @State private var topicId: UUID? = nil  //for updating topic
    @State private var selectedQuestion: String = "" //question the user is answering when updating a topic
    @State private var selectedSection: Section? = nil
    
    init(dataController: DataController, openAISwiftService: OpenAISwiftService) {
        
        let topicViewModel = TopicViewModel(openAISwiftService: openAISwiftService, dataController: dataController)
        
        _topicViewModel = StateObject(wrappedValue: topicViewModel)
    }
    
    
    var body: some View {
        NavigationStack {
            HomeView(topicViewModel: topicViewModel, showCreateNewTopicView: $showCreateNewTopicView, showUpdateTopicView: $showUpdateTopicView, showSectionRecapView: $showSectionRecapView, selectedCategory: $selectedCategory, topicId: $topicId, selectedQuestion: $selectedQuestion, selectedSection: $selectedSection)
        }
        .environment(\.colorScheme, .light)
        .overlay  {
            if showCreateNewTopicView {
                CreateNewTopicView(topicViewModel: topicViewModel, showCreateNewTopicView: $showCreateNewTopicView, selectedCategory: selectedCategory)
            } else if let showingUpdateTopicView = showUpdateTopicView, showingUpdateTopicView {
                UpdateTopicView(topicViewModel: topicViewModel, showUpdateTopicView: $showUpdateTopicView, selectedCategory: selectedCategory, topicId: topicId, question: selectedQuestion, section: selectedSection)
            } else if showSectionRecapView {
                SectionRecapView(topicViewModel: topicViewModel, showSectionRecapView: $showSectionRecapView, topicId: $topicId, selectedCategory: selectedCategory)
            }
        }
    }
}

//#Preview {
//    AppViewsManager()
//}
