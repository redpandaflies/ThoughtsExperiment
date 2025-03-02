//
//  CategoryView.swift
//  Fearless2
//
//  Created by Yue Deng-Wu on 2/7/25.
//
import CloudStorage
import CoreData
import SwiftUI

struct CategoryView: View {
    @ObservedObject var topicViewModel: TopicViewModel
    @ObservedObject var transcriptionViewModel: TranscriptionViewModel
    @EnvironmentObject var dataController: DataController
    
    @State private var categoriesScrollPosition: Int?
    @State private var showSettingsView: Bool = false
    @State private var animationStage: Int = 0
    @State private var showTutorialSheetView: Bool = false
    
    
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
    @AppStorage("showTopics") var showTopics: Bool = false
    @CloudStorage("discoveredFirstCategory") var firstCategory: Bool = false
    
    var body: some View {
        NavigationStack {
            VStack {
                // MARK: - Categories Scroll View
                if categories.count > 1 {
                    CategoriesScrollView(categoriesScrollPosition: $categoriesScrollPosition, categories: categories)
                } else {
                    Text(categories[0].categoryEmoji)
                        .font(.system(size: (!firstCategory && animationStage == 0) ? 100 : 50))
                        .padding(.bottom, -10)
                }
                
                // MARK: - Category description
                if let scrollPosition = categoriesScrollPosition {
                    CategoryDescriptionView(animationStage: $animationStage, category: categories[scrollPosition])
                        .padding(.vertical, 25)
                        .padding(.horizontal, (!firstCategory && animationStage < 1) ? 15: 30)
                }
                
                // MARK: - To do
//                CategoryMissionBox()
//                    .padding(.horizontal)
//                    .padding(.bottom, 25)
                
                if showTopics {
                    // MARK: - Quest header
                    CategoryQuestsHeading()
                        .padding(.horizontal)
                        .padding(.bottom, 25)
                        .padding(.top, 20)
                    
                    // MARK: - Topics list
                    if let scrollPosition = categoriesScrollPosition, let currentPoints = points.first {
                        TopicsListView(topicViewModel: topicViewModel, transcriptionViewModel: transcriptionViewModel, selectedTopic: $selectedTopic, currentTabBar: $currentTabBar, selectedTabTopic: $selectedTabTopic, navigateToTopicDetailView: $navigateToTopicDetailView, categoriesScrollPosition: $categoriesScrollPosition, category: categories[scrollPosition], points: currentPoints)
                    }
                }
            } //VStack
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: (!firstCategory && animationStage == 0) ? .center : .top)
            .padding(.top, (!firstCategory && animationStage == 0) ? 0 : 30)
            .background {
                BackgroundPrimary(backgroundColor: getCategoryBackground())
            }
            .onAppear {
                setupView()
               
            }
            .onChange(of: firstCategory) {
                if firstCategory {
                    withAnimation(.snappy(duration: 0.25)) {
                        showTopics = true
                    }
                }
            }
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    SettingsToolbarItem(action: {
                        showSettingsView = true
                    })
                    .opacity(firstCategory ? 1 : 0)
                }
                
                ToolbarItem(placement: .principal) {
                    ToolbarTitleItem(title: "Forgotten Realms")
                        .opacity(firstCategory ? 1 : 0)
                }
                
                ToolbarItem(placement: .topBarTrailing) {
                    LaurelItem(size: 15, points: "\(Int(points.first?.total ?? 0))")
                        .opacity(firstCategory ? 1 : 0)
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
            .sheet(isPresented: $showTutorialSheetView, onDismiss: {
                showTutorialSheetView = false
            }) {
                TutorialFirstRealm(backgroundColor: getCategoryBackground())
                    .presentationDetents([.fraction(0.65)])
                    .presentationCornerRadius(30)
                
            }
            
        }
        .environment(\.colorScheme, .dark)
    }
    
    private func setupView() {
      
        categoriesScrollPosition = currentCategory
        
        if !firstCategory {
            startAnimation()
        }
 
    }
    
    private func startAnimation() {
        // Initial state
        animationStage = 0
        
        // First stage: Move to smaller layout
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            withAnimation(.smooth(duration: 0.25)) {
                animationStage = 1
            }
        }
        
        // Second stage: Fade in description
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            withAnimation(.smooth(duration: 0.3)) {
                animationStage = 2
            }
           
        }
        
        // Show tutorial sheet
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.5) {
            firstCategory = true
            showTutorialSheetView = true
        }
    }
    
    private func getCategoryBackground() -> Color {
        if let scrollPosition = categoriesScrollPosition {
            return Realm.getBackgroundColor(forName: categories[scrollPosition].categoryName)
        }
        
        return AppColors.backgroundCareer
    }
}
