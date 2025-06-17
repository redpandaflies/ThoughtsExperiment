//
//  PlanSuggestionsObservable.swift
//  Fearless2
//
//  Created by Yue Deng-Wu on 6/13/25.
//

import Foundation

protocol PlanSuggestionsObservable: ObservableObject {
    var createPlanSuggestions: LoadingStatePrimary { get set }
    var completedLoadingAnimationPlan: Bool { get set }
    var newPlanSuggestions: [NewPlan] { get }
    var currentCategory: Category? { get }
    var currentGoal: Goal? { get }
    
    // needed because property is observed via Combine
    var createPlanSuggestionsPublisher: Published<LoadingStatePrimary>.Publisher { get }
    var completedLoadingAnimationPlanPublisher: Published<Bool>.Publisher { get }
    
}
