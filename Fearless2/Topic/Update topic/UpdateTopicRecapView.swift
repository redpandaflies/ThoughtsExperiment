//
//  UpdateTopicRecapView.swift
//  Fearless2
//
//  Created by Yue Deng-Wu on 4/24/25.
//

import SwiftUI

struct UpdateTopicRecapView<ViewModel: TopicRecapObservable>: View {
    
    @ObservedObject var viewModel: ViewModel
    
    @Binding var recapSelectedTab: Int
    
    let topic: TopicRepresentable
    let retryAction: () -> Void
    
    let loadingTexts: [String] = [
        "Going through your answers",
        "Summarizing what you've said",
        "Writing down some thoughts"
    ]
    
    var body: some View {

        ScrollView {
            VStack (alignment: .leading) {
                
                RecapReflectionView(
                    viewModel: viewModel,
                    recapSelectedTab: $recapSelectedTab,
                    feedback: topic.review?.reviewSummary ?? "",
                    retryAction: {
                        retryAction()
                    },
                    topic: topic,
                    loadingText: loadingTexts
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

