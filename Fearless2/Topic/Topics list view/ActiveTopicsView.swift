//
//  ActiveTopicsView.swift
//  Fearless2
//
//  Created by Yue Deng-Wu on 11/7/24.
//
import CoreData
import SwiftUI

struct ActiveTopicsView: View {
    @ObservedObject var topicViewModel: TopicViewModel
    @ObservedObject var transcriptionViewModel: TranscriptionViewModel
    
    @State private var showSectionRecapView: Bool = false
    
    @State private var selectedSection: Section? = nil
    @State private var selectedCategory: TopicCategoryItem = .personal
    
    @Binding var showCreateNewTopicView: Bool
    @Binding var selectedTopic: Topic?
    @Binding var showTabBar: Bool
    @Binding var currentTabBar: TabBarType
    @Binding var selectedTabTopic: TopicPickerItem
    @Binding var navigateToTopicDetailView: Bool
    
    let columns = [GridItem(.adaptive(minimum:150), spacing: 15)]
    
    @FetchRequest(
        sortDescriptors: [
            NSSortDescriptor(key: "createdAt", ascending: false)
        ]
    ) var topics: FetchedResults<Topic>
    
    var body: some View {
        NavigationStack {
            VStack {
                
                ScrollView (showsIndicators: false) {
                    LazyVGrid(columns: columns, spacing: 15) {
                        ForEach(topics, id: \.topicId) { topic in

                            TopicBox(topicViewModel: topicViewModel, topic: topic)
                                .onTapGesture {
                                    //set selected topic ID so that delete topic works
                                    selectedTopic = topic
                                    
                                    navigateToTopicDetailView = true
                                    
                                    
                                    //change footer
                                    withAnimation(.snappy(duration: 0.2)) {
                                        currentTabBar = .topic
                                    }
                                }
                                
                        }
                        
                        AddTopicButton()
                            .onTapGesture {
                                showCreateNewTopicView = true
                            }
                            .sensoryFeedback(.selection, trigger: showCreateNewTopicView) { oldValue, newValue in
                                return oldValue != newValue && newValue == true
                            }
                        
                    }
                    .navigationDestination(isPresented: $navigateToTopicDetailView) {
                        if let topic = selectedTopic {
                            TopicDetailView(topicViewModel: topicViewModel, transcriptionViewModel: transcriptionViewModel, showTabBar: $showTabBar, selectedTabTopic: $selectedTabTopic, topic: topic)
                        }
                    }
                
                
                    
                }
                .scrollClipDisabled(true)
                .padding()
                .safeAreaInset(edge: .bottom, content: {
                    Rectangle()
                        .fill(Color.clear)
                        .frame(height: 50)
                })
                
                
               
            }//VStack
            .ignoresSafeArea(.keyboard)
            .toolbarBackground(Color.black)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    ToolbarTitleItem(title: "Top of mind", regularSize: true)
                }
                
//                ToolbarItem(placement: .topBarTrailing) {
//                    ProfileToolbarItem()
//                }
            }
            .navigationBarTitleDisplayMode(.inline)
        }
        .environment(\.colorScheme, .dark)
    }
}

//#Preview {
//    ActiveTopicsView()
//}
