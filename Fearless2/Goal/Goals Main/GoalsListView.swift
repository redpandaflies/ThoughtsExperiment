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
    let frameWidth: CGFloat
    let safeAreaPadding: CGFloat
    
    var body: some View {
        
        VStack (spacing: 0) {
            if !goals.isEmpty {
                
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
                    .padding(.top, 20)
                }
                
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
