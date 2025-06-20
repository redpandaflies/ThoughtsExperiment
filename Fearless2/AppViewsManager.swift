//
//  AppViewsManager.swift
//  Fearless2
//
//  Created by Yue Deng-Wu on 9/30/24.
//
import CoreData
import SwiftUI

struct AppViewsManager: View {
    
    @StateObject private var topicViewModel: TopicViewModel
    
    @State private var currentView: Int = 0
    @State private var selectedTabHome: TabBarItemHome = .daily
    
    @FetchRequest(
        sortDescriptors: [
            NSSortDescriptor(key: "orderIndex", ascending: true)
        ]
    ) var categories: FetchedResults<Category>
    
    @AppStorage("currentAppView") var currentAppView: Int = 0

    init(topicViewModel: TopicViewModel) {
        _topicViewModel = StateObject(wrappedValue: topicViewModel)
    }


    var body: some View {
        Group {
            switch currentView {
                
            case 0:
                
                OnboardingMainView(
                    topicViewModel: topicViewModel,
                    selectedTabHome: $selectedTabHome
                )
                
            default:
//                if !categories.isEmpty {
                MainAppManager(
                    topicViewModel: topicViewModel,
                    selectedTabHome: $selectedTabHome
                )
                .transition(.opacity)
//                } else {
//                    //Should never happen, user should always have categories unless they haven't done onboarding, may come up during testing
//                    OnboardingMainView()
//                }
            }
        }
        .onAppear {
            currentView = currentAppView
        }
        .onChange(of: currentAppView) {
            if currentAppView == 1 {
                withAnimation(.smooth) {
                    currentView = 1
                }
            } else {
                currentView = 0
            }
        }
        
    }
    
}



//#Preview {
//    AppViewsManager()
//}
