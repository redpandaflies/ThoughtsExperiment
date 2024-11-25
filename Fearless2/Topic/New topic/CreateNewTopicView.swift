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
    @State private var selectedTab: Int = 0
    @State private var showCard: Bool = false
    
    @Binding var showCreateNewTopicView: Bool
    @Binding var selectedCategory: TopicCategoryItem
    
    var body: some View {
        ZStack {
            Rectangle()
                .fill(Material.ultraThin)
                .ignoresSafeArea()
                .onTapGesture {
                    cancelEntry()
                }
            
           
            if showCard {
                CreateNewTopicBox(topicViewModel: topicViewModel, showCard: $showCard, selectedTab: $selectedTab)
                    .padding(.horizontal)
                    .transition(.move(edge: .bottom))
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
        Task {
            if let topicId = dataController.newTopic?.topicId {
                await self.dataController.deleteTopic(id: topicId)
            }
        }
        withAnimation(.snappy(duration: 0.2)) {
            self.showCard = false
        }
        showCreateNewTopicView = false
    }
}

//#Preview {
//    CreateNewTopicView(selectedCategory: .decision)
//}
