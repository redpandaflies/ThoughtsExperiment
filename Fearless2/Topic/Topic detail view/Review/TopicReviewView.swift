//
//  TopicReviewView.swift
//  Fearless2
//
//  Created by Yue Deng-Wu on 1/4/25.
//

import SwiftUI

struct TopicReviewView: View {
    let topicId: UUID
    
    var body: some View {
       
        ScrollView {
           
                
            InsightsListView(topicId: topicId)
                
           
            
        }
        .scrollIndicators(.hidden)
        .scrollClipDisabled()
        .safeAreaInset(edge: .bottom, content: {
            Rectangle()
                .fill(Color.clear)
                .frame(height: 50)
        })
        
    }
}

