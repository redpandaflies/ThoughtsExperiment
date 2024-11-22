//
//  CreateNewTopicView.swift
//  Fearless2
//
//  Created by Yue Deng-Wu on 10/1/24.
//

import SwiftUI

struct CreateNewTopicView: View {
    @EnvironmentObject var dataController: DataController
    @ObservedObject var topicViewModel: TopicViewModel
    
    @State private var showCard: Bool = false
    @State private var selectedTab: Int = 0
    
    @Binding var showCreateNewTopicView: Bool
    
    let selectedCategory: TopicCategoryItem
    
    var body: some View {
        ZStack {
            Rectangle()
                .fill(Material.ultraThin)
                .ignoresSafeArea()
                .onTapGesture {
                    cancelEntry()
                }
            
            switch selectedTab {
            case 0:
                if showCard {
                    CreateNewTopicBox(topicViewModel: topicViewModel, showCard: $showCard, selectedTab: $selectedTab, selectedCategory: selectedCategory)
                        .padding(.horizontal)
                        .transition(.move(edge: .bottom))
                }
                
            default:
                LoadingAnimation(selectedCategory: selectedCategory)
                
            }
            
        }
        .environment(\.colorScheme, .dark)
        .onAppear {
            withAnimation(.snappy(duration: 0.2)) {
                self.showCard = true
            }
        }
        .onChange(of: topicViewModel.topicUpdated) {
            if topicViewModel.topicUpdated {
                showCreateNewTopicView = false
                
            }
        }
    }
    
    private func cancelEntry() {
        withAnimation(.snappy(duration: 0.2)) {
            self.showCard = false
        }
        showCreateNewTopicView = false
//        Task {
//            if let topicId = dataController.newTopic?.topicId {
//                await self.dataController.deleteTopic(id: topicId)
//            }
//        }
    }
}

//#Preview {
//    CreateNewTopicView(selectedCategory: .decision)
//}
