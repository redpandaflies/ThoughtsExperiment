//
//  TopicReviewView.swift
//  Fearless2
//
//  Created by Yue Deng-Wu on 1/4/25.
//

import SwiftUI

struct TopicReviewView: View {
    @ObservedObject var topicViewModel: TopicViewModel
    
    let topicId: UUID
    let focusAreasCompleted: Int
    
    var body: some View {
       
        ScrollView {
            
            VStack (spacing: 30) {
                
                TopicOverviewBox(topicViewModel: topicViewModel, topicId: topicId, focusAreasCompleted: focusAreasCompleted)
                  
                
                InsightsListView(topicId: topicId)
            }

        }
        .scrollIndicators(.hidden)
        .scrollClipDisabled()
        .safeAreaInset(edge: .bottom, content: {
            Rectangle()
                .fill(Color.clear)
                .frame(height: 70)
        })
        
    }
}

