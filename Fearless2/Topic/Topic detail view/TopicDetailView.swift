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
    @State private var showFocusAreaRecapView: Bool = false
    @State private var selectedSection: Section? = nil
    @State private var selectedSectionSummary: SectionSummary? = nil
    @State private var selectedFocusArea: FocusArea? = nil
    @State private var headerHeight: CGFloat = 0
    @State private var focusAreaScrollPosition: Int?
    
    @Binding var selectedTabTopic: TopicPickerItem
    
    let topic: Topic
    var topicCategory: TopicCategoryItem {
        return TopicCategoryItem.fromFullName(topic.topicCategory) ?? .work
    }
  
    let screenWidth = UIScreen.current.bounds.width
    
    var body: some View {
        
        NavigationStack {
            ZStack {
//                if selectedTabTopic == .explore {
//                    backgroundImage()
//                }
                
                VStack {
                    switch selectedTabTopic {
                        
                    case .explore:
                        FocusAreasView(topicViewModel: topicViewModel, showFocusAreaRecapView: $showFocusAreaRecapView, selectedSection: $selectedSection, selectedSectionSummary: $selectedSectionSummary, selectedFocusArea: $selectedFocusArea, focusAreaScrollPosition: $focusAreaScrollPosition, topicId: topic.topicId)
                        
                    case .review:
                        TopicReviewView(topicId: topic.topicId)
                            .padding(.horizontal)
                            
                    }
                    
                    Spacer()
                    
                }
                .padding(.top, (selectedTabTopic == .explore) ? headerHeight : (headerHeight - 20))
                
                if selectedTabTopic == .review {
                    headerBackground2()
                    headerBackground()
                }
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
            .background(AppColors.black4)
            .fullScreenCover(item: $selectedSection, onDismiss: {
                selectedSection = nil
            }) { section in
                UpdateSectionView(topicViewModel: topicViewModel, selectedSectionSummary: $selectedSectionSummary, topicId: topic.topicId, focusArea: section.focusArea, section: section)
                    .presentationBackground(AppColors.black4)
            }
//            .sheet(isPresented: $showRecordingView, onDismiss: {
//                showRecordingView = false
//            }){
//                RecordingView(transcriptionViewModel: transcriptionViewModel, categoryEmoji: topicCategory.getCategoryEmoji(), topic: topic)
//                    .presentationCornerRadius(20)
//                    .presentationDetents([.fraction(0.75)])
//                    .presentationBackground(AppColors.black3)
//                
//            }
//            .sheet(item: $selectedEntry, onDismiss: {
//                selectedEntry = nil
//            }) { entry in
//                EntryDetailView(entry: entry)
//                    .presentationCornerRadius(20)
//                    .presentationBackground(Color.black)
//            }
//            .sheet(item: $selectedSectionSummary, onDismiss: {
//                selectedSectionSummary = nil
//            }) { summary in
//                SectionSummaryView(summary: summary)
//                    .presentationCornerRadius(20)
//                    .presentationBackground(Color.black)
//            }
            .fullScreenCover(isPresented: $showFocusAreaRecapView, onDismiss: {
                showFocusAreaRecapView = false
            }) {
                FocusAreaRecapView(topicViewModel: topicViewModel, focusArea: $selectedFocusArea, lastFocusArea: lastFocusArea())
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
    
    private func nextIndicator() -> some View {
        VStack (alignment: .center, spacing: 10){
            Text("Next")
                .font(.caption)
                .fontWeight(.regular)
                .foregroundStyle(AppColors.whiteDefault)
                .opacity(0.7)
            
            
            Image(systemName: "chevron.compact.down")
                .font(.largeTitle)
                .fontWeight(.regular)
                .foregroundStyle(AppColors.whiteDefault)
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
    
    private func headerBackground() -> some View {
        VStack {
            
            Rectangle()
                .fill(
                    LinearGradient(
                        stops: [
                            Gradient.Stop(color: Color.black, location: 0.70),
                            Gradient.Stop(color: Color.black.opacity(0.1), location: 1.0)
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .blur(radius: 3)
                .frame(width: screenWidth, height: headerHeight)
            
            Spacer()
            
        }
        .ignoresSafeArea(edges: .top)
    }
    
    private func headerBackground2() -> some View {
        VStack {
            
            Rectangle()
                .fill(Color.black)
                .frame(width: screenWidth, height: 20)
            
            Spacer()
            
        }
        .ignoresSafeArea(edges: .top)
    }
    
    private func lastFocusArea() -> Bool {
        let totalFocusAreas = topic.topicFocusAreas.count
        print("Current scroll position: \(String(describing: focusAreaScrollPosition))")
        
        if focusAreaScrollPosition != nil {
            return focusAreaScrollPosition == totalFocusAreas - 1
        } else {
            return true
        }
    }
    
}





//#Preview {
//    TopicDetailView(selectedCategory: .work)
//}
