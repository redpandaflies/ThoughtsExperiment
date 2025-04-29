//
//  RecapReflectionView.swift
//  Fearless2
//
//  Created by Yue Deng-Wu on 4/4/25.
//

import SwiftUI

struct RecapReflectionView: View {
    @ObservedObject var topicViewModel: TopicViewModel
    @State private var animationValue: Bool = false
    @State private var animator: TextAnimator?
    @State private var startedAnimation: Bool = false
    @State private var recapSelectedTab: Int = 0 //manage the UI changes when recap is ready
    @Binding var animatedText: String
    
    let feedback: String
    let retryAction: () -> Void
    let focusArea: FocusArea?
    let topic: Topic?
    
    init(topicViewModel: TopicViewModel, animatedText: Binding<String>, feedback: String, retryAction: @escaping () -> Void, focusArea: FocusArea? = nil, topic: Topic? = nil) {
            self.topicViewModel = topicViewModel
            self._animatedText = animatedText
            self.feedback = feedback
            self.retryAction = retryAction
            self.focusArea = focusArea
            self.topic = topic
    }
    
    var body: some View {
        
        VStack (alignment: .leading) {
            switch recapSelectedTab {
                case 0:
                    LoadingAnimationEllipsis(animationValue: $animationValue)
                    .padding(.top, 5)
                
                case 1:
                    recapText()
                
                default:
                    FocusAreaRetryView(action: {
                        retryAction()
                    })
            }
            
        }//VStack
        .onAppear {
//            if animator == nil {
//                animator = TextAnimator(text: feedback, animatedText: $animatedText, speed: 0.04)
//            }
            
            if let topic = topic {
                manageTopicRecapView(topic: topic)
            }
            
        }
        .onChange(of: recapSelectedTab) {
//            if recapStatus == 1 && !startedAnimation {
//                print("recap ready, starting typewriter animation")
//                if animator == nil {
//                    animator = TextAnimator(text: feedback, animatedText: $animatedText, speed: 0.02)
//                } else {
//                    animator?.updateText(feedback)
//                }
//                animator?.animate()
//            }
            if recapSelectedTab == 1 {
                if let topic = topic {
                    manageTopicRecapView(topic: topic)
                }
            }
        }
//        .onChange(of: topicViewModel.createFocusAreaSummary) {
//            
//            switch topicViewModel.createFocusAreaSummary {
//                case .ready:
//                    animationValue = false
//                    withAnimation (.snappy(duration: 0.2)) {
//                        recapStatus = 1
//                    }
//                case .retry:
//                    withAnimation (.snappy(duration: 0.2)) {
//                        recapStatus = 2
//                    }
//                default:
//                withAnimation (.snappy(duration: 0.2)) {
//                    recapStatus = 0
//                }
//            }
//        }
        .onChange(of: topicViewModel.createTopicOverview) {
            
            switch topicViewModel.createTopicOverview {
                case .ready:
                    animationValue = false
                    withAnimation (.snappy(duration: 0.2)) {
                        recapSelectedTab = 1
                    }
                case .retry:
                    withAnimation (.snappy(duration: 0.2)) {
                        recapSelectedTab = 2
                    }
                default:
                withAnimation (.snappy(duration: 0.2)) {
                    recapSelectedTab = 0
                }
            }
        }
    }
    
    private func recapText() -> some View {
        Text(animatedText)
            .multilineTextAlignment(.leading)
            .font(.system(size: 19, design: .serif))
            .foregroundStyle(AppColors.textPrimary.opacity(0.9))
            .lineSpacing(1.5)
        
    }

//    private func manageFocusAreaRecapView(focusArea: FocusArea) {
//        switch  topicViewModel.createFocusAreaSummary  {
//            case .ready:
//                if focusArea.focusAreaStatus == FocusAreaStatusItem.completed.rawValue {
//                    animatedText = feedback //no animation if use has already seen the feedback once
//                    startedAnimation = true //prevent triggering animation when recapReady is set to true
//                    recapStatus = 1
//                } else {
//                    startedAnimation = true
//                    recapStatus = 1
//                    animator?.animate()
//                }
//            case .loading:
//                recapStatus = 0
//            case .retry:
//                recapStatus = 2
//        }
//    }
    
    private func manageTopicRecapView(topic: Topic) {
        switch  topicViewModel.createTopicOverview  {
            case .ready:
//                if topic.topicStatus == TopicStatusItem.completed.rawValue {
                    animatedText = feedback //no animation if use has already seen the feedback once
                    startedAnimation = true //prevent triggering animation when recapReady is set to true
                    recapSelectedTab = 1
//                } else {
//                    startedAnimation = true
//                    recapStatus = 1
//                    animator?.animate()
//                }
            case .loading:
                recapSelectedTab = 0
            case .retry:
                recapSelectedTab = 2
        }
    }

}

