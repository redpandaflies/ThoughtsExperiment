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
                        HStack (spacing: 32) {
                            ForEach(Array(goals.enumerated()), id: \.element.goalId) { index, goal in
                                // MARK: - Quests map
                                if let category = goal.category {
                                    if !goal.goalSequences.isEmpty {
                                        QuestMapView(
                                            topicViewModel: topicViewModel,
                                            selectedTopic: $selectedTopic,
                                            currentTabBar: $currentTabBar,
                                            selectedTabTopic: $selectedTabTopic,
                                            category: category,
                                            points: currentPoints,
                                            backgroundColor: getCategoryBackground(goal: goal),
                                            goal: goal)
                                        .id(index)
                                    }
                                }
                            }//ForEach
                        }//HStack
                        .scrollTargetLayout()
                    }//ScrollView
                    .scrollPosition(id: $goalScrollPosition, anchor: .center)
                    .contentMargins(.horizontal, 16, for: .scrollContent)
                    .scrollClipDisabled(true)
                    .scrollTargetBehavior(.viewAligned)
                    .scrollIndicators(.hidden)
                    
                    if goals.count > 1 {
                        PageIndicatorView(scrollPosition: $goalScrollPosition, pagesCount: goals.count)
                        
                    }
                    
                }
                
            }//VStack
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            .overlay {
                addGoalButton(buttonAction: {
                    showNewGoalSheet = true
                })
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
                    cancelledCreateNewCategory: $cancelledCreateNewCategory,
                    categories: categories
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
            RoundButton(
                buttonImage: "plus",
                size: 23,
                frameSize: 60,
                buttonAction: {
                    buttonAction()
                }
            )
            .padding(.horizontal)
            .padding(.bottom, 20)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomTrailing)
    }
}
