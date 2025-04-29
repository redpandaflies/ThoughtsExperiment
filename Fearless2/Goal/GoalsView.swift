//
//  GoalsView.swift
//  Fearless2
//
//  Created by Yue Deng-Wu on 4/22/25.
//
import CoreData
import SwiftUI

struct GoalsView: View {
    @EnvironmentObject var viewModelFactoryMain: ViewModelFactoryMain
    @EnvironmentObject var dataController: DataController
    @ObservedObject var topicViewModel: TopicViewModel
    
    @State private var showSettingsView: Bool = false
    @State private var goalScrollPosition: Int?
    @State private var showNewGoalSheet: Bool = false
    @State private var cancelledCreateNewCategory: Bool = false //prevents scroll if user exits create new category flow
    
    @Binding var selectedTopic: Topic?
    @Binding var currentTabBar: TabBarType
    @Binding var selectedTabTopic: TopicPickerItem
    
    @FetchRequest(
        sortDescriptors: [
            NSSortDescriptor(key: "orderIndex", ascending: true)
        ]
    ) var categories: FetchedResults<Category>
    
    @FetchRequest(
        sortDescriptors: [
            NSSortDescriptor(key: "createdAt", ascending: true)
        ]
    ) var goals: FetchedResults<Goal>
    
    @FetchRequest(
        sortDescriptors: []
    ) var points: FetchedResults<Points>
    
    var currentPoints: Int {
        return Int(points.first?.total ?? 0)
    }
    
    // avoid crashing app when goals is 0 or goalScrollPosition is out of bounds
    private var displayedGoal: Goal? {
        // if there are no goals, bail out
        guard !goals.isEmpty else { return nil }
        // if you have a valid scroll position, use it
        if let pos = goalScrollPosition, goals.indices.contains(pos) {
            return goals[pos]
        }
        // otherwise just show the first goal
        return goals.first
    }
    
    private var headerImageName: String {
        let index = goalScrollPosition ?? 0
        let imageIndex = (index % 3) + 1
        return "goal\(imageIndex)"
    }
    
    let screenWidth = UIScreen.current.bounds.width
    
    var frameWidth: CGFloat {
        return screenWidth * 0.85
    }
    
    var safeAreaPadding: CGFloat {
        return (screenWidth - frameWidth)/2
    }
    
    var body: some View {
        NavigationStack {
            
            
            VStack (spacing: 15){
                if !goals.isEmpty {
          
                    Image(headerImageName)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(height: 160)
                        .blendMode(.screen)
                    
                    
                    ScrollView (.horizontal) {
                        HStack (spacing: 15) {
                            ForEach(Array(goals.enumerated()), id: \.element.goalId) { index, goal in
                                // MARK: - Quests map 
                                QuestMapView(
                                    topicViewModel: topicViewModel,
                                    selectedTopic: $selectedTopic,
                                    currentTabBar: $currentTabBar,
                                    selectedTabTopic: $selectedTabTopic,
                                    points: currentPoints,
                                    backgroundColor: getCategoryBackground(goal: goal),
                                    goal: goal,
                                    frameWidth: frameWidth
                                )
                                    .id(index)
                                    .scrollTransition { content, phase in
                                        content
                                        .opacity(phase.isIdentity ? 1 : 0.3)
                                    }
                                
                            }//ForEach
                        }//HStack
                        .scrollTargetLayout()
                    }//ScrollView
                    .scrollPosition(id: $goalScrollPosition, anchor: .center)
                    .scrollClipDisabled(true)
                    .scrollTargetBehavior(.viewAligned(limitBehavior: .alwaysByOne))
                    .scrollIndicators(.hidden)
                    .contentMargins(.horizontal, safeAreaPadding, for: .scrollContent)
                    
                    if goals.count > 1 {
                        PageIndicatorView(scrollPosition: $goalScrollPosition, pagesCount: goals.count)
                            .padding(.top)
                    }
                    
                }
                
            }//VStack
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            .ignoresSafeArea(.keyboard)
            .overlay {
                addGoalButton(buttonAction: {
                    showNewGoalSheet = true
                })
            }
            .onAppear {
                print("Number of goals: \(goals.count)")
            }
            .onChange(of: dataController.deletedAllData) {
                print("Number of goals: \(goals.count)")
//                if dataController.deletedAllData {
//                    selectedTopic = nil
//                    goalScrollPosition = nil
//                }
            }
            .background {
                BackgroundPrimary(backgroundColor: getCategoryBackground(goal: displayedGoal))
            }
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    SettingsToolbarItem(action: {
                        showSettingsView = true
                    })
                   
                }
                
            }
            .sheet(isPresented: $showSettingsView, onDismiss: {
                showSettingsView = false
            }, content: {
                SettingsView(backgroundColor: AppColors.backgroundOnboardingIntro)
                    .presentationCornerRadius(20)
                    .presentationBackground {
                        Color.clear
                            .background(.regularMaterial)
                            .environment(\.colorScheme, .dark )
                    }
            })
            .fullScreenCover(isPresented: $showNewGoalSheet, onDismiss: {
                showNewGoalSheet = false
            }) {
                NewCategoryView(
                    newCategoryViewModel: viewModelFactoryMain.makeNewCategoryViewModel(),
                    showNewGoalSheet: $showNewGoalSheet,
                    cancelledCreateNewCategory: $cancelledCreateNewCategory
                )
            }
        }
        .environment(\.colorScheme, .dark)
        .tint(AppColors.textPrimary)
        
       
    }
    
    private func getCategoryBackground(goal: Goal?) -> Color {
        
        if let category = goal?.category {
            
            return Realm.getBackgroundColor(forName: category.categoryName)
            
        } else {
            return AppColors.backgroundOnboardingIntro
        }

    }
    
    private func addGoalButton(buttonAction: @escaping () -> Void) -> some View {
        VStack {
            SquareButton(
                buttonImage: "plus",
                buttonAction: {
                    buttonAction()
                }
            )
            .padding(.horizontal, safeAreaPadding)
            .padding(.bottom, 20)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomTrailing)
    }
}
