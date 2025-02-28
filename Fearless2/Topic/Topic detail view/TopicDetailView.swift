//
//  TopicDetailView.swift
//  Fearless2
//
//  Created by Yue Deng-Wu on 11/12/24.
//

import SwiftUI

struct TopicDetailView: View {
    @EnvironmentObject var dataController: DataController
    @ObservedObject var topicViewModel: TopicViewModel
    @ObservedObject var transcriptionViewModel: TranscriptionViewModel
  
    @State private var showRecordingView: Bool = false
    @State private var selectedEntry: Entry? = nil
    @State private var showFocusAreaRecapView: Bool = false
    @State private var selectedSection: Section? = nil
    @State private var selectedSectionSummary: SectionSummary? = nil
    @State private var selectedFocusArea: FocusArea? = nil
    @State private var selectedEndOfTopicSection: Section? = nil
    @State private var headerHeight: CGFloat = 0
    @State private var focusAreaScrollPosition: Int?
    
    @Binding var selectedTabTopic: TopicPickerItem
    
    let topic: Topic
    @ObservedObject var points: Points
    let focusAreasLimit: Int
    let screenWidth = UIScreen.current.bounds.width
    
    init(topicViewModel: TopicViewModel, transcriptionViewModel: TranscriptionViewModel, selectedTabTopic: Binding<TopicPickerItem>, topic: Topic, points: Points, focusAreasLimit: Int) {
        self.topicViewModel = topicViewModel
        self.transcriptionViewModel = transcriptionViewModel
        self._selectedTabTopic = selectedTabTopic
        self.topic = topic
        self.points = points
        self.focusAreasLimit = focusAreasLimit
        
    }
    
    var body: some View {
        
        NavigationStack {
            ZStack {
                
                VStack {
                    switch selectedTabTopic {
                        
                    case .paths:
                        FocusAreasView(topicViewModel: topicViewModel, showFocusAreaRecapView: $showFocusAreaRecapView, selectedSection: $selectedSection, selectedSectionSummary: $selectedSectionSummary, selectedFocusArea: $selectedFocusArea, focusAreaScrollPosition: $focusAreaScrollPosition, selectedEndOfTopicSection: $selectedEndOfTopicSection, topicId: topic.topicId)
                        
                    case .chronicles:
                        TopicChroniclesView(focusAreas: topic.topicFocusAreas)
                            .padding(.top)
                            
                    }
                    
                    Spacer()
                    
                }
                .padding(.top, headerHeight - 30)
                
                
                VStack {
                    TopicDetailViewHeader(title: topic.topicTitle, progress: topic.topicFocusAreas.count, focusAreasLimit: focusAreasLimit, topic: topic)
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
                    
                }
                .padding(.bottom)
                
            }//ZStack
            .background {
                if let category = topic.category {
                    BackgroundPrimary(backgroundColor: Realm.getBackgroundColor(forName: category.categoryName))
                } else {
                    BackgroundPrimary(backgroundColor: AppColors.backgroundCareer)
                }
            }
            .onAppear {
                withAnimation(.snappy(duration: 0.2)) {
                    selectedTabTopic = .paths
                }
               
            }
            .fullScreenCover(item: $selectedSection, onDismiss: {
                selectedSection = nil
            }) { section in
                UpdateSectionView(topicViewModel: topicViewModel, selectedSectionSummary: $selectedSectionSummary, topicId: topic.topicId, focusArea: section.focusArea, section: section)
            }
            .fullScreenCover(item: $selectedEndOfTopicSection, onDismiss: {
                selectedEndOfTopicSection = nil
            }) { section in
                EndTopicView(topicViewModel: topicViewModel, section: $selectedEndOfTopicSection, topic: topic)
            }
            .fullScreenCover(isPresented: $showFocusAreaRecapView, onDismiss: {
                showFocusAreaRecapView = false
            }) {
                FocusAreaRecapView(topicViewModel: topicViewModel, focusArea: $selectedFocusArea, focusAreaScrollPosition: $focusAreaScrollPosition, totalFocusAreas: topic.topicFocusAreas.count, focusAreasLimit: focusAreasLimit)
                    .presentationCornerRadius(20)
                    .presentationBackground(AppColors.black4)
            }
            .onChange(of: topicViewModel.updatedEntry) {
                if let newEntry = topicViewModel.updatedEntry {
                    if showRecordingView {
                        showRecordingView = false
                    }
                    selectedEntry = newEntry
                }
            }
            .toolbar {
               
                ToolbarItem(placement: .principal) {
                    ToolbarTitleItem(title: topic.category?.categoryEmoji ?? "", largerFont: true)
                }
                
                ToolbarItem(placement: .topBarTrailing) {
                    LaurelItem(size: 15, points: "\(Int(points.total))")
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackgroundVisibility(.hidden)
            .accentColor(AppColors.textPrimary)
        }//NavigationStack
        .tint(AppColors.textPrimary)

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
                        Image("placeholder")
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
    
    private func getFocusAreasCompleted() -> Int? {
        let focusAreas = topic.topicFocusAreas
        return focusAreas.filter { $0.completed }.count
    }
    
}





//#Preview {
//    TopicDetailView(selectedCategory: .work)
//}
