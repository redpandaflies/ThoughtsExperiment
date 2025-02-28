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
    @State private var showSettingsView: Bool = false
    
    @Binding var selectedTopic: Topic?
    @Binding var currentTabBar: TabBarType
    @Binding var selectedTabTopic: TopicPickerItem
    @Binding var navigateToTopicDetailView: Bool
    
    @FetchRequest(
        sortDescriptors: [
            NSSortDescriptor(key: "orderIndex", ascending: true)
        ]
    ) var categories: FetchedResults<Category>
    
    @FetchRequest(
        sortDescriptors: []
    ) var points: FetchedResults<Points>
    
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
//                CategoryMissionBox()
//                    .padding(.horizontal)
//                    .padding(.bottom, 25)
                
                // MARK: - Quest header
                CategoryQuestsHeading()
                    .padding(.horizontal)
                    .padding(.bottom, 25)
                    .padding(.top, 20)
                
                // MARK: - Topics list
                if let scrollPosition = categoriesScrollPosition, let currentPoints = points.first {
                    TopicsListView(topicViewModel: topicViewModel, transcriptionViewModel: transcriptionViewModel, selectedTopic: $selectedTopic, currentTabBar: $currentTabBar, selectedTabTopic: $selectedTabTopic, navigateToTopicDetailView: $navigateToTopicDetailView, categoriesScrollPosition: $categoriesScrollPosition, category: categories[scrollPosition], points: currentPoints)
                }
                
                Spacer()
            } //VStack
            .padding(.top, 30)
            .background {
                BackgroundPrimary(backgroundColor: getCategoryBackground())
            }
            .onAppear {
                
                Task {
                    if categories.isEmpty {
                       
                            await dataController.addCategoriesToCoreData()
                        
                    } else {
                        
                        await MainActor.run {
                            categoriesScrollPosition = currentCategory
                        }
                    }
                    
                    if points.isEmpty {
                            await dataController.updatePoints(newPoints: 5)
                        
                    }
                }
            }
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    SettingsToolbarItem(action: {
                        showSettingsView = true
                    })
                }
                
                ToolbarItem(placement: .principal) {
                    ToolbarTitleItem(title: "Forgotten Realms")
                }
                
                ToolbarItem(placement: .topBarTrailing) {
                    LaurelItem(size: 15, points: "\(Int(points.first?.total ?? 0))")
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .sheet(isPresented: $showSettingsView, onDismiss: {
                showSettingsView = false
            }, content: {
                SettingsView()
                    .presentationCornerRadius(20)
                    .presentationBackground {
                        Color.clear
                            .background(.regularMaterial)
                            .environment(\.colorScheme, .dark )
                    }
            })
            
        }
        .environment(\.colorScheme, .dark)
    }
    
    private func getCategoryBackground() -> Color {
        if let scrollPosition = categoriesScrollPosition {
            return Realm.getBackgroundColor(forName: categories[scrollPosition].categoryName)
        }
        
        return AppColors.backgroundCareer
    }
}
