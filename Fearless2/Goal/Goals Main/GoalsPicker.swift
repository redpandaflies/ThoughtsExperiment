//
//  GoalsPicker.swift
//  Fearless2
//
//  Created by Yue Deng-Wu on 5/20/25.
//

import Foundation
import SwiftUI

enum GoalsPicker: Int, CaseIterable {

    case active
    case completed
    
    func pickerHeading() -> String {
        switch self {
        case .active:
            return "Active"
        case .completed:
            return "Resolved"
        }
    }
    
    @ViewBuilder
    func pickerView(
        topicViewModel: TopicViewModel,
        goalScrollPositionActive: Binding<Int?>,
        goalScrollPositionCompleted: Binding<Int?>,
        selectedSegment: Binding<GoalsPicker>,
        selectedTopic: Binding<Topic?>,
        currentTabBar: Binding<TabBarType>,
        selectedTabTopic: Binding<TopicPickerItem>,
        showNewGoalSheet: Binding<Bool>
    ) -> some View {
        switch self {
        case .active:
            GoalsViewActive(
                topicViewModel: topicViewModel,
                goalScrollPosition: goalScrollPositionActive,
                selectedTopic: selectedTopic,
                currentTabBar: currentTabBar,
                selectedTabTopic: selectedTabTopic,
                showNewGoalSheet: showNewGoalSheet
            )
        case .completed:
            GoalsViewCompleted(
                topicViewModel: topicViewModel,
                goalScrollPosition: goalScrollPositionCompleted,
                selectedSegment: selectedSegment,
                selectedTopic: selectedTopic,
                currentTabBar: currentTabBar,
                selectedTabTopic: selectedTabTopic,
                showNewGoalSheet: showNewGoalSheet
            )
        }
    }

}
