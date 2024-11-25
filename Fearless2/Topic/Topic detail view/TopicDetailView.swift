//
//  TopicDetailView.swift
//  Fearless2
//
//  Created by Yue Deng-Wu on 11/12/24.
//

import SwiftUI

struct TopicDetailView: View {
    @ObservedObject var topicViewModel: TopicViewModel
    @ObservedObject var transcriptionViewModel: TranscriptionViewModel
    @State private var selectedTab: TopicPickerItem = .paths
    @State private var showRecordingView: Bool = false
    @State private var selectedEntry: Entry? = nil
    @State private var showUpdateTopicView: Bool? = nil
    @State private var showSectionRecapView: Bool = false
    @State private var selectedSection: Section? = nil
    @State private var headerHeight: CGFloat = 0
    
    let topic: Topic
    var topicCategory: TopicCategoryItem {
        return TopicCategoryItem.fromFullName(topic.topicCategory) ?? .work
    }
  
    var body: some View {
        
        NavigationStack {
            ZStack {
                
                VStack {
                    switch selectedTab {
                        
                    case .paths:
                        FocusAreasView(topicViewModel: topicViewModel, showUpdateTopicView: $showUpdateTopicView, showSectionRecapView: $showSectionRecapView, selectedSection: $selectedSection, topicId: topic.topicId, selectedCategory: topicCategory)
                        
                    case .entries:
                        EntriesListView(transcriptionViewModel: transcriptionViewModel, selectedEntry: $selectedEntry, showRecordingView: $showRecordingView, topicId: topic.topicId)
                            .padding(.horizontal)
                        
                    case .insights:
                        InsightsListView(selectedEntry: $selectedEntry, topicId: topic.topicId)
                            .padding(.horizontal)
                    }
                    
                    Spacer()
                    
                }
                .padding(.top, headerHeight)
   
                VStack {
                    TopicDetailViewHeader(title: topic.topicTitle)
                        .background {
                            GeometryReader { geo in
                                Color.clear
                                    .onAppear {
                                        let calculatedHeight = geo.size.height
                                        headerHeight = calculatedHeight + 10
                                    }
                            }
                        }
                    
                    Spacer()
                    
                    TopicDetailViewFooter(transcriptionViewModel: transcriptionViewModel, selectedTab: $selectedTab, topicId: topic.topicId)
                        .transition(.opacity)
                }
                .ignoresSafeArea(edges: .bottom)
                
            }//ZStack
            .overlay {
                if let showingUpdateTopicView = showUpdateTopicView, showingUpdateTopicView {
                    UpdateTopicView(topicViewModel: topicViewModel, showUpdateTopicView: $showUpdateTopicView, selectedCategory: topicCategory, topicId: topic.topicId, section: selectedSection)
                } else if showSectionRecapView {
                    FocusAreaRecapView(topicViewModel: topicViewModel, showSectionRecapView: $showSectionRecapView, topicId: topic.topicId, selectedCategory: topicCategory)
                }
            }
            .sheet(isPresented: $showRecordingView, onDismiss: {
                showRecordingView = false
            }){
                RecordingView(transcriptionViewModel: transcriptionViewModel, categoryEmoji: topicCategory.getCategoryEmoji(), topic: topic)
                    .presentationCornerRadius(20)
                    .presentationDetents([.fraction(0.75)])
                    .presentationBackground {
                        Color.clear
                            .background(.ultraThinMaterial)
                            .environment(\.colorScheme, .dark)
                    }
                
            }
            .sheet(item: $selectedEntry, onDismiss: {
                selectedEntry = nil
            }) { entry in
                EntryDetailView(entry: entry)
                    .presentationCornerRadius(20)
                    .presentationBackground(Color.black)
            }
            .onChange(of: topicViewModel.updatedEntry) {
                if let newEntry = topicViewModel.updatedEntry {
                    if showRecordingView {
                        showRecordingView = false
                    }
                    selectedEntry = newEntry
                }
            }
            .toolbarVisibility(((showUpdateTopicView ?? false) || showSectionRecapView) ? .hidden : .automatic)
            .navigationBarTitleDisplayMode(.inline)
        }//NavigationStack
     
    }
}





//#Preview {
//    TopicDetailView(selectedCategory: .work)
//}
