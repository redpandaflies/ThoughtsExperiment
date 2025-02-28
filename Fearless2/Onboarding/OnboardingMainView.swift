//
//  OnboardingMainView.swift
//  Fearless2
//
//  Created by Yue Deng-Wu on 2/24/25.
//
import CoreData
import SwiftUI

struct OnboardingMainView: View {
    @EnvironmentObject var dataController: DataController
    @State private var selectedTab: Int = 0
    @State private var selectedIntroPage: Int = 0
    @State private var categoriesScrollPosition: Int?
    @State private var selectedCategory: String = ""
    let introContent: [OnboardingIntroContent] = OnboardingIntroContent.pages
    
    @FetchRequest(
        sortDescriptors: [
            NSSortDescriptor(key: "orderIndex", ascending: true)
        ]
    ) var categories: FetchedResults<Category>
    
    var body: some View {
        
        VStack {
            
            switch selectedTab {
                case 0:
                OnboardingIntroView(selectedTab: $selectedTab, selectedIntroPage: $selectedIntroPage, categoriesScrollPosition: $categoriesScrollPosition, categories: categories)
                case 1:
                OnboardingQuestionsView(selectedTab: $selectedTab, categoriesScrollPosition: $categoriesScrollPosition, selectedCategory: $selectedCategory)
                default:
                OnboardingFirstCategoryView(selectedCategory: $selectedCategory)
            }
            
        }
      
        .background {
            BackgroundPrimary(backgroundColor: AppColors.backgroundOnboardingIntro)
        }
        .onAppear {
            
            Task {
                if categories.isEmpty {
                   
                    await dataController.addCategoriesToCoreData()
                    
                } else {
                    await dataController.deleteAll()
                    await dataController.addCategoriesToCoreData()
                    
                    await MainActor.run {
                        categoriesScrollPosition = 3
                    }
                }
            }
        }
    }
  
}


#Preview {
    OnboardingMainView()
}
