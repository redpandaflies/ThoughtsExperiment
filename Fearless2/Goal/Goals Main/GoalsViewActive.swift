//
//  GoalsViewActive.swift
//  Fearless2
//
//  Created by Yue Deng-Wu on 5/20/25.
//
import CoreData
import Mixpanel
import Pow
import SwiftUI

struct GoalsViewActive: View {
    @EnvironmentObject var dataController: DataController
    @ObservedObject var topicViewModel: TopicViewModel
    
    @State private var selectedTabGoals: Int = 0
    @State private var animatedGoalIDs: Set<UUID> = []
    
    @Binding var goalScrollPosition: Int?
    @Binding var selectedTopic: Topic?
    @Binding var currentTabBar: TabBarType
    @Binding var selectedTabTopic: TopicPickerItem
    @Binding var showNewGoalSheet: Bool
    
    @FetchRequest(
        sortDescriptors: [
            NSSortDescriptor(key: "createdAt", ascending: true)
        ],
        predicate: NSPredicate(format: "status == %@", GoalStatusItem.active.rawValue)
    ) var goals: FetchedResults<Goal>
    
    let screenWidth = UIScreen.current.bounds.width
    
    var frameWidth: CGFloat {
        return screenWidth * 0.85
    }
    
    var safeAreaPadding: CGFloat {
        return (screenWidth - frameWidth)/2
    }
    
    var body: some View {
        
        VStack (spacing: 15){
            
            switch selectedTabGoals {
                case 0:
                    GoalsListView(
                        topicViewModel: topicViewModel,
                        goalScrollPosition: $goalScrollPosition,
                        selectedTopic: $selectedTopic,
                        currentTabBar: $currentTabBar,
                        selectedTabTopic: $selectedTabTopic,
                        animatedGoalIDs: $animatedGoalIDs,
                        goals: goals,
                        frameWidth: frameWidth,
                        safeAreaPadding: safeAreaPadding
                    )
                    
                default:
                    GoalsEmptyState(
                        showNewGoalSheet: $showNewGoalSheet
                    )
            }
            
            
        }//VStack
        .padding(.top, -40)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .ignoresSafeArea(.keyboard)
        .background {
            BackgroundPrimary(backgroundColor: getBackground(index: goalScrollPosition))
            
        }
        .onAppear {
            
            print("Number of goals: \(goals.count)")
            
            if animatedGoalIDs.isEmpty {
                animatedGoalIDs = Set(goals.map(\.goalId))
            }
            
            if goals.count == 0 {
                selectedTabGoals = 1
            }
            
            if dataController.createdNewGoal && goals.count > 1 {
                scrollToNewGoal(delay: 0.5)
            }
        }
        .onChange(of:  goals.map(\.goalId)) { oldValue, newValue in
            
            if oldValue.count < newValue.count {
                updateGoalsList(newValue: newValue)
            }
            
        }
        .onChange(of: animatedGoalIDs) { oldValue, newValue in
            
            //                print("Old value: \(oldValue), new value: \(newValue)")
            // update scroll view only if a goal has been abandoned or completed
            if oldValue.count > newValue.count {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    if let scrollPosition = goalScrollPosition {
                        withAnimation {
                            goalScrollPosition = scrollPosition == 0 ? nil : max(scrollPosition - 1, 0)
                        }
                    }
                }
            }
            
            if animatedGoalIDs.isEmpty {
                selectedTabGoals = 1
            }
        }
        .onChange(of: showNewGoalSheet) {
            if !showNewGoalSheet && dataController.createdNewGoal && goals.count > 1 {
                scrollToNewGoal(delay: 1.0)
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
    
    private func updateGoalsList(newValue: [UUID]) {
        let newSet = Set(newValue)
        let added = newSet.subtracting(animatedGoalIDs)  // IDs to bring in
        
        // Animate removals
        //        withAnimation {
        //            animatedGoalIDs.subtract(removed)
        //        }
        
        // Immediately add any new ones
        animatedGoalIDs.formUnion(added)
        if selectedTabGoals != 0 {
            selectedTabGoals = 0
        }
    }
    
    private func scrollToNewGoal(delay: Double) {
        DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
            withAnimation {
                goalScrollPosition = goals.count - 1
            }
        }
    }
}

