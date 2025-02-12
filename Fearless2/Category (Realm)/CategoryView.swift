//
//  CategoryView.swift
//  Fearless2
//
//  Created by Yue Deng-Wu on 2/7/25.
//
import CoreData
import SwiftUI

struct CategoryView: View {
    @ObservedObject var topicViewModel: TopicViewModel
    @ObservedObject var transcriptionViewModel: TranscriptionViewModel
    @EnvironmentObject var dataController: DataController
    
    @State private var categoriesScrollPosition: Int?
    
    @Binding var selectedTopic: Topic?
    @Binding var currentTabBar: TabBarType
    @Binding var selectedTabTopic: TopicPickerItem
    @Binding var navigateToTopicDetailView: Bool
    
    @FetchRequest(
        sortDescriptors: [
            NSSortDescriptor(key: "orderIndex", ascending: true)
        ]
    ) var categories: FetchedResults<Category>
    
    @AppStorage("currentCategory") var currentCategory: Int = 0
    
    var body: some View {
        NavigationStack {
            VStack {
                // MARK: - Categories Scroll View
                CategoriesScrollView(categoriesScrollPosition: $categoriesScrollPosition, categories: categories)
                
                // MARK: - Category description
                if let scrollPosition = categoriesScrollPosition {
                    CategoryDescriptionView(category: categories[scrollPosition])
                        .padding(.vertical, 25)
                        .padding(.horizontal, 30)
                }
                
                // MARK: - To do
                CategoryMissionBox()
                    .padding(.horizontal)
                    .padding(.bottom, 25)
                
                // MARK: - Topics list
                if let scrollPosition = categoriesScrollPosition {
                    TopicsListView(topicViewModel: topicViewModel, transcriptionViewModel: transcriptionViewModel, selectedTopic: $selectedTopic, currentTabBar: $currentTabBar, selectedTabTopic: $selectedTabTopic, navigateToTopicDetailView: $navigateToTopicDetailView, categoriesScrollPosition: $categoriesScrollPosition, category: categories[scrollPosition])
                }
                Spacer()
            } //VStack
            .padding(.top, 30)
            .background {
                Image("backgroundPrimary")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .ignoresSafeArea()
                    .background {
                        AppColors.backgroundCareer
                            .ignoresSafeArea()
                    }
            }
            .onAppear {
                if categories.isEmpty {
                    Task {
                        await dataController.addCategoriesToCoreData()
                    }
                } else {
                    categoriesScrollPosition = currentCategory
                }
            }
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    SettingsToolbarItem(action: {
                        
                    })
                }
                
                ToolbarItem(placement: .principal) {
                    ToolbarTitleItem(title: "The Seven Realms")
                }
                
                ToolbarItem(placement: .topBarTrailing) {
                    ToolbarLaurelItem(points: "5")
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            
        }
        .environment(\.colorScheme, .dark)
    }
}
