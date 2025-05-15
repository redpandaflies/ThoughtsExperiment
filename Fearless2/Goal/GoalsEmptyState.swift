//
//  GoalsEmptyState.swift
//  Fearless2
//
//  Created by Yue Deng-Wu on 5/7/25.
//
import Pow
import SwiftUI

struct GoalsEmptyState: View {
    // manage animation
    @State private var currentChunk = 0
    @State private var showIndexInChunk = -1
    @State private var isAnimating = false


    @Binding var showNewGoalSheet: Bool
    let sampleTopics: [OnboardingSampleTopicsItem] = OnboardingSampleTopicsItem.sample
    
    let screenWidth = UIScreen.current.bounds.width
    let hStackSpacing: CGFloat = 12
    var boxFrameWidth: CGFloat {
        return (screenWidth - (2 * hStackSpacing) - 60) / 3
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10)  {
            
            SpinnerDefault()
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.top, 70)
                .padding(.horizontal, 30)
            
            Text(OnboardingIntroContent.pages[1].title)
                .multilineTextAlignment(.leading)
                .font(.system(size: 25, design: .serif))
                .foregroundStyle(AppColors.textPrimary)
                .lineSpacing(1.4)
                .padding(.horizontal, 30)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.top, 40)

            
                HStack (spacing: hStackSpacing) {
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
                                showNewGoalSheet = true
                            }
                        }
                    }
                }
                .padding(.horizontal, 30)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.top)
            
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

        // 1) reveal each of the 3 with a stagger
        for i in 0..<3 {
            let revealDelay = Double(i) * 0.1
            DispatchQueue.main.asyncAfter(deadline: .now() + revealDelay) {
                guard isAnimating else { return }
                withAnimation(.snappy(duration: 0.2)) {
                    self.showIndexInChunk = i
                }
            }
        }

        // 2) after all three are revealed, hide them then schedule next chunk
          let totalRevealTime = Double(2) * 0.3 + 0.2    // last reveal starts at 0.6, takes 0.2
        let postRevealHold: Double = 5.0
          let hideAnimationDelay: Double = 0.75

          DispatchQueue.main.asyncAfter(deadline: .now() + totalRevealTime + postRevealHold) {
              guard isAnimating else { return }
              withAnimation(.easeInOut) {
                  showIndexInChunk = -1
              }

              // 3) pick next chunk with wrap-around
              let next = (chunk + 1) % 3

              // 4) give the hide animation a moment, then recurse
              DispatchQueue.main.asyncAfter(deadline: .now() + hideAnimationDelay) {
                  animateChunk(next)
              }
          }
    }
}

