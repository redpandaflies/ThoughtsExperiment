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
    @State private var selectedTab: TopicPickerItem = .insights
    @State private var showRecordingView: Bool = false
    @State private var selectedEntry: Entry? = nil
    @State private var showUpdateTopicView: Bool? = nil
    @State private var showSectionRecapView: Bool = false
    @State private var selectedSection: Section? = nil
    
    let topic: Topic
    var topicCategory: TopicCategoryItem {
        return TopicCategoryItem.fromFullName(topic.topicCategory) ?? .work
    }
   
    
    var body: some View {
        
        NavigationStack {
            ZStack {
                
                ScrollView (showsIndicators: false) {
                    
                    VStack (spacing: 10){
                        
                        Group {
                            Image(systemName: topicCategory.getCategoryEmoji())
                                .font(.system(size: 20))
                                .foregroundStyle(AppColors.whiteDefault)
                                .symbolRenderingMode(.monochrome)
                            
                            
                            Text(topic.topicTitle)
                                .font(.system(size: 20))
                                .foregroundStyle(AppColors.whiteDefault)
                            
                            Text("I’m focused on building a product that aligns with my values and creates real, meaningful progress for users.")
                                .font(.system(size: 14))
                                .foregroundStyle(AppColors.topicSubtitle)
                                .opacity(0.6)
                                .padding(.bottom)
                            
                            Divider()
                                .overlay(topicCategory.getDividerColor())
                            
                            TopicPickerView(selectedTab: $selectedTab, selectedCategory: topicCategory)
                        }
                        .padding(.horizontal)
                        
                        switch selectedTab {
                        case .insights:
                            InsightsListView(selectedEntry: $selectedEntry, topicId: topic.topicId)
                                .padding(.horizontal)
                        case .paths:
                            FocusAreasView(topicViewModel: topicViewModel, showUpdateTopicView: $showUpdateTopicView, showSectionRecapView: $showSectionRecapView, selectedSection: $selectedSection, topicId: topic.topicId, selectedCategory: topicCategory)
                               
                        case .entries:
                            EntriesListView(selectedEntry: $selectedEntry, topicId: topic.topicId)
                                .padding(.horizontal)
                        }

                    }//VStack
                }
                .scrollClipDisabled(true)
                .safeAreaInset(edge: .top, content: {
                    Rectangle()
                        .fill(Color.clear)
                        .frame(height: ((showUpdateTopicView ?? false) || showSectionRecapView) ? 50 : 0)
                })
        
                TopicDetailViewFooter(transcriptionViewModel: transcriptionViewModel, showRecordingView: $showRecordingView, topicId: topic.topicId)
                    .transition(.opacity)
                
            }//ZStack
            .overlay {
                if let showingUpdateTopicView = showUpdateTopicView, showingUpdateTopicView {
                    UpdateTopicView(topicViewModel: topicViewModel, showUpdateTopicView: $showUpdateTopicView, selectedCategory: topicCategory, topicId: topic.topicId, section: selectedSection)
                } else if showSectionRecapView {
                    SectionRecapView(topicViewModel: topicViewModel, showSectionRecapView: $showSectionRecapView, topicId: topic.topicId, selectedCategory: topicCategory)
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
            .toolbarBackground(Color.black)
            .toolbarVisibility(((showUpdateTopicView ?? false) || showSectionRecapView) ? .hidden : .automatic)
        }//NavigationStack
       
    }
}





//#Preview {
//    TopicDetailView(selectedCategory: .work)
//}
