//
//  HomeView.swift
//  Fearless2
//
//  Created by Yue Deng-Wu on 9/30/24.
//
import CoreData
import SwiftUI

struct HomeView: View {
    
    @ObservedObject var topicViewModel: TopicViewModel
    
    @State private var scrollPosition: Int?
    @State private var showSummarySheet: Bool = false
    @Binding var showCreateNewTopicView: Bool
    @Binding var showUpdateTopicView: Bool
    @Binding var selectedCategory: CategoryItem
    @Binding var topicId: UUID?
    @Binding var selectedQuestion: String
    
    @FetchRequest(
        sortDescriptors: [
            NSSortDescriptor(key: "createdAt", ascending: true)
        ]
    ) var topics: FetchedResults<Topic>
    
    var body: some View {
        ZStack {
            ScrollView {
                VStack (spacing: 20){
                    
                    if scrollPosition == topics.count {
                        
                        CategoryView(showCreateNewTopicView: $showCreateNewTopicView, selectedCategory: $selectedCategory)
                        
                    } else if let index = scrollPosition, topics.count > 0 {
                        let topic = topics[index]
                        
                        //Top view
                        HomeTopView(topicFeedback: topic.topicFeedback)
                            .onTapGesture {
                                showSummarySheet = true
                            }
                        
                        //Questions
                        HomeQuestionsView(showUpdateTopicView: $showUpdateTopicView, topicId: $topicId, selectedQuestion: $selectedQuestion, questions: topic.topicQuestions)
                    }
                    
                    Spacer()
                    
                    
                }//VStack
                .padding(.horizontal)
            }
            .scrollDisabled(true)
            
            VStack {
                Spacer()
                //Carousel
                HomeCarouselView(scrollPosition: $scrollPosition, topics: Array(topics))
            }

            
        }
        .ignoresSafeArea(.keyboard)
        .ignoresSafeArea(edges: .bottom)
        .background {
            AppColors.homeBackground
                .ignoresSafeArea()
        }
        .safeAreaInset(edge: .top, content: {
                Color.clear
                    .frame(height: 10)
        })
        .toolbar {
            
            ToolbarItem(placement: .topBarLeading) {
                SettingsToolbarItem()
            }
            
            ToolbarItem(placement: .principal) {
                Image("cloudWithEyes")
                    .resizable()
                    .scaledToFit()
                    .frame(height: 40)
                 
            }
            
            ToolbarItem(placement: .topBarTrailing) {
                ProfileToolbarItem()
              
                
            }
            
        }
        .navigationBarTitleDisplayMode(.inline)
        .customToolbarAppearance()
        .dynamicTypeSize(.large)
        .onChange(of: showCreateNewTopicView) {
            if !showCreateNewTopicView && topics.count > 0 && topicViewModel.topicUpdated {
                scrollPosition = topics.count - 1
                topicViewModel.topicUpdated = false
            }
        }
        .sheet(isPresented: $showSummarySheet, onDismiss: {
            showSummarySheet = false
        }) {
            if let index = scrollPosition {
                let topic = topics[index]
                SummaryView(topic: topic)
                    .presentationCornerRadius(30)
                    .presentationBackground{
                        Color.clear
                            .background(.regularMaterial)
                            .environment(\.colorScheme, .light)
                    }
            }
            
        }
    }
}

//#Preview {
//    AppViewsManager()
//}
