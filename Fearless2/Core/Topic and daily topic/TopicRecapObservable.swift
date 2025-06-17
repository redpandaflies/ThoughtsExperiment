//
//  TopicRecapObservable.swift
//  Fearless2
//
//  Created by Yue Deng-Wu on 6/6/25.
//

import Foundation

protocol TopicRecapObservable: ObservableObject {
    var createTopicRecap: LoadingStatePrimary { get }
    var completedLoadingAnimationSummary: Bool { get }
    
    // needed because property is observed via Combine
    var createTopicRecapPublisher: Published<LoadingStatePrimary>.Publisher { get }
    var completedLoadingAnimationSummaryPublisher: Published<Bool>.Publisher { get }
    
    func markCompleteLoadingAnimationSummary()
}

enum LoadingStatePrimary {
    case ready
    case loading
    case retry
}
