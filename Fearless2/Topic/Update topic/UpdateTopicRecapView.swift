//
//  UpdateTopicRecapView.swift
//  Fearless2
//
//  Created by Yue Deng-Wu on 4/24/25.
//

import SwiftUI

struct UpdateTopicRecapView: View {
    
    @ObservedObject var topicViewModel: TopicViewModel
    @State private var animatedText = ""
    
    let topic: Topic
    let retryAction: () -> Void
    
    var body: some View {

        ScrollView {
            VStack (alignment: .leading) {
                Text("Reflection")
                    .multilineTextAlignment(.leading)
                    .font(.system(size: 22, design: .serif))
                    .foregroundStyle(AppColors.textPrimary)
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.bottom)
                
                RecapReflectionView(
                    topicViewModel: topicViewModel,
                    animatedText: $animatedText,
                    feedback: topic.review?.reviewSummary ?? "",
                    retryAction: {
                        retryAction()
                    },
                    topic: topic
                )
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal)
        }
        .scrollIndicators(.hidden)
        .scrollDisabled(true)
        .safeAreaInset(edge: .bottom, content: {
            Rectangle()
                .fill(Color.clear)
                .frame(height: 120)
        })
    
    }
}

