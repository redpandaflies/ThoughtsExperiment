//
//  ArchivedTopicsView.swift
//  Fearless2
//
//  Created by Yue Deng-Wu on 11/7/24.
//
import CoreData
import SwiftUI

struct ArchivedTopicsView: View {
    @ObservedObject var topicViewModel: TopicViewModel
    @ObservedObject var transcriptionViewModel: TranscriptionViewModel
    
    @Binding var selectedTopic: Topic?
    @Binding var currentTabBar: TabBarType
    @Binding var selectedTabTopic: TopicPickerItem
    @Binding var navigateToTopicDetailView: Bool
    
    let columns = [GridItem(.adaptive(minimum:150), spacing: 15)]
    
    @FetchRequest(
        sortDescriptors: [
            NSSortDescriptor(key: "createdAt", ascending: false)
        ],
        predicate: NSPredicate(format: "status == %@", TopicStatusItem.archived.rawValue)
    ) var topics: FetchedResults<Topic>
    
    var body: some View {
            ScrollView {
                
                if !topics.isEmpty {
                    TopicsGridView(
                        topicViewModel: topicViewModel,
                        topics: topics,
                        onTopicTap: { topic in
                            onTopicTap(topic: topic)
                        },
                        showAddButton: false
                    )
                    .navigationDestination(isPresented: $navigateToTopicDetailView) {
                        if let topic = selectedTopic {
                            TopicDetailView(topicViewModel: topicViewModel, transcriptionViewModel: transcriptionViewModel, selectedTabTopic: $selectedTabTopic, topic: topic)
                        }
                    }
                } else {
                    ArchivedTopicsEmptyState()
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
        
        selectedTabTopic = .review
        
        navigateToTopicDetailView = true
        
        //change footer
        withAnimation(.snappy(duration: 0.2)) {
            currentTabBar = .topic
        }
    }
}

struct ArchivedTopicsEmptyState: View {
    
    var body: some View {
        VStack (spacing: 20){
            
            Image("archivedEmptyState")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 196)
            
        
            Text("Once you’re done with a topic, you can archive it for future reference. Archived topics will show up here.")
                .multilineTextAlignment(.center)
                .font(.system(size: 13))
                .foregroundStyle(AppColors.whiteDefault.opacity(0.7))
                .padding()
                .background {
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color.white.opacity(0.2), lineWidth: 0.5)
                }
              
        }
        .padding(.top, 110)
    }
}

//#Preview {
//    ActiveTopicsView()
//}
