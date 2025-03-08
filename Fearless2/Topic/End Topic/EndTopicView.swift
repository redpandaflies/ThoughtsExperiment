//
//  EndTopicView.swift
//  Fearless2
//
//  Created by Yue Deng-Wu on 2/18/25.
//
import Mixpanel
import Pow
import SwiftUI

struct EndTopicView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var dataController: DataController
    @ObservedObject var topicViewModel: TopicViewModel
    @State private var selectedTab: Int = 0
    @State private var showFragment: Bool = false
    @State private var startRepeatingAnimation: Bool = false
    @Binding var section: Section?
    @ObservedObject var topic: Topic
    
    
    var body: some View {
        NavigationStack {
            VStack {
                
                Group {
                    switch selectedTab {
                    case 0:
                        
                        RecapCelebrationView(title: section?.topic?.topicTitle ?? "", text: "For completing", points: "+5")
                            .padding(.horizontal)
                            .padding(.bottom, 30)
                        
                    default:
                        topicRecapView()
                        
                    }
                }
                .padding(.bottom, 90)
                
                RectangleButtonPrimary(
                    buttonText: getButtonText(),
                    action: {
                        buttonAction()
                    },
                    disableMainButton: disableButton(),
                    buttonColor: .white
                )
                .padding(.bottom, 10)
                .padding(.horizontal)
                
                
            }//VStack
            .background {
                if let category = topic.category {
                    BackgroundPrimary(backgroundColor: Realm.getBackgroundColor(forName: category.categoryName))
                } else {
                    BackgroundPrimary(backgroundColor: AppColors.backgroundCareer)
                }
            }
            .onAppear {
                getTopicReview()
            }
            .toolbar {
               
                ToolbarItem(placement: .principal) {
                    ToolbarTitleItem2(emoji: topic.category?.categoryEmoji ?? "", title: "Quest complete")
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    XmarkToolbarItem()
                }
                
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackgroundVisibility(.hidden)
            
        }//NavigationStack
    }
    
    
    private func getButtonText() -> String {
        if selectedTab == 0 {
            return "Next: restore lost fragment"
        } else {
            return getButtonTextFragmentView()
        }
    }
    
    private func getButtonTextFragmentView() -> String {
        switch topicViewModel.createTopicOverview {
        case .ready:
            return "Done"
        case .loading:
           return "Restoring . . ."
        case .retry:
            return "Retry"
        }
    }
    
    
    private func buttonAction() {
        if selectedTab == 0 {
            selectedTab += 1
        } else {
            
            if let currentSection = section {
                Task {
                    //mark section as complete
                    await dataController.completeSection(section: currentSection)
                    
                    //mark topic as complete
                    await dataController.completeTopic(topic: topic, section: currentSection)
                    
                    //close view
                    await MainActor.run {
                        dismiss()
                    }
                }
            }
        }
    }
    
    private func disableButton() -> Bool {
        switch selectedTab {
        case 0:
            return false
        default:
            return topicViewModel.createTopicOverview != .ready
        }
    }
    
    @ViewBuilder private func topicRecapView() -> some View {
        
        VStack {
                
            switch topicViewModel.createTopicOverview {
            case .ready:
                if let review = topic.review?.reviewOverview {
                    if showFragment {
                        TopicRecapFragmentBox(fragmentText: review)
                            .transition(.movingParts.flip)
                            .conditionalEffect(
                                  .repeat(
                                    .glow(color: .white.opacity(0.25), radius: 80),
                                    every: 3
                                  ),
                                  condition: startRepeatingAnimation
                              )
                    }
                } else { //happens when user sees this view before API call has been made
                    LoadingPlaceholderContent(contentType: .topicReview)
                }
            case .loading:
                LoadingPlaceholderContent(contentType: .topicReview)
            case .retry:
                RetryButton(action: {
                    getTopicReview()
                })
            }
            
        }
        .frame(maxHeight: .infinity, alignment: .center)
        .onAppear {
            revealFragment()
        }
        .onChange(of: topicViewModel.createTopicOverview) {
            revealFragment()
        }
        .onDisappear {
            startRepeatingAnimation = false
        }
    }
    
    private func getTopicReview() {
        
        if let _ = topic.review?.reviewOverview {
            selectedTab = 1
        } else {
            
            Task {
                
                //generate review
                do {
                    try await topicViewModel.manageRun(selectedAssistant: .topicOverview, topicId: topic.topicId)
                } catch {
                    topicViewModel.createTopicOverview = .retry
                }
                
                DispatchQueue.global(qos: .background).async {
                    Mixpanel.mainInstance().track(event: "Restored fragment")
                }
            }
        }
    }
    
    private func revealFragment() {
        if topicViewModel.createTopicOverview == .ready {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                withAnimation(.interpolatingSpring(mass: 1, stiffness: 10, damping: 10, initialVelocity: 10)) {
                    showFragment = true
                }
                
                startRepeatingAnimation = true
            }
            
        }
    }
}

struct TopicRecapFragmentBox: View {
    
    let fragmentText: String
    let boxBorder: CGFloat = 10
    
    var body: some View {
       
        VStack (spacing: 0){
            
            HStack {
                shortLine()
                
                Text("Fragment restored")
                    .font(.system(size: 19, weight: .light).smallCaps())
                    .fontWidth(.condensed)
                    .foregroundStyle(AppColors.textBlack)
                    .tracking(0.3)
                    .opacity(0.8)
                    .fixedSize()
                    .padding(.horizontal, 10)
                shortLine()
                
            }
            .frame(height: 70, alignment: .bottom)
          
            
            HStack {
                Text(fragmentText)
                    .multilineTextAlignment(.center)
                    .font(.system(size: 20, design: .serif))
                    .foregroundStyle(AppColors.textBlack)
                    .lineSpacing(1.3)
                    .padding(.bottom, 40)
            }
            .frame(minHeight: 240)
           
            
        }
        .padding(.horizontal, 35)
        .frame(width: 310)
        .background {
            RoundedRectangle(cornerRadius: 25)
                .stroke(Color.white.opacity(0.4), lineWidth: 0.5)
                .fill(
                    LinearGradient(colors: [Color.white, AppColors.boxSecondary], startPoint: .top, endPoint: .bottom)
                )
                .shadow(color: Color.white.opacity(0.25), radius: 30, x: 0, y: 0)
                .padding(boxBorder)
                .background {
                    RoundedRectangle(cornerRadius: 30)
                        .stroke(Color.white.opacity(0.2), lineWidth: 0.5)
                        .fill(AppColors.boxGrey1.opacity(0.2))
                        .blendMode(.colorDodge)
                    
                }
                
        }

        
    }
    
    private func shortLine() -> some View {
        Rectangle()
            .fill(Color.black.opacity(0.1))
            .shadow(color: Color.white.opacity(0.5), radius: 0, x: 0, y: 1)
            .frame(maxWidth: .infinity)
            .frame(height: 1)
    }
}

#Preview {
    TopicRecapFragmentBox(fragmentText: "You observe the moment, but do you let it transform you?")
}
