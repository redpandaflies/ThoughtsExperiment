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
    
    @Binding var showCreateNewTopicView: Bool
    @Binding var selectedTopic: Topic?
    @Binding var currentTabBar: TabBarType
    @Binding var selectedTabTopic: TopicPickerItem
    @Binding var navigateToTopicDetailView: Bool
    
    let columns = [GridItem(.adaptive(minimum:150), spacing: 15)]
    
    @FetchRequest(
        sortDescriptors: [
            NSSortDescriptor(key: "createdAt", ascending: false)
        ],
        predicate: NSPredicate(format: "status == %@ OR status == nil", TopicStatusItem.active.rawValue)
    ) var topics: FetchedResults<Topic>
    
    var body: some View {
            ScrollView {
                TopicsGridView(
                    topicViewModel: topicViewModel,
                    topics: topics,
                    onTopicTap: { topic in
                        onTopicTap(topic: topic)
                    },
                    showAddButton: true,
                    onAddButtonTap: {
                        showCreateNewTopicView = true
                    }
                )
                .navigationDestination(isPresented: $navigateToTopicDetailView) {
                    if let topic = selectedTopic {
                        TopicDetailView(topicViewModel: topicViewModel, transcriptionViewModel: transcriptionViewModel, selectedTabTopic: $selectedTabTopic, topic: topic)
                    }
                }
            }
            .scrollClipDisabled(true)
            .scrollIndicators(.hidden)
            .padding()
            .safeAreaInset(edge: .bottom, content: {
                Rectangle()
                    .fill(Color.clear)
                    .frame(height: 50)
            })
          
        }
    
    
    private func onTopicTap(topic: Topic) {
        //set selected topic ID so that delete topic works
        selectedTopic = topic
        
        navigateToTopicDetailView = true
        
        //change footer
        withAnimation(.snappy(duration: 0.2)) {
            currentTabBar = .topic
        }
    }
}

//#Preview {
//    ActiveTopicsView()
//}
