//
//  AppViewsManager.swift
//  Fearless2
//
//  Created by Yue Deng-Wu on 9/30/24.
//
import CoreData
import SwiftUI

struct AppViewsManager: View {
    
    @EnvironmentObject var viewModelFactoryMain: ViewModelFactoryMain
    
    @State private var currentView: Int = 0
    
    @FetchRequest(
        sortDescriptors: [
            NSSortDescriptor(key: "orderIndex", ascending: true)
        ]
    ) var categories: FetchedResults<Category>
    
    @AppStorage("currentAppView") var currentAppView: Int = 0

    var body: some View {
        Group {
            switch currentAppView {
            case 0:
                OnboardingMainView()
            default:
//                if !categories.isEmpty {
                    MainAppManager(topicViewModel: viewModelFactoryMain.makeTopicViewModel())
                    
//                } else {
//                    //Should never happen, user should always have categories unless they haven't done onboarding, may come up during testing
//                    OnboardingMainView()
//                }
            }
        }
        .environment(\.colorScheme, .dark)
        .onAppear {
            if currentAppView == 2 {
                withAnimation(.smooth) {
                    currentView = 2
                }
            }
        }
        .onChange(of: currentAppView) {
            if currentAppView == 2 {
                withAnimation(.smooth) {
                    currentView = 2
                }
            } else {
                currentView = 0
            }
        }
        .onAppear {
            if categories.count > 0 && currentAppView == 0 {
                currentAppView = 1
            }
        }
    }
    
}



//#Preview {
//    AppViewsManager()
//}
