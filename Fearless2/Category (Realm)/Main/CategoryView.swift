////
////  CategoryView.swift
////  Fearless2
////
////  Created by Yue Deng-Wu on 2/7/25.
////
//import CoreData
//import Mixpanel
//import Pow
//import SwiftUI
//
//struct CategoryView: View {
//    @ObservedObject var topicViewModel: TopicViewModel
//    @EnvironmentObject var dataController: DataController
//    
//    @State private var categoriesScrollPosition: Int?
//    @State private var showSettingsView: Bool = false
//    @State private var animationStage: Int = 0
//    @State private var showFirstCategoryInfoSheet: Bool = false
//    @State private var showLaurelInfoSheet: Bool = false
//    @State private var showNewCategory: Bool = false //Animation won't work if directly using UserDefaults. Best to trigger animation via a @State private var
//
//    @State private var isProgrammaticScroll: Bool = false //prevent haptic feedback on programmatic scroll
//    
//    @Binding var selectedTopic: Topic?
//    @Binding var currentTabBar: TabBarType
//    @Binding var selectedTabTopic: TopicPickerItem
//    @Binding var navigateToTopicDetailView: Bool
//    
//    @FetchRequest(
//        sortDescriptors: [
//            NSSortDescriptor(key: "orderIndex", ascending: true)
//        ]
//    ) var categories: FetchedResults<Category>
//    
//    @FetchRequest(
//        sortDescriptors: []
//    ) var points: FetchedResults<Points>
//    
//    @FetchRequest(
//        sortDescriptors: []
//    ) var topics: FetchedResults<Topic>
//    
//    @AppStorage("currentAppView") var currentAppView: Int = 0
//    @AppStorage("currentCategory") var currentCategory: Int = 0
//    @AppStorage("showTopics") var showTopics: Bool = false
//    @AppStorage("unlockNewCategory") var newCategory: Bool = false
//    @AppStorage("discoveredFirstCategory") var discoveredFirstCategory: Bool = false
//    
//    let categoryEmojiSize: CGFloat = 100
//    
//    var safeAreaPadding: CGFloat {
//        return (UIScreen.main.bounds.width - categoryEmojiSize)/2
//    }
//    
//    var currentCategoryScrollPosition: Int {
//        if let scrollPostion = categoriesScrollPosition {
//            return Int(scrollPostion - 1) // subtracting 1 because 0 is mirror realm
//        }
//        
//        return 0
//    }
//    
//    var body: some View {
//       
//        NavigationStack {
//            VStack {
//                // MARK: - Categories Scroll View
//                ZStack {
//                    CategoriesScrollView(categoriesScrollPosition: $categoriesScrollPosition, isProgrammaticScroll: $isProgrammaticScroll, categories: categories, totalTopics: topics.count)
//                        .opacity((!newCategory) ? 0 : 1)
//                    
//                    if showNewCategory {
//                        Image(categories[currentCategory].categoryEmoji)
//                            .resizable()
//                            .aspectRatio(contentMode: .fit)
//                            .frame(width: categoryEmojiSize)
//                            .transition(
//                                .identity
//                                    .animation(.linear(duration: 1).delay(2))
//                                    .combined(
//                                        with: .movingParts.anvil
//                                    )
//                            )
//                            .padding(.horizontal, safeAreaPadding)
//                            .sensoryFeedback(.impact, trigger: showNewCategory) { oldValue, newValue in
//                                return oldValue != newValue && newValue == true
//                            }
//                    }
//                }
//                .frame(height: categoryEmojiSize)
//              
//                if let scrollPosition = categoriesScrollPosition, scrollPosition > 0 {
//                    // MARK: - Category description
//                    CategoryDescriptionView(animationStage: $animationStage, showNewCategory: $showNewCategory, category: categories[currentCategoryScrollPosition])
//                        .padding(.vertical, 25)
//                        .padding(.horizontal, 30)
//                    
//                    
//                    // MARK: - To do
//                    //                CategoryMissionBox()
//                    //                    .padding(.horizontal)
//                    //                    .padding(.bottom, 25)
//                    
////                    if showTopics {
////                        
////                        if let currentPoints = points.first, let goal = categories[currentCategoryScrollPosition].categoryGoals.first {
////                            
////                            // MARK: - Quests map
////                            QuestMapView(topicViewModel: topicViewModel, selectedTopic: $selectedTopic, currentTabBar: $currentTabBar, selectedTabTopic: $selectedTabTopic, navigateToTopicDetailView: $navigateToTopicDetailView, categoriesScrollPosition: $categoriesScrollPosition, category: categories[currentCategoryScrollPosition], points: currentPoints, totalCategories: categories.count, backgroundColor: getCategoryBackground(), goal: goal)
////                            
////                        }
////                    }
//                } else {
//                    MirrorMainView(categoriesScrollPosition: $categoriesScrollPosition, categories: categories)
//                    
//                }
//                
//            } //VStack
//            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
//            .padding(.top, 10)
//            .background {
//                BackgroundPrimary(backgroundColor: getCategoryBackground())
//            }
//            .onAppear {
//                setupView()
//                
//            }
//            .toolbar {
//                ToolbarItem(placement: .topBarLeading) {
//                    SettingsToolbarItem(action: {
//                        showSettingsView = true
//                    })
//                    .opacity(newCategory ? 1 : 0)
//                   
//                }
//                
////                ToolbarItem(placement: .principal) {
////                    ToolbarTitleItem(title: "Forgotten Realms")
////                        .opacity(newCategory ? 1 : 0)
////                }
//                
//                ToolbarItem(placement: .topBarTrailing) {
//                    Button {
//                        //tbd
//                        showLaurelInfoSheet = true
//                        
//                        DispatchQueue.global(qos: .background).async {
//                            Mixpanel.mainInstance().track(event: "Tapped laurel counter")
//                        }
//                        
//                    } label: {
//                        LaurelItem(size: 15, points: "\(Int(points.first?.total ?? 0))")
//                            .opacity(newCategory ? 1 : 0)
//                    }
//                }
//                
//            }
//            .navigationBarTitleDisplayMode(.inline)
//            .sheet(isPresented: $showSettingsView, onDismiss: {
//                showSettingsView = false
//            }, content: {
//                SettingsView(backgroundColor: getCategoryBackground())
//                    .presentationCornerRadius(20)
//                    .presentationBackground {
//                        Color.clear
//                            .background(.regularMaterial)
//                            .environment(\.colorScheme, .dark )
//                    }
//            })
//            .sheet(isPresented: $showFirstCategoryInfoSheet, onDismiss: {
//                showFirstCategoryInfoSheet = false
//            }) {
//                InfoFirstCategory(backgroundColor: getCategoryBackground())
//                    .presentationDetents([.fraction(0.65)])
//                    .presentationCornerRadius(30)
//                    .interactiveDismissDisabled()
//            }
//            .sheet(isPresented: $showLaurelInfoSheet, onDismiss: {
//                showLaurelInfoSheet = false
//            }) {
//                
//                InfoPrimaryView(
//                    backgroundColor: getCategoryBackground(),
//                    useIcon: false,
//                    titleText: "You earn laurels by exploring paths and completing quests.",
//                    descriptionText: "You’ll be able to use them to unlock new abilities.",
//                    useRectangleButton: false,
//                    buttonAction: {}
//                )
//                .presentationDetents([.fraction(0.65)])
//                .presentationCornerRadius(30)
//            }
//            
//        }
//        .environment(\.colorScheme, .dark)
//        .tint(AppColors.textPrimary)
//    }
//    
//    private func setupView() {
//        isProgrammaticScroll = true
//        categoriesScrollPosition = currentCategory
//        
//        //needed in case user deletes and reinstalls app, and appstorage vars reset
//        
//        /// new user shouldn't have any topics that are active yet, because they haven't picked their first topic
////        let createdTopics = topics.filter { $0.status == TopicStatusItem.active.rawValue }.count
//        
//        if discoveredFirstCategory {
//            //restore app to its state before deletion
//            setupViewForExistingUser()
//        } else if !newCategory {
//            //new realm discovered
//            startAnimation()
//        }
//    }
//    
//    private func startAnimation() {
//        // Initial state
//        animationStage = 0
//        
//        //show new category emoji and name
//        DispatchQueue.main.asyncAfter(deadline: .now() + 0.75) {
//            withAnimation {
//                showNewCategory = true
//            }
//        }
//        
//        // Fade in description
//        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
//            withAnimation(.smooth(duration: 0.3)) {
//                animationStage = 2
//            }
//           
//        }
//        
//        // show date
//        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
//            withAnimation(.smooth(duration: 0.3)) {
//                animationStage = 2
//            }
//        }
//        
//        // Show tutorial sheet
//        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
//            newCategory = true
//            showNewCategory = false
//            if !discoveredFirstCategory {
//                showFirstCategoryInfoSheet = true
//            } else if !showTopics {
//                withAnimation(.easeIn) {
//                    showTopics = true
//                }
//            }
//        }
//    }
//    
//    //needed in case user deletes and reinstalls app, and appstorage vars reset
//    private func setupViewForExistingUser() {
//        // Initial state
//        newCategory = true
//        animationStage = 0
//        
//        // Fade in description & show date discovered
//        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
//            withAnimation(.smooth(duration: 0.3)) {
//                animationStage = 2
//            }
//           
//        }
//        
//        // show date
//        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
//            if !discoveredFirstCategory {
//                showFirstCategoryInfoSheet = true
//            } else if !showTopics {
//                withAnimation(.easeIn) {
//                    showTopics = true
//                }
//            }
//        }
//        
//    }
//    
//    private func getCategoryBackground() -> Color {
//        guard let scrollPosition = categoriesScrollPosition else {
//            return AppColors.backgroundOnboardingIntro
//        }
//        
//        if scrollPosition > 0 {
//            
//            return Realm.getBackgroundColor(forName: categories[currentCategoryScrollPosition].categoryName)
//            
//        } else {
//            return AppColors.backgroundOnboardingIntro
//        }
//
//    }
//    
//}
