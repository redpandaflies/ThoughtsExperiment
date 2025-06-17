//
//  MainAppManager.swift
//  Fearless2
//
//  Created by Yue Deng-Wu on 2/27/25.
//
import CoreData
import SwiftUI

struct MainAppManager: View {
    @EnvironmentObject var viewModelFactoryMain: ViewModelFactoryMain
    @ObservedObject var topicViewModel: TopicViewModel
    
    @State private var currentTabBar: TabBarType = .home
    @State private var selectedTabHome: TabBarItemHome = .daily
    @State private var selectedTabTopic: TopicPickerItem = .paths
    @State private var navigateToTopicDetailView: Bool = false
   
    @State private var selectedTopic: Topic? = nil
    @State private var showAskQuestionView: Bool = false
    @State private var askQuestionTab: Int = 0 //to control which view shows up when showAskQuestionView is true
    
    @FetchRequest(
        sortDescriptors: []
    ) var points: FetchedResults<Points>
    
    var currentPoints: Int {
        return Int(points.first?.total ?? 1)
    }
    
    var body: some View {
        ZStack {
            switch selectedTabHome {
            case .daily:
                DailyReflectionView(
                    dailyTopicViewModel: viewModelFactoryMain.makeDailyTopicViewModel(),
                    topicViewModel: topicViewModel,
                    currentPoints: currentPoints
                )
                
            default:
                GoalsView(
                    topicViewModel: topicViewModel,
                    selectedTopic: $selectedTopic,
                    currentTabBar: $currentTabBar,
                    selectedTabTopic: $selectedTabTopic,
                    currentPoints: currentPoints
                )
            }
            
            
           TabBar(selectedTabHome: $selectedTabHome)
            
        } //ZStack
        .ignoresSafeArea(.all)
    }
}

//#Preview {
//    MainAppManager()
//}
