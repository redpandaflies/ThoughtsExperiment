//
//  CreateNewTopicView.swift
//  Fearless2
//
//  Created by Yue Deng-Wu on 10/1/24.
//

import SwiftUI

struct CreateNewTopicView: View {
    @ObservedObject var topicViewModel: TopicViewModel
    
    @State private var topicText = ""
    @State private var showCard: Bool = false
    @State private var selectedTab: Int = 0
    
    @Binding var showCreateNewTopicView: Bool
    
    let selectedCategory: TopicCategoryItem

    let screenWidth = UIScreen.current.bounds.width
    
    var body: some View {
        ZStack {
            Rectangle()
                .fill(Material.ultraThin)
                .ignoresSafeArea()
                .onTapGesture {
                    withAnimation(.snappy(duration: 0.2)) {
                        self.showCard = false
                    }
                    showCreateNewTopicView = false
                }
            
            switch selectedTab {
            case 0:
                if showCard {
                    CreateNewTopicBox(topicViewModel: topicViewModel, showCard: $showCard, selectedTab: $selectedTab, selectedCategory: selectedCategory)
                        .padding(.horizontal)
                        .transition(.move(edge: .bottom))
                }
                
            default:
                LoadingAnimation()
                
            }
            
        }
        .environment(\.colorScheme, .light)
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
}

//#Preview {
//    CreateNewTopicView(selectedCategory: .decision)
//}
