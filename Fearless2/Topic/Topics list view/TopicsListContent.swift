////
////  TopicsListContent.swift
////  Fearless2
////
////  Created by Yue Deng-Wu on 1/22/25.
////
//
//import SwiftUI
//
//struct TopicsListContent: View {
//    @ObservedObject var topicViewModel: TopicViewModel
//    @State private var playHapticEffect: Int = 0
//    
//    let topics: FetchedResults<Topic>
//    var onTopicTap: (Int, Topic) -> Void
//    var showAddButton: Bool
//    var onAddButtonTap: (() -> Void)? = nil
//    let frameWidth: CGFloat
//    var totalTopics: Int {
//        return topics.count
//    }
//    
//    var body: some View {
//        HStack (alignment: .center, spacing: 20) {
//            ForEach(Array(topics.enumerated()), id: \.element.topicId) { index, topic in
//                
//                TopicBox(topicViewModel: topicViewModel, topic: topic, buttonAction: {
//                    onTopicTap(index, topic)
//                })
//                .frame(width: frameWidth, height: 300)
//                .scrollTransition { content, phase in
//                    content
//                        .opacity(phase.isIdentity ? 1 : 0.5)
//                        .scaleEffect(y: phase.isIdentity ? 1 : 0.90)
//                }
//                .id(index)
//                .onTapGesture {
//                    playHapticEffect += 1
//                    print("Haptic effect \(playHapticEffect)")
//                    onTopicTap(index, topic)
//                }
//                .sensoryFeedback(.selection, trigger: playHapticEffect)
//            }
//            
//            if showAddButton, let onAddButtonTap = onAddButtonTap {
//                AddTopicButton(frameWidth: frameWidth,
//                               noTopics: topics.count == 0,
//                               buttonAction: {
//                                    onAddButtonTap()
//                                })
//                    .scrollTransition { content, phase in
//                        content
//                            .opacity(phase.isIdentity ? 1 : 0.5)
//                            .scaleEffect(y: phase.isIdentity ? 1 : 0.85)
//                    }
//                    .id(totalTopics)
//                    .onTapGesture {
//                        playHapticEffect += 1
//                        print("Haptic effect \(playHapticEffect)")
//                        onAddButtonTap()
//                    }
//                    .sensoryFeedback(.selection, trigger: playHapticEffect)
//                    
//            }
//        }//HStack
//        .onAppear {
//            if playHapticEffect != 0 {
//                playHapticEffect = 0
//            }
//        }
//    }
//}
//
//
//
