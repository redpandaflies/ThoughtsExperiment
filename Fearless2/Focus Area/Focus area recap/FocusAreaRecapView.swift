////
////  FocusAreaRecapView.swift
////  Fearless2
////
////  Created by Yue Deng-Wu on 10/30/24.
////
//import CoreData
//import Mixpanel
//import OSLog
//import Pow
//import SwiftUI
//
//struct FocusAreaRecapView: View {
//    @Environment(\.dismiss) var dismiss
//    @EnvironmentObject var dataController: DataController
//    @ObservedObject var topicViewModel: TopicViewModel
//    @State private var selectedTab: Int = 1 // [0] celebration, [1] feedback/recap
//    @State private var selectedTabSuggestionsList: Int = 1 //manages whether suggestions, loading view or retry is shown on suggestions list
//    @State private var animatedText = ""
//    @State private var celebrationAnimationStage: Int = 0
//    
//    @Binding var focusArea: FocusArea?
//    @Binding var focusAreaScrollPosition: Int?
//    
//    let topic: Topic
//    
//    let loadingTexts: [String] = [
//        "Going through your answers",
//        "Understanding your situation",
//        "Summarizing what you’ve told me"
//    ]
//    
//    var focusAreaIndex: Int {
//        let focusAreaNumber = focusArea?.orderIndex ?? 1
//        return Int(focusAreaNumber)
//    }
//    
//    var focusAreasLimit: Int {
//        return Int(topic.focusAreasLimit)
//    }
//    
//    private let screenWidth = UIScreen.current.bounds.width
//    private let logger = Logger.uiEvents
//    
//    var body: some View {
//        NavigationStack {
//            
//            ZStack {
//                
//                ScrollView {
//                    VStack (alignment: (selectedTab == 0) ? .center : .leading, spacing: 5) {
//                        
//                        getTitle()
//                            .padding(.bottom, (selectedTab == 2) ? 15 : 10)
//                            .padding(.horizontal)
//                        
//                        getContent()
//                            .padding(.horizontal, (selectedTab == 2) ? 0 : 16)
//                        
//                    }
//                    .padding(.top, 30)
//                    
//                }
//                .scrollIndicators(.hidden)
//                .scrollDisabled(true)
//                .safeAreaInset(edge: .bottom, content: {
//                    Rectangle()
//                        .fill(Color.clear)
//                        .frame(height: 120)
//                })
//                
//                
//                VStack {
//                    
//                    Spacer()
//                    
//                    
//                    if selectedTab != 2 {
//                        RectangleButtonPrimary(
//                            buttonText: getButtonText(),
//                            action: {
//                                buttonAction()
//                            },
//                            disableMainButton: disableButton(),
//                            buttonColor: .white
//                        )
//                        .padding(.bottom, 10)
//                        .padding(.horizontal)
//                        
//                    }
//                    
//                }//VStack
//            }//ZStack
//            .background {
//                if let category = focusArea?.category {
//                    BackgroundPrimary(backgroundColor: Realm.getBackgroundColor(forName: category.categoryName))
//                } else {
//                    BackgroundPrimary(backgroundColor: AppColors.backgroundCareer)
//                }
//            }
//            .onAppear {
//                getRecap()
//            }
//            .toolbar {
//               
//                ToolbarItem(placement: .principal) {
//                    ToolbarTitleItem2(emoji: focusArea?.category?.categoryEmoji ?? "", title: "Path complete")
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
//            
//        }//NavigationStack
//    }
// 
//    
//    private func getTitle() -> some View {
//        
//        HStack {
//            Group {
//                switch selectedTab {
//                case 0:
//                    Text("")
//                case 1:
//                    Text("Reflection")
//                    
//                default:
//                    Text("")
//                }
//            }
//            .multilineTextAlignment(.leading)
//            .font(.system(size: 25, design: .serif))
//            .foregroundStyle(AppColors.textPrimary)
//            
//            Spacer()
//        }
//       
//    }
//    
//    @ViewBuilder
//    private func getContent() -> some View {
//        switch selectedTab {
//        case 0:
//            if let currentFocusArea = focusArea {
//                RecapCelebrationView(animationStage: $celebrationAnimationStage, title: currentFocusArea.focusAreaTitle, text: "For exploring", points: "+1")
//                    .padding(.top, 80)
//            }
//            
//        default:
//            RecapReflectionView(
//                viewModel: topicViewModel,
//                feedback: focusArea?.summary?.summaryFeedback ?? "",
//                retryAction: {
//                    generateNewRecap()
//                },
//                focusArea: focusArea,
//                loadingText: loadingTexts
//            )
//        }
//    }
//    
//    private func getButtonText() -> String {
//        switch selectedTab {
//            case 0:
//                return "Next: A small reflection"
//                
//            case 1:
//            if let currentFocusArea = focusArea, (currentFocusArea.recapComplete != true) && (focusAreaIndex < focusAreasLimit) {
//                    return topicViewModel.createFocusAreaSummary == .loading ? "Loading..." : "Next: Go to new path"
//                } else if focusAreaIndex == focusAreasLimit {
//                    return topicViewModel.createFocusAreaSummary == .loading ? "Loading..." : "Next: Restore lost fragment"
//                } else {
//                    return "Complete"
//                }
//        
//            default:
//                return "Retry"
//        }
//    }
//    
//    private func buttonAction() {
//        switch selectedTab {
//            
//        case 0:
//            updatePoints()
//            
//        default:
//            if let currentFocusArea = focusArea, (currentFocusArea.recapComplete != true) && (focusAreaIndex < focusAreasLimit) {
//                //complete recap
//                dismiss()
//                completeFocusArea()
//            } else if focusAreaIndex == focusAreasLimit {
//                //add sections for complete quest path
//                createEndOfTopicFocsAreaIfNeeded()
//            } else {
//                //for when user is just reviewing their recap,
//                dismiss()
//            }
//        }
//    }
//    
//    private func disableButton() -> Bool {
//        switch selectedTab {
//            case 1:
//                if topicViewModel.createFocusAreaSummary == .loading {
//                    return true
//                } else {
//                    if let feedback = focusArea?.summary?.summaryFeedback {
//                       return animatedText != feedback
//                    } else {
//                        return false
//                    }
//                }
//            default:
//                return false
//            
//        }
//        
//    }
//    
//    //create or show focus area summary
//    private func getRecap() {
//        
//        if let currentFocusArea = focusArea, currentFocusArea.focusAreaStatus == FocusAreaStatusItem.completed.rawValue {
//            logger.log("Focus area summary already generated")
//            
//        } else {
//            selectedTab = 0
//            generateNewRecap()
//        }
//    }
//    
//    private func generateNewRecap() {
//        topicViewModel.createNewFocusArea = .loading //ensures focus area section list shows loading animation
//        
//        let topicId = focusArea?.topic?.topicId
//        
//        let sortedFocusAreas = topic.topicFocusAreas.sorted { $0.orderIndex < $1.orderIndex }
//        
//        let newFocusArea: FocusArea = sortedFocusAreas[focusAreaIndex]
//        
//        Task {
//            do {
//                
//                try await topicViewModel.manageRun(selectedAssistant: .focusAreaSummary, topicId: topicId, focusArea: focusArea)
//                
//                // mark focusArea complete
//                if let focusArea = focusArea {
//                    await dataController.completeFocusArea(focusArea: focusArea)
//                }
//                
//                // update next focus area status to active
//                 await dataController.updateFocusAreaStatus(focusArea: newFocusArea)
//               
//            } catch {
//                topicViewModel.createFocusAreaSummary = .retry
//            }
//            
//            if focusAreaIndex < focusAreasLimit {
//                // API call to create new focus area
//                do {
//                    
//                    // create sections for next focus area
//                    try await topicViewModel.manageRun(selectedAssistant: .focusArea, topicId: topicId, focusArea: newFocusArea)
//                    
//                } catch {
//                    topicViewModel.createNewFocusArea = .retry
//                }
//
//            }
//            
//            DispatchQueue.global(qos: .background).async {
//                Mixpanel.mainInstance().track(event: "Revealed reflection")
//            }
//        }
//    }
//    
//    private func updatePoints() {
//        selectedTab += 1
//        Task {
//            await dataController.updatePoints(newPoints: 1)
//        }
//    }
//    
//    private func completeFocusArea() {
//        dataController.newFocusArea = true //to trigger scroll to new focus area
//        
//        Task {
//            if let focusArea = focusArea {
//                await dataController.completeFocusAreaRecap(focusArea: focusArea)
//            }
//        }
//    }
//    
//    private func createEndOfTopicFocsAreaIfNeeded() {
//        topicViewModel.createNewFocusArea = .loading //change this to trigger section list view update
//        dataController.newFocusArea = true //scroll to complete quest path
//        dismiss()
//        
//        if focusAreaIndex == focusAreasLimit {
//           print("Adding sections for last path")
//            
//            Task {
//                
//                // add sections to complete quest path
//                if let topic = focusArea?.topic {
//                    await dataController.addEndOfTopicFocusArea(topic: topic)
//                }
//                
//                await MainActor.run {
//                    topicViewModel.createNewFocusArea = .ready
//                }
//            }
//        }
//    }
//}
//
//
////struct FocusAreaRecapReflectionView: View {
////    @ObservedObject var topicViewModel: TopicViewModel
////    @State private var animationValue: Bool = false
////    @State private var animator: TextAnimator?
////    @State private var startedAnimation: Bool = false
////    
////    @Binding var recapReady: Bool
////    @Binding var animatedText: String
////    
////    let feedback: String
////    let focusArea: FocusArea?
////    
////    var body: some View {
////        
////        Group {
////            if recapReady {
////                Text(animatedText)
////                    .font(.system(size: 19, design: .serif))
////                    .foregroundStyle(AppColors.textPrimary.opacity(0.9))
////                    .lineSpacing(1.5)
////                
////            } else {
////                HStack {
////                    Image(systemName: "ellipsis")
////                        .font(.system(size: 25, weight: .regular))
////                        .foregroundStyle(AppColors.textPrimary.opacity(0.9))
////                        .symbolEffect(.wiggle.byLayer, options: animationValue ? .repeating : .nonRepeating, value: animationValue)
////                    
////                    Spacer()
////                }
////                .transition(.asymmetric(insertion: .opacity, removal: .identity))
////                .onAppear {
////                    animationValue = true
////                }
////                .onDisappear {
////                    animationValue = false
////                }
////            }
////        }
////        .onAppear {
////            if animator == nil {
////                    animator = TextAnimator(text: feedback, animatedText: $animatedText, speed: 0.04)
////                }
////            
////            if topicViewModel.createFocusAreaSummary == .ready {
////                if let focusArea = focusArea, focusArea.focusAreaStatus == FocusAreaStatusItem.completed.rawValue {
////                    animatedText = feedback //no animation if use has already seen the feedback once
////                    startedAnimation = true //prevent triggering animation when recapReady is set to true
////                    recapReady = true
////                } else {
////                    startedAnimation = true
////                    recapReady = true
////                    animator?.animate()
////                }
////            } else {
////                recapReady = false
////            }
////        }
////        .onChange(of: recapReady) {
////            if recapReady && !startedAnimation {
////                print("recap ready, starting typewriter animation")
////                if animator == nil {
////                    animator = TextAnimator(text: feedback, animatedText: $animatedText, speed: 0.02)
////                } else {
////                    animator?.updateText(feedback)
////                }
////                animator?.animate()
////            }
////        }
////    }
////
////}
