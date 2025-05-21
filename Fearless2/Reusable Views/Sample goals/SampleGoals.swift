//
//  SampleGoalsView.swift
//  Fearless2
//
//  Created by Yue Deng-Wu on 5/20/25.
//

import SwiftUI

struct AnimatedSampleTopicsView: View {
   

    @State private var currentChunk = 0
    @State private var showIndexInChunk = -1
    @State private var isAnimating = false
        
    let onTapAction: () -> Void
    
    let sampleTopics: [OnboardingSampleTopicsItem] = OnboardingSampleTopicsItem.sample

    private let screenWidth = UIScreen.current.bounds.width
    private let hStackSpacing: CGFloat = 12
    
    private var boxFrameWidth: CGFloat {
        return (screenWidth - (2 * hStackSpacing) - 60) / 3
    }

    var body: some View {
        HStack(spacing: hStackSpacing) {
            ForEach(Array(sampleTopics.enumerated()), id: \.element.id) { index, topic in
                let chunk = index / 3
                let positionInChunk = index % 3
                if chunk == currentChunk && positionInChunk <= showIndexInChunk {
                    SampleTopicBox(
                        heading: topic.heading,
                        title: topic.title,
                        boxFrameWidth: boxFrameWidth
                    )
                    .transition(.movingParts.blur)
                    .onTapGesture {
                        onTapAction()
                    }
                }
            }
        }
        .onAppear {
            isAnimating = true
            animateChunk(0)
        }
        .onDisappear {
            isAnimating = false
        }
    }

    private func animateChunk(_ chunk: Int) {
        guard isAnimating else { return }
        currentChunk = chunk
        showIndexInChunk = -1

        // reveal each of the 3 with a stagger
        for i in 0..<3 {
            let delay = Double(i) * 0.1
            DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                guard isAnimating else { return }
                withAnimation(.snappy(duration: 0.2)) {
                    showIndexInChunk = i
                }
            }
        }

        // timing for hold & hide
        let totalRevealTime = (Double(2) * 0.3) + 0.2
        let holdDuration: Double = 5.0
        let hideDelay: Double = 0.75

        DispatchQueue.main.asyncAfter(deadline: .now() + totalRevealTime + holdDuration) {
            guard isAnimating else { return }
            withAnimation(.easeInOut) {
                showIndexInChunk = -1
            }
            let next = (chunk + 1) % 3
            DispatchQueue.main.asyncAfter(deadline: .now() + hideDelay) {
                animateChunk(next)
            }
        }
    }
}
