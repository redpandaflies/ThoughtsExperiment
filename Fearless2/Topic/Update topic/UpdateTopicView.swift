//
//  UpdateTopicView.swift
//  Fearless2
//
//  Created by Yue Deng-Wu on 10/3/24.
//

import SwiftUI

struct UpdateTopicView: View {
    @ObservedObject var topicViewModel: TopicViewModel
    
    @State private var topicText = ""
    @State private var showCard: Bool = false
    @State private var selectedTab: Int = 0
    
    @Binding var showUpdateTopicView: Bool
    
    let selectedCategory: CategoryItem
    let topicId: UUID?
    let question: String
    
    var body: some View {
        ZStack {
            Rectangle()
                .fill(Material.ultraThin)
                .ignoresSafeArea()
                .onTapGesture {
                    withAnimation(.snappy(duration: 0.2)) {
                        self.showCard = false
                    }
                    showUpdateTopicView = false
                }

            
            switch selectedTab {
            case 0:
                if showCard {
                    UpdateTopicBox(topicViewModel: topicViewModel, showCard: $showCard, selectedTab: $selectedTab, selectedCategory: selectedCategory, topicId: topicId, question: question)
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
                showUpdateTopicView = false
                
            }
        }
    }
}

//#Preview {
//    UpdateTopicView()
//}
