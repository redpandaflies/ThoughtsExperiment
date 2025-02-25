//
//  TopicsListContent.swift
//  Fearless2
//
//  Created by Yue Deng-Wu on 1/22/25.
//

import SwiftUI

struct TopicsListContent: View {
    @ObservedObject var topicViewModel: TopicViewModel
    
    let topics: FetchedResults<Topic>
    var onTopicTap: (Int, Topic) -> Void
    var showAddButton: Bool
    var onAddButtonTap: (() -> Void)? = nil
    let frameWidth: CGFloat
    var totalTopics: Int {
        return topics.count
    }
    
    var body: some View {
        HStack (alignment: .center, spacing: 20) {
            ForEach(Array(topics.enumerated()), id: \.element.topicId) { index, topic in
                TopicBox(topicViewModel: topicViewModel, topic: topic, buttonAction: {
                    onTopicTap(index, topic)
                })
                    .frame(width: frameWidth, height: 300)
                    .scrollTransition { content, phase in
                        content
                            .opacity(phase.isIdentity ? 1 : 0.5)
                            .scaleEffect(y: phase.isIdentity ? 1 : 0.90)
                    }
                    .id(index)
                    .onTapGesture {
                        onTopicTap(index, topic)
                    }
            }
            
            if showAddButton, let onAddButtonTap = onAddButtonTap {
                AddTopicButton(frameWidth: frameWidth,
                               noTopics: topics.count == 0,
                               buttonAction: {
                                    onAddButtonTap()
                                })
                    .scrollTransition { content, phase in
                        content
                            .opacity(phase.isIdentity ? 1 : 0.5)
                            .scaleEffect(y: phase.isIdentity ? 1 : 0.85)
                    }
                    .id(totalTopics)
                    .onTapGesture {
                        onAddButtonTap()
                    }
            }
        }
    }
}



