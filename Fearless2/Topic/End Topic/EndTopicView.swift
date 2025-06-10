////
////  EndTopicView.swift
////  Fearless2
////
////  Created by Yue Deng-Wu on 2/18/25.
////
//import Mixpanel
//import Pow
//import SwiftUI
//
//struct EndTopicView: View {
//    @Environment(\.dismiss) var dismiss
//    @EnvironmentObject var dataController: DataController
//    @ObservedObject var topicViewModel: TopicViewModel
//    @State private var selectedTab: Int = 0
//    @State private var showFragment: Bool = false
//    @State private var startRepeatingAnimation: Bool = false
//    @State private var celebrationAnimationStage: Int = 0
//    @Binding var section: Section?
//    @ObservedObject var topic: Topic
//    
//    let loadingTexts: [String] = [
//        "Going through your answers",
//        "Understanding your situation",
//        "Summarizing what you’ve told me"
//    ]
//    
//    var body: some View {
//        NavigationStack {
//            ZStack {
//                VStack (alignment: (selectedTab == 1) ? .leading : .center, spacing: 5) {
//                    switch selectedTab {
//                        case 0:
//                            RecapCelebrationView(animationStage: $celebrationAnimationStage, title: section?.topic?.topicTitle ?? "", text: "For completing", points: "+5")
//                                .padding(.horizontal)
//                                .padding(.top, 80)
//                            
//                        case 1:
//                            recapView()
//                            
//                        default:
//                            fragmentView()
//                                .padding(.bottom, 100)
//                    }
//                }
//                
//                VStack {
//                    
//                    Spacer()
//                    
//                    RectangleButtonPrimary(
//                        buttonText: getButtonText(),
//                        action: {
//                            buttonAction()
//                        },
//                        disableMainButton: disableButton(),
//                        buttonColor: .white
//                    )
//                    .padding(.bottom, 10)
//                    .padding(.horizontal)
//                }
//                
//            }//VStack
//            .background {
//                if let category = topic.category {
//                    BackgroundPrimary(backgroundColor: Realm.getBackgroundColor(forName: category.categoryName))
//                } else {
//                    BackgroundPrimary(backgroundColor: AppColors.backgroundCareer)
//                }
//            }
//            .onAppear {
//                getTopicReview()
//            }
//            .toolbar {
//               
//                ToolbarItem(placement: .principal) {
//                    ToolbarTitleItem2(emoji: topic.category?.categoryEmoji ?? "", title: "Quest complete")
//                }
//                
//                ToolbarItem(placement: .navigationBarTrailing) {
//                    XmarkToolbarItem(action: {
//                        dismiss()
//                    })
//                }
//                
//            }
//            .navigationBarTitleDisplayMode(.inline)
//            .toolbarBackgroundVisibility(.hidden)
//            
//        }//NavigationStack
//    }
//    
//    
//    private func getButtonText() -> String {
//        switch selectedTab {
//            case 0:
//                return "Next: quest reflection"
//            case 1:
//               return getButtonTextRecapView()
//            default:
//                return getButtonTextFragmentView()
//        }
//    }
//    
//    private func getButtonTextRecapView() -> String {
//        switch topicViewModel.createTopicOverview {
//            case .ready:
//                return "Next: restore lost fragment"
//            case .loading:
//               return "Loading . . ."
//            case .retry:
//                return "Retry"
//        }
//    }
//    
//    private func getButtonTextFragmentView() -> String {
//        switch topicViewModel.createTopicOverview {
//        case .ready:
//            return "Done"
//        case .loading:
//           return "Restoring . . ."
//        case .retry:
//            return "Retry"
//        }
//    }
//    
//    
//    private func buttonAction() {
//        
//        switch selectedTab {
//        case 0:
//            selectedTab += 1
//            Task {
//                //add 5 points for completing topic
//                await dataController.updatePoints(newPoints: 5)
//            }
//        case 1:
//            selectedTab += 1
//        default:
//            completeFlow()
//        }
//    }
//    
//    private func completeFlow() {
//        if let currentSection = section {
//            Task {
//                //mark section as complete
//                await dataController.completeSection(section: currentSection)
//                
//                //mark topic as complete
//                await dataController.completeTopic(topic: topic, section: currentSection)
//                
//                //close view
//                await MainActor.run {
//                    dismiss()
//                }
//                
//                DispatchQueue.global(qos: .background).async {
//                    Mixpanel.mainInstance().track(event: "Completed quest")
//                }
//            }
//        }
//    }
//    
//    private func disableButton() -> Bool {
//        switch selectedTab {
//        case 0:
//            return false
//        default:
//            return topicViewModel.createTopicOverview != .ready
//        }
//    }
//    
//    @ViewBuilder private func recapView() -> some View {
//        ScrollView {
//            RecapReflectionView(
//                topicViewModel: topicViewModel,
//                feedback: topic.review?.reviewSummary ?? "",
//                retryAction: {
//                    getTopicReview()
//                },
//                topic: topic,
//                loadingText: loadingTexts
//            )
//            .padding(.top, 20)
//            .padding(.horizontal)
//        }
//        .scrollIndicators(.hidden)
//        .scrollDisabled(true)
//        .safeAreaInset(edge: .bottom, content: {
//            Rectangle()
//                .fill(Color.clear)
//                .frame(height: 120)
//        })
//        
//    }
//    
//    @ViewBuilder private func fragmentView() -> some View {
//        
//        VStack {
//                
//            switch topicViewModel.createTopicOverview {
//            case .ready:
//                if let review = topic.review?.reviewOverview {
//                    if showFragment {
//                        TopicRecapFragmentBox(fragmentText: review)
//                            .transition(.movingParts.flip)
//                            .conditionalEffect(
//                                  .repeat(
//                                    .glow(color: .white.opacity(0.25), radius: 80),
//                                    every: 3
//                                  ),
//                                  condition: startRepeatingAnimation
//                              )
//                    }
//                } else { //happens when user sees this view before API call has been made
//                    LoadingPlaceholderContent(contentType: .topicFragment)
//                }
//            case .loading:
//                LoadingPlaceholderContent(contentType: .topicFragment)
//            case .retry:
//                RetryButton(action: {
//                    getTopicReview()
//                })
//            }
//            
//        }
//        .frame(maxHeight: .infinity, alignment: .center)
//        .onAppear {
//            if let _ = topic.review?.reviewOverview, topicViewModel.createTopicOverview == .ready {
//                revealFragment()
//            }
//        }
//        .onChange(of: topicViewModel.createTopicOverview) { oldState, newState in
//            // Now properly detect transition from loading to ready
//            if oldState == .loading && newState == .ready {
//                // Reset animation state first
//                showFragment = false
//                
//                // Then trigger the animation sequence
//                revealFragment()
//            }
//        }
//        .onDisappear {
//            startRepeatingAnimation = false
//        }
//    }
//    
//    
//    
//    private func getTopicReview() {
//        
//        if let _ = topic.review?.reviewOverview {
//            selectedTab = 1
//        } else {
//            topicViewModel.createTopicOverview = .loading
//            Task {
//                //generate review
//                do {
//                    try await topicViewModel.manageRun(selectedAssistant: .topicOverview, topicId: topic.topicId)
//                } catch {
//                    topicViewModel.createTopicOverview = .retry
//                }
//                
//                DispatchQueue.global(qos: .background).async {
//                    Mixpanel.mainInstance().track(event: "Restored fragment")
//                }
//            }
//        }
//    }
//    
//    private func revealFragment() {
//            
//        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
//            withAnimation(.interpolatingSpring(mass: 1, stiffness: 10, damping: 10, initialVelocity: 10)) {
//                showFragment = true
//            }
//            
//            startRepeatingAnimation = true
//        }
//            
//    }
//}
//
//
