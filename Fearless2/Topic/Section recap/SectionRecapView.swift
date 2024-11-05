//
//  SectionRecapView.swift
//  Fearless2
//
//  Created by Yue Deng-Wu on 10/30/24.
//
import CoreData
import SwiftUI

struct SectionRecapView: View {
    @EnvironmentObject var dataController: DataController
    @ObservedObject var topicViewModel: TopicViewModel
    @State private var selectedTab: Int = 0
    @State private var showCard: Bool = false
    @Binding var showSectionRecapView: Bool
    @Binding var topicId: UUID?
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
                    SectionRecapBox(topicViewModel: topicViewModel, selectedTab: $selectedTab, topicId: $topicId, selectedPage: .reflection, selectedCategory: selectedCategory)
                        .padding(.horizontal)
                        .transition(.move(edge: .bottom))
                }
                
            case 1:
                LoadingAnimation()
            
            case 2:
                SectionRecapBox(topicViewModel: topicViewModel, selectedTab: $selectedTab, topicId: $topicId, selectedPage: .suggestions, selectedCategory: selectedCategory)
                    .padding(.horizontal)
                    .transition(.move(edge: .bottom))
             
                
            default:
                LoadingAnimation()
                
            }
            
        }//ZStack
        .environment(\.colorScheme, .light)
        .onAppear {
            withAnimation(.snappy(duration: 0.2)) {
                self.showCard = true
            }
        }
        .onChange(of: topicViewModel.topicUpdated) {
            if topicViewModel.topicUpdated && selectedTab == 1 {
                withAnimation(.snappy(duration: 0.2)) {
                    selectedTab += 1
                }
                
            } else if topicViewModel.topicUpdated && selectedTab > 2 {
                showSectionRecapView = false
            }
        }
            
        
    }
    
    private func cancelEntry() {
        withAnimation(.snappy(duration: 0.2)) {
            self.showCard = false
        }
        showSectionRecapView = false
    }
    
}

//#Preview {
//    SectionReflectionView()
//}
