//
//  GoalsListView.swift
//  Fearless2
//
//  Created by Yue Deng-Wu on 5/12/25.
//
import Pow
import SwiftUI

struct GoalsListView: View {
    
    @ObservedObject var topicViewModel: TopicViewModel
    
    @Binding var goalScrollPosition: Int?
    @Binding var selectedTopic: Topic?
    @Binding var currentTabBar: TabBarType
    @Binding var selectedTabTopic: TopicPickerItem
    @Binding var animatedGoalIDs: Set<UUID>
    
    let goals: FetchedResults<Goal>
    let currentPoints: Int
    let frameWidth: CGFloat
    let safeAreaPadding: CGFloat
    
    var headerImage: String {
        // 1. If there are no goals, fall back to your default
        guard !goals.isEmpty else {
            return "goalDecision"
        }

        // 2. Decide which index to use (0 if nil)
        let rawIndex = goalScrollPosition ?? 0

        // 3. Clamp to the valid indices of `goals`
        let safeIndex = goals.indices.contains(rawIndex)
            ? rawIndex : 0

        // 4. Pull the goal at the safe index
        let goal = goals[safeIndex]
        return GoalTypeItem.imageName(forLongName: goal.goalProblemType)
    }
    
    var body: some View {
        if !goals.isEmpty {
            
            
            Image(headerImage)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(height: 160)
                .blendMode(.screen)
            
            ScrollView (.horizontal) {
                HStack (spacing: 15) {
                    ForEach(Array(goals.enumerated()), id: \.element.goalId) { index, goal in
                        // MARK: - Quests map
                        /// if statement for 1) manage goal map animation; 2) ensure goal has plans/sequences
                        if animatedGoalIDs.contains(goal.goalId) && goal.goalSequences.count > 0 {
                            QuestMapView (
                                topicViewModel: topicViewModel,
                                selectedTopic: $selectedTopic,
                                currentTabBar: $currentTabBar,
                                selectedTabTopic: $selectedTabTopic,
                                animatedGoalIDs: $animatedGoalIDs,
                                goal: goal,
                                points: currentPoints,
                                backgroundColor: getBackground(index: index),
                                frameWidth: frameWidth
                            )
                            .transition(.movingParts.poof)
                            .id(index)
//                                        .scrollTransition { content, phase in
//                                            content
//                                                .opacity(phase.isIdentity ? 1 : 0.3)
//                                        }
                            
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
                PageIndicatorView (
                    scrollPosition: $goalScrollPosition,
                    pagesCount: getPagesCount()
                )
                .padding(.top)
            }
            
        }
    }
    
    private func getBackground(index: Int?) -> Color {
        if let index = index {
            let count = AppColors.allBackgrounds.count
            
            let usableIndex = ((index % count) + count) % count
            
            return AppColors.allBackgrounds[usableIndex]
            
        }
        
        return AppColors.allBackgrounds[0]
    }
    
    private func getPagesCount() -> Int {
        let incompleteGoals = goals.filter { $0.goalSequences.isEmpty }.count
        
        if incompleteGoals == 0 {
            return goals.count
        } else {
            return goals.count - incompleteGoals
        }
        
    }
    
   
}
