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
    let topic: Topic
    var topicCategory: TopicCategoryItem {
        return TopicCategoryItem.fromFullName(topic.topicCategory) ?? .work
    }
   
    
    var body: some View {
        
        NavigationStack {
            ZStack {
                
                ScrollView (showsIndicators: false) {
                    
                    
                    VStack (spacing: 10){
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
                        
                        switch selectedTab {
                        case .insights:
                            EmptyView()
                        case .paths:
                            EmptyView()
                        case .entries:
                            EntriesListView(selectedEntry: $selectedEntry, topicId: topic.topicId)
                        }
                        
                        
                        
                    }//VStack
                }
                .scrollClipDisabled(true)
                .padding(.horizontal)
                
                TopicDetailViewFooter(transcriptionViewModel: transcriptionViewModel, showRecordingView: $showRecordingView, topicId: topic.topicId)
                    .transition(.opacity)
                
            }//ZStack
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
        }//NavigationStack
    }
}





//#Preview {
//    TopicDetailView(selectedCategory: .work)
//}
