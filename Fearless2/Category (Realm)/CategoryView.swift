//
//  CategoryView.swift
//  Fearless2
//
//  Created by Yue Deng-Wu on 2/7/25.
//
import CloudStorage
import CoreData
import Pow
import SwiftUI

struct CategoryView: View {
    @ObservedObject var topicViewModel: TopicViewModel
    @ObservedObject var transcriptionViewModel: TranscriptionViewModel
    @EnvironmentObject var dataController: DataController
    
    @State private var categoriesScrollPosition: Int?
    @State private var showSettingsView: Bool = false
    @State private var animationStage: Int = 0
    @State private var showTutorialSheetView: Bool = false
    @State private var showNewCategory: Bool = false //Animation won't work if directly using UserDefaults. Best to trigger animation via a @State private var
    
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
    @CloudStorage("unlockNewCategory") var newCategory: Bool = false
    @CloudStorage("seenTutorialFirstCategory") var seenTutorialFirstCategory: Bool = false
    
    let categoryEmojiSize: CGFloat = 50
    
    var safeAreaPadding: CGFloat {
        return (UIScreen.main.bounds.width - categoryEmojiSize)/2
    }
    
    var body: some View {
       
        NavigationStack {
            VStack {
                // MARK: - Categories Scroll View
                ZStack {
                    CategoriesScrollView(categoriesScrollPosition: $categoriesScrollPosition, categories: categories)
                        .opacity((!newCategory) ? 0 : 1)
                    
                    if showNewCategory {
                        Text(categories[currentCategory].categoryEmoji)
                            .font(.system(size: (animationStage == 0) ? 100 : categoryEmojiSize))
                            .transition(.movingParts.blur)
                            .padding(.horizontal, (animationStage == 0) ? 0 : safeAreaPadding)
                    }
                }
                .frame(height: (!newCategory && animationStage == 0) ? 100 : categoryEmojiSize)
                
                // MARK: - Category description
                ///  scrollPosition < categories.count needed for when scroll is on the questionmark
                if let scrollPosition = categoriesScrollPosition, scrollPosition < categories.count {
                    CategoryDescriptionView(animationStage: $animationStage, showNewCategory: $showNewCategory, category: categories[scrollPosition])
                        .padding(.vertical, 25)
                        .padding(.horizontal, (!newCategory && animationStage == 0) ? 15: 30)
                }
                
                // MARK: - To do
//                CategoryMissionBox()
//                    .padding(.horizontal)
//                    .padding(.bottom, 25)
                
                if showTopics {
                    
                    if let scrollPosition = categoriesScrollPosition, let currentPoints = points.first, scrollPosition < categories.count {
                    // MARK: - Quest header
                    CategoryQuestsHeading()
                        .padding(.horizontal)
                        .padding(.bottom, 25)
                        .padding(.top, 20)
                    
                    // MARK: - Topics list
                    
                        TopicsListView(topicViewModel: topicViewModel, transcriptionViewModel: transcriptionViewModel, selectedTopic: $selectedTopic, currentTabBar: $currentTabBar, selectedTabTopic: $selectedTabTopic, navigateToTopicDetailView: $navigateToTopicDetailView, categoriesScrollPosition: $categoriesScrollPosition, category: categories[scrollPosition], points: currentPoints)
                            
                    }
                }
            } //VStack
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: (!newCategory && animationStage == 0) ? .center : .top)
            .padding(.top, (!newCategory && animationStage == 0) ? 0 : 30)
            .background {
                BackgroundPrimary(backgroundColor: getCategoryBackground())
            }
            .onAppear {
                setupView()
            }
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    SettingsToolbarItem(action: {
                        showSettingsView = true
                    })
                    .opacity(newCategory ? 1 : 0)
                }
                
                ToolbarItem(placement: .principal) {
                    ToolbarTitleItem(title: "Forgotten Realms")
                        .opacity(newCategory ? 1 : 0)
                }
                
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        //tbd
                    } label: {
                        LaurelItem(size: 15, points: "\(Int(points.first?.total ?? 0))")
                            .opacity(newCategory ? 1 : 0)
                    }
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
                TutorialFirstCategory(backgroundColor: getCategoryBackground())
                    .presentationDetents([.fraction(0.65)])
                    .presentationCornerRadius(30)
                    .interactiveDismissDisabled()
            }
            
        }
        .environment(\.colorScheme, .dark)
        .tint(AppColors.textPrimary)
    }
    
    private func setupView() {
        
        categoriesScrollPosition = currentCategory
        
        if !newCategory {
            startAnimation()
        }
        
    }
    
    private func startAnimation() {
        // Initial state
        animationStage = 0
        
        //show new category emoji and name
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            withAnimation {
                showNewCategory = true
            }
        }
        
        // First stage: Move to smaller layout
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            withAnimation(.smooth(duration: 0.25)) {
                animationStage = 1
            }
        }
        
        // Second stage: Fade in description
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
            withAnimation(.smooth(duration: 0.3)) {
                animationStage = 2
            }
           
        }
        
        // show date
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            withAnimation(.smooth(duration: 0.3)) {
                animationStage = 3
            }
        }
        
        // Show tutorial sheet
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.5) {
            newCategory = true
            showNewCategory = false
            if !seenTutorialFirstCategory {
                showTutorialSheetView = true
            } else if !showTopics {
                withAnimation(.easeIn) {
                    showTopics = true
                }
            }
        }
    }
    
    private func getCategoryBackground() -> Color {
        if let scrollPosition = categoriesScrollPosition, scrollPosition < categories.count {
            return Realm.getBackgroundColor(forName: categories[scrollPosition].categoryName)
        }
        
        return AppColors.backgroundOnboardingIntro
    }
}
