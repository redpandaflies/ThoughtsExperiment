//
//  TopicRepresentable.swift
//  Fearless2
//
//  Created by Yue Deng-Wu on 6/4/25.
//

import Foundation

protocol TopicRepresentable: AnyObject {
    var topicId: UUID { get set }
    var topicCreatedAt: String { get set }
    var topicStatus: String { get set }
    var topicEmoji: String { get set }
    var topicTitle: String { get set }
    var review: TopicReview? { get set }
    var topicFeedback: [TopicFeedback] { get }
    var topicQuestions: [Question] { get }

    func addToQuestions(_ value: Question)
    func addToExpectations(_ value: TopicExpectation)
    func assignReview(_ review: TopicReview)
    func addToFeedback( _ value: TopicFeedback)
}
