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
    @Binding var showFocusAreasView: Bool
    
    let columns = [GridItem(.adaptive(minimum:150), spacing: 15)]
    
    @FetchRequest(
        sortDescriptors: [
            NSSortDescriptor(key: "createdAt", ascending: true)
        ]
    ) var topics: FetchedResults<Topic>
    
    var body: some View {
        NavigationStack {
            ZStack {
                
                ScrollView (showsIndicators: false) {
                    LazyVGrid(columns: columns, spacing: 15) {
                        ForEach(topics, id: \.topicId) { topic in
                            
                            NavigationLink (destination: TopicDetailView(topicViewModel: topicViewModel, transcriptionViewModel: transcriptionViewModel, topic: topic)) {
                                TopicBox(topic: topic)
                            }
                               
                        }
                    }
                    
                }
                .padding()
                .scrollClipDisabled(true)
                .safeAreaInset(edge: .top, content: {
                    Rectangle()
                        .foregroundStyle(.clear)
                        .frame(height: 100)
                })
                
                VStack {
                    Spacer()
                    
                    RectangleButton(buttonName: "New Topic")
                        .padding()
                        .onTapGesture {
                            showCreateNewTopicView = true
                        }
                        .sensoryFeedback(.selection, trigger: showCreateNewTopicView) { oldValue, newValue in
                            return oldValue != newValue && newValue == true
                        }
                }
                .padding(.bottom, 110)
            }//ZStack
            .ignoresSafeArea(.keyboard)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    ToolbarTitleItem(title: "Your Topics")
                }
                
                ToolbarItem(placement: .topBarTrailing) {
                    ProfileToolbarItem()
                }
            }
            .navigationBarTitleDisplayMode(.inline)
        }
        
    }
}

//#Preview {
//    ActiveTopicsView()
//}
