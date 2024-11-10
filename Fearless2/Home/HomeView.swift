//
//  HomeView.swift
//  Fearless2
//
//  Created by Yue Deng-Wu on 9/30/24.
//
//import CoreData
//import SwiftUI
//
//struct HomeView: View {
//    
//    @ObservedObject var topicViewModel: TopicViewModel
//    
//    @State private var scrollPosition: Int?
//    @State private var showSummarySheet: Bool = false
//    @Binding var showCreateNewTopicView: Bool
//    @Binding var showUpdateTopicView: Bool?
//    @Binding var showSectionRecapView: Bool
//    @Binding var selectedCategory: TopicCategoryItem
//    @Binding var topicId: UUID?
//    @Binding var selectedQuestion: String
//    @Binding var selectedSection: Section?
//    
//    @FetchRequest(
//        sortDescriptors: [
//            NSSortDescriptor(key: "createdAt", ascending: true)
//        ]
//    ) var topics: FetchedResults<Topic>
//    
//    let screenWidth: CGFloat = UIScreen.current.bounds.width
//    let screenHeight: CGFloat = UIScreen.current.bounds.height
//    
//    var body: some View {
//        ZStack {
//            ScrollView {
//                VStack (spacing: 20){
//                    
//                    if scrollPosition == topics.count {
//                        
//                        TopicCategoryView(showCreateNewTopicView: $showCreateNewTopicView, selectedCategory: $selectedCategory)
//                        
//                    } else if let index = scrollPosition, topics.count > 0 {
//                        let topic = topics[index]
//
//                        FocusAreaView(topicViewModel: topicViewModel, showUpdateTopicView: $showUpdateTopicView, showSectionRecapView: $showSectionRecapView, selectedCategory: $selectedCategory, selectedSection: $selectedSection, topicId: topic.topicId)
//                        
//                        
//                    }
//                    
//                    Spacer()
//                    
//                    
//                }//VStack
//                .padding(.horizontal)
//            }
//            .scrollIndicators(.hidden)
//            .safeAreaInset(edge: .bottom, content: {
//                    Color.clear
//                        .frame(height: screenHeight * 0.4)
//            })
//          
//            VStack {
//                Spacer()
//                
//                LinearGradient(
//                    gradient: Gradient(colors: [AppColors.homeBackground, Color.clear]),
//                    startPoint: UnitPoint(x: 0.5, y: 0.2),
//                    endPoint: UnitPoint(x: 0.5, y: 0)
//                )
//                    .frame(width: screenWidth, height: screenHeight * 0.4)
//                    .mask(
//                    Rectangle()
//                    .frame(width: screenWidth, height: screenHeight * 0.4)
//                      .blur(radius: 10)
//                    )
//                
//            }
//            
//            VStack {
//                Spacer()
//                //Carousel
//                HomeCarouselView(scrollPosition: $scrollPosition, topicId: $topicId, topics: Array(topics))
//            }
//
//            
//        }
//        .ignoresSafeArea(.keyboard)
//        .ignoresSafeArea(edges: .bottom)
//        .background {
//            AppColors.homeBackground
//                .ignoresSafeArea()
//        }
//        .safeAreaInset(edge: .top, content: {
//                Color.clear
//                    .frame(height: 10)
//        })
//      
//        .toolbar {
//            
//            ToolbarItem(placement: .topBarLeading) {
//                SettingsToolbarItem()
//            }
//            
//            ToolbarItem(placement: .principal) {
//                Image("cloudWithEyes")
//                    .resizable()
//                    .scaledToFit()
//                    .frame(height: 40)
//                 
//            }
//            
//            ToolbarItem(placement: .topBarTrailing) {
//                ProfileToolbarItem()
//              
//                
//            }
//            
//        }
//        .navigationBarTitleDisplayMode(.inline)
//        .customToolbarAppearance()
//        .dynamicTypeSize(.large)
//        .onChange(of: showCreateNewTopicView) {
//            if !showCreateNewTopicView && topics.count > 0 && topicViewModel.topicUpdated {
//                scrollPosition = topics.count - 1
//                if let index = scrollPosition, index != topics.count {
//                    self.topicId = topics[index].topicId
//                }
//            }
//        }
//        .sheet(isPresented: $showSummarySheet, onDismiss: {
//            showSummarySheet = false
//        }) {
//            if let index = scrollPosition {
//                let topic = topics[index]
//                SummaryView(topic: topic)
//                    .presentationCornerRadius(30)
//                    .presentationBackground{
//                        Color.clear
//                            .background(.regularMaterial)
//                            .environment(\.colorScheme, .light)
//                    }
//            }
//            
//        }
//    }
//}

//#Preview {
//    AppViewsManager()
//}
