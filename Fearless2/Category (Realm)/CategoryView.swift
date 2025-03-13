//
//  CategoryView.swift
//  Fearless2
//
//  Created by Yue Deng-Wu on 2/7/25.
//
import CloudStorage
import CoreData
import Mixpanel
import Pow
import SwiftUI

struct CategoryView: View {
    @ObservedObject var topicViewModel: TopicViewModel
    @ObservedObject var transcriptionViewModel: TranscriptionViewModel
    @EnvironmentObject var dataController: DataController
    
    @State private var categoriesScrollPosition: Int?
    @State private var showSettingsView: Bool = false
    @State private var animationStage: Int = 0
    @State private var showFirstCategoryInfoSheet: Bool = false
    @State private var showLaurelInfoSheet: Bool = false
    @State private var showNewCategory: Bool = false //Animation won't work if directly using UserDefaults. Best to trigger animation via a @State private var

    @State private var isProgrammaticScroll: Bool = false //prevent haptic feedback on programmatic scroll
    
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
    
    @FetchRequest(
        sortDescriptors: []
    ) var topics: FetchedResults<Topic>
    
    @CloudStorage("currentAppView") var currentAppView: Int = 0
    @AppStorage("currentCategory") var currentCategory: Int = 0
    @AppStorage("showTopics") var showTopics: Bool = false
    @CloudStorage("unlockNewCategory") var newCategory: Bool = false
    @CloudStorage("discoveredFirstCategory") var discoveredFirstCategory: Bool = false
    
    let categoryEmojiSize: CGFloat = 50
    
    var safeAreaPadding: CGFloat {
        return (UIScreen.main.bounds.width - categoryEmojiSize)/2
    }
    
    var showUndiscovered: Bool {
        let checker = NewCategoryEligibilityChecker()
        return checker.checkEligibility(topics: topics, totalCategories: categories.count)
    }
    
    var body: some View {
       
        NavigationStack {
            VStack {
                // MARK: - Categories Scroll View
                ZStack {
                    CategoriesScrollView(categoriesScrollPosition: $categoriesScrollPosition, isProgrammaticScroll: $isProgrammaticScroll, categories: categories, showUndiscovered: showUndiscovered)
                        .opacity((!newCategory) ? 0 : 1)
                    
                    if showNewCategory {
                        Text(categories[currentCategory].categoryEmoji)
                            .font(.system(size: categoryEmojiSize))
                            .transition(
                                .identity
                                    .animation(.linear(duration: 1).delay(2))
                                    .combined(
                                        with: .movingParts.anvil
                                    )
                            )
                            .padding(.horizontal, safeAreaPadding)
                            .sensoryFeedback(.impact, trigger: showNewCategory) { oldValue, newValue in
                                return oldValue != newValue && newValue == true
                            }
                    }
                }
                .frame(height: categoryEmojiSize)
                
                
                if let scrollPosition = categoriesScrollPosition, scrollPosition < categories.count {
                    
                    // MARK: - Category description
                    ///  scrollPosition < categories.count needed for when scroll is on the questionmark
                    CategoryDescriptionView(animationStage: $animationStage, showNewCategory: $showNewCategory, category: categories[scrollPosition])
                        .padding(.vertical, 25)
                        .padding(.horizontal, 30)
    
                    
                    // MARK: - To do
                    //                CategoryMissionBox()
                    //                    .padding(.horizontal)
                    //                    .padding(.bottom, 25)
                    
                    if showTopics {
                        
                        if let currentPoints = points.first {
                            // MARK: - Quest header
                            CategoryQuestsHeading()
                                .padding(.horizontal)
                                .padding(.bottom, 25)
                                .padding(.top, 20)
                            
                            // MARK: - Topics list
                            
                            TopicsListView(topicViewModel: topicViewModel, transcriptionViewModel: transcriptionViewModel, selectedTopic: $selectedTopic, currentTabBar: $currentTabBar, selectedTabTopic: $selectedTabTopic, navigateToTopicDetailView: $navigateToTopicDetailView, categoriesScrollPosition: $categoriesScrollPosition, category: categories[scrollPosition], points: currentPoints, totalCategories: categories.count)
                            
                        }
                    }
                } else {
                    CategoryUndiscoveredView()
                }
                
                
            } //VStack
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            .padding(.top, 30)
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
                   
                }
                
                ToolbarItem(placement: .principal) {
                    ToolbarTitleItem(title: "Forgotten Realms")
                        .opacity(newCategory ? 1 : 0)
                }
                
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        //tbd
                        showLaurelInfoSheet = true
                        
                        DispatchQueue.global(qos: .background).async {
                            Mixpanel.mainInstance().track(event: "Tapped laurel counter")
                        }
                        
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
            .sheet(isPresented: $showFirstCategoryInfoSheet, onDismiss: {
                showFirstCategoryInfoSheet = false
            }) {
                InfoFirstCategory(backgroundColor: getCategoryBackground())
                    .presentationDetents([.fraction(0.65)])
                    .presentationCornerRadius(30)
                    .interactiveDismissDisabled()
            }
            .sheet(isPresented: $showLaurelInfoSheet, onDismiss: {
                showLaurelInfoSheet = false
            }) {
                
                InfoPrimaryView(
                    backgroundColor: getCategoryBackground(),
                    useIcon: false,
                    titleText: "You earn laurels by exploring paths and completing quests.",
                    descriptionText: "You’ll be able to use them to unlock new abilities.",
                    useRectangleButton: false,
                    buttonAction: {}
                )
                    .presentationDetents([.fraction(0.65)])
                    .presentationCornerRadius(30)
            }
            
        }
        .environment(\.colorScheme, .dark)
        .tint(AppColors.textPrimary)
    }
    
    private func setupView() {
        isProgrammaticScroll = true
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
        
        // Fade in description
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            withAnimation(.smooth(duration: 0.3)) {
                animationStage = 1
            }
           
        }
        
        // show date
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            withAnimation(.smooth(duration: 0.3)) {
                animationStage = 2
            }
        }
        
        // Show tutorial sheet
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            newCategory = true
            showNewCategory = false
            if !discoveredFirstCategory {
                showFirstCategoryInfoSheet = true
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
