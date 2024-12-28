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
  
    @State private var showRecordingView: Bool = false
    @State private var selectedEntry: Entry? = nil
    @State private var showUpdateSectionView: Bool? = nil
    @State private var showFocusAreaRecapView: Bool = false
    @State private var selectedSection: Section? = nil
    @State private var selectedSectionSummary: SectionSummary? = nil
    @State private var selectedFocusArea: FocusArea? = nil
    @State private var selectedFocusAreaSummary: FocusAreaSummary? = nil
    @State private var headerHeight: CGFloat = 0
    @State private var focusAreaScrollPosition: Int?
    
    @Binding var showTabBar: Bool
    @Binding var selectedTabTopic: TopicPickerItem
    
    let topic: Topic
    var topicCategory: TopicCategoryItem {
        return TopicCategoryItem.fromFullName(topic.topicCategory) ?? .work
    }
  
    var body: some View {
        
        NavigationStack {
            ZStack {
                
                backgroundImage()
                
                
                VStack {
                    switch selectedTabTopic {
                        
                    case .paths:
                        FocusAreasView(topicViewModel: topicViewModel, showUpdateSectionView: $showUpdateSectionView, showFocusAreaRecapView: $showFocusAreaRecapView, selectedSection: $selectedSection, selectedSectionSummary: $selectedSectionSummary, selectedFocusArea: $selectedFocusArea, selectedFocusAreaSummary: $selectedFocusAreaSummary, focusAreaScrollPosition: $focusAreaScrollPosition, topicId: topic.topicId)
                        
                    case .entries:
                        EntriesListView(transcriptionViewModel: transcriptionViewModel, selectedEntry: $selectedEntry, showRecordingView: $showRecordingView, topicId: topic.topicId)
                            .padding(.horizontal)
                            .padding(.top, 90)
                        
                    case .insights:
                        InsightsListView(selectedEntry: $selectedEntry, topicId: topic.topicId)
                            .padding(.horizontal)
                            .padding(.top, 90)
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
                                        headerHeight = calculatedHeight + 70
                                    }
                            }
                        }
                    
                    Spacer()
                    
                    if (topic.topicFocusAreas.count > 1) && (focusAreaScrollPosition != topic.topicFocusAreas.count - 1) {
                        nextIndicator()
                            .onTapGesture {
                                getNewScrollPosition()
                            }
                    }
                    
                }
                .padding(.bottom)
                
            }//ZStack
            .overlay {
                if let showingUpdateSectionView = showUpdateSectionView, showingUpdateSectionView {
                    UpdateSectionView(topicViewModel: topicViewModel, showUpdateSectionView: $showUpdateSectionView, selectedSectionSummary: $selectedSectionSummary, topicId: topic.topicId, section: selectedSection)
                }
            }
            .sheet(isPresented: $showRecordingView, onDismiss: {
                showRecordingView = false
            }){
                RecordingView(transcriptionViewModel: transcriptionViewModel, categoryEmoji: topicCategory.getCategoryEmoji(), topic: topic)
                    .presentationCornerRadius(20)
                    .presentationDetents([.fraction(0.75)])
                    .presentationBackground(AppColors.black3)
                
            }
            .sheet(item: $selectedEntry, onDismiss: {
                selectedEntry = nil
            }) { entry in
                EntryDetailView(entry: entry)
                    .presentationCornerRadius(20)
                    .presentationBackground(Color.black)
            }
            .sheet(item: $selectedSectionSummary, onDismiss: {
                selectedSectionSummary = nil
            }) { summary in
                SectionSummaryView(summary: summary)
                    .presentationCornerRadius(20)
                    .presentationBackground(Color.black)
            }
            .sheet(isPresented: $showFocusAreaRecapView, onDismiss: {
                showFocusAreaRecapView = false
            }) {
                FocusAreaRecapView(topicViewModel: topicViewModel, selectedFocusAreaSummary: $selectedFocusAreaSummary, focusArea: $selectedFocusArea)
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
            .onChange(of: showUpdateSectionView) {
                if showUpdateSectionView == true {
                    withAnimation(.snappy(duration: 0.1)) {
                        showTabBar = false
                    }
                } else {
                    withAnimation(.snappy(duration: 0.1)) {
                        showTabBar = true
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbarVisibility(.hidden, for: .navigationBar)
        }//NavigationStack
     
    }
    
    private func backgroundImage() -> some View {
        VStack {
            
            Group {
                Circle()
                    .stroke(Color.black)
                    .fill(
                        RadialGradient(
                            gradient: Gradient(stops: [
                                .init(color: .black.opacity(0), location: 0.0),
                                .init(color: .black, location: 0.87),
                            ]),
                            center: UnitPoint(x: 0.5, y: 0.2),
                            startRadius: 0,
                            endRadius: 300
                        )
                    )
                    .background {
                        Image("topicPlaceholder1")
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .opacity(0.5)
                            
                            .clipShape(Circle())
                    }
            }
            .scaleEffect(1.2)
            .offset(y: -100)
        
            Spacer()
           
        }
        .ignoresSafeArea(.all)
    }
    
    private func nextIndicator() -> some View {
        VStack (alignment: .center, spacing: 10){
            Text("Next")
                .font(.caption)
                .fontWeight(.regular)
                .foregroundStyle(Color.white)
                .opacity(0.7)
            
            
            Image(systemName: "chevron.compact.down")
                .font(.largeTitle)
                .fontWeight(.regular)
                .foregroundStyle(Color.white)
                .opacity(0.7)
            
        }
        .contentShape(Rectangle())
    }
    
    private func getNewScrollPosition() {
        if let currentScrollPosition = focusAreaScrollPosition {
            let newScrollPosition = currentScrollPosition + 1
            focusAreaScrollPosition = newScrollPosition
        }
    }
}





//#Preview {
//    TopicDetailView(selectedCategory: .work)
//}
