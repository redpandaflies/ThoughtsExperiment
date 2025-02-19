//
//  EndTopicView.swift
//  Fearless2
//
//  Created by Yue Deng-Wu on 2/18/25.
//
import Mixpanel
import SwiftUI

struct EndTopicView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var dataController: DataController
    @ObservedObject var topicViewModel: TopicViewModel
    @State private var selectedTab: Int = 0
    @Binding var section: Section?
    @ObservedObject var topic: Topic
    
    
    var body: some View {
        NavigationStack {
            VStack {

                switch selectedTab {
                case 0:
                    
                    RecapCelebrationView(title: section?.topic?.topicTitle ?? "", text: "For completing")
                        .padding(.horizontal)

                default:
                    topicRecapView()
                        .padding(.top, 30)
                    
                    Spacer()
                }
      
                
                RectangleButtonYellow(
                    buttonText: getButtonText(),
                    action: {
                        buttonAction()
                    },
                    buttonColor: .white
                )
                .padding(.bottom, 10)
                .padding(.horizontal)
                
                
            }//VStack
            .background {
                if let category = topic.category {
                    AppBackground(backgroundColor: Realm.getBackgroundColor(forName: category.categoryName))
                } else {
                    AppBackground(backgroundColor: AppColors.backgroundCareer)
                }
            }
            .onAppear {
                getTopicReview()
            }
            .toolbar {
               
                ToolbarItem(placement: .principal) {
                    ToolbarTitleItem2(emoji: topic.category?.categoryEmoji ?? "", title: topic.topicTitle)
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
        return (selectedTab == 0 ) ? "Next: restore lost fragment" : "Done"
    }
    
    private func buttonAction() {
        if selectedTab == 0 {
            selectedTab += 1
        } else {
            Task {
                //mark section as complete
                section?.completed = true
                await dataController.save()
                
                //close view
                dismiss()
            }
        }
    }
    
    @ViewBuilder private func topicRecapView() -> some View {
        switch topicViewModel.createTopicOverview {
        case .ready:
            TopicRecapFragmentBox(fragmentText: topic.review?.reviewOverview ?? "")
        case .loading:
            LoadingPlaceholderContent(contentType: .topicReview)
        case .retry:
            RetryButton(action: {
                getTopicReview()
            })
        }
    }
    
    private func getTopicReview() {
        Task {
            
            //generate review
            do {
                try await topicViewModel.manageRun(selectedAssistant: .topicOverview, topicId: topic.topicId)
            } catch {
                topicViewModel.createTopicOverview = .retry
            }
            
            DispatchQueue.global(qos: .background).async {
                Mixpanel.mainInstance().track(event: "Updated topic overview")
            }
        }
    }
}

struct TopicRecapFragmentBox: View {
    
    let fragmentText: String
    
    var body: some View {
        VStack (spacing: 30 ){
            
            HStack {
                shortLine()
                
                Text("Fragment restored")
                    .font(.system(size: 19, weight: .light).smallCaps())
                    .fontWidth(.condensed)
                    .foregroundStyle(AppColors.textBlack)
                    .textCase(.uppercase)
                    .opacity(0.8)
                
                
                shortLine()
                
            }
            
            
            Text(fragmentText)
                .font(.system(size: 25, design: .serif))
                .foregroundStyle(AppColors.textBlack)
                .lineSpacing(1.3)
            
        }
        .padding(.horizontal, 30)
        .padding(.vertical, 40)
        .frame(width: 310)
        .background {
            RoundedRectangle(cornerRadius: 25)
                .stroke(Color.white.opacity(0.4), lineWidth: 0.5)
                .fill(
                    LinearGradient(colors: [Color.white, AppColors.boxSecondary], startPoint: .top, endPoint: .bottom)
                )
                .shadow(color: Color.white.opacity(0.25), radius: 30, x: 0, y: 0)
                .padding(10)
                .background {
                    RoundedRectangle(cornerRadius: 25)
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
            .frame(width: 40, height: 1)
    }
}
