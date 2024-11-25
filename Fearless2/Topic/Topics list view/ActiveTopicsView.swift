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
    
    @State private var showUpdateTopicView: Bool? = nil
    @State private var showSectionRecapView: Bool = false
   
    @State private var selectedSection: Section? = nil
    @State private var selectedCategory: TopicCategoryItem = .personal
    
    @Binding var showCreateNewTopicView: Bool
    @Binding var selectedTopic: Topic?
   
    
    let columns = [GridItem(.adaptive(minimum:150), spacing: 15)]
    
    @FetchRequest(
        sortDescriptors: [
            NSSortDescriptor(key: "createdAt", ascending: true)
        ]
    ) var topics: FetchedResults<Topic>
    
    var body: some View {
       
            VStack {
                
                ScrollView (showsIndicators: false) {
                    LazyVGrid(columns: columns, spacing: 15) {
                        ForEach(topics, id: \.topicId) { topic in
                            
                            NavigationLink (destination: TopicDetailView(topicViewModel: topicViewModel, transcriptionViewModel: transcriptionViewModel, topic: topic)) {
                                TopicBox(topic: topic)
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
    }
}

//#Preview {
//    ActiveTopicsView()
//}
