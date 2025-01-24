//
//  TopicsGridView.swift
//  Fearless2
//
//  Created by Yue Deng-Wu on 1/22/25.
//

import SwiftUI

struct TopicsGridView: View {
    @ObservedObject var topicViewModel: TopicViewModel
    
    var topics: FetchedResults<Topic>
    var onTopicTap: (Topic) -> Void
    var showAddButton: Bool
    var onAddButtonTap: (() -> Void)? = nil
    
    let columns = [GridItem(.adaptive(minimum: 150), spacing: 15)]
    
    var body: some View {
        LazyVGrid(columns: columns, spacing: 15) {
            ForEach(topics, id: \.topicId) { topic in
                TopicBox(topicViewModel: topicViewModel, topic: topic)
                    .onTapGesture {
                        onTopicTap(topic)
                    }
            }
            
            if showAddButton, let onAddButtonTap = onAddButtonTap {
                AddTopicButton()
                    .onTapGesture {
                        onAddButtonTap()
                    }
            }
        }
    }
}


