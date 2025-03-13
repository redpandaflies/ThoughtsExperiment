//
//  TopicDetailView.swift
//  Fearless2
//
//  Created by Yue Deng-Wu on 11/12/24.
//
import CoreData
import CloudStorage
import Mixpanel
import SwiftUI

struct TopicDetailView: View {
    @EnvironmentObject var dataController: DataController
    @ObservedObject var topicViewModel: TopicViewModel
    @ObservedObject var transcriptionViewModel: TranscriptionViewModel
    @ObservedObject var points: Points
    
    @State private var showRecordingView: Bool = false
    @State private var selectedEntry: Entry? = nil
    @State private var showFocusAreaRecapView: Bool = false
    @State private var selectedSection: Section? = nil
    @State private var selectedSectionSummary: SectionSummary? = nil
    @State private var selectedFocusArea: FocusArea? = nil
    @State private var selectedEndOfTopicSection: Section? = nil
    @State private var headerHeight: CGFloat = 0
    @State private var focusAreaScrollPosition: Int?
    @State private var showTutorialFocusArea: Bool = false
    @State private var showInfoNewCategory: Bool = false
    @State private var showLaurelInfoSheet: Bool = false
    
    @Binding var selectedTabTopic: TopicPickerItem
    
    let topic: Topic
    let totalCategories: Int
    let screenWidth = UIScreen.current.bounds.width
    
    @FetchRequest(
        sortDescriptors: []
    ) var topics: FetchedResults<Topic>
    
    @CloudStorage("currentAppView") var currentAppView: Int = 0
    @CloudStorage("discoveredFirstFocusArea") var firstFocusArea: Bool = false
    @CloudStorage("unlockNewCategory") var unlockNewCategory: Int = 0
    
    init(topicViewModel: TopicViewModel, transcriptionViewModel: TranscriptionViewModel, selectedTabTopic: Binding<TopicPickerItem>, topic: Topic, points: Points, totalCategories: Int) {
        self.topicViewModel = topicViewModel
        self.transcriptionViewModel = transcriptionViewModel
        self._selectedTabTopic = selectedTabTopic
        self.topic = topic
        self.points = points
        self.totalCategories = totalCategories
        
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
                    TopicDetailViewHeader(title: topic.topicTitle, progress: topic.topicFocusAreas.count, topic: topic)
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
                
                //show sheet explaining the concept of focus areas(paths)
//                if !firstFocusArea {
//                    showTutorialFocusArea = true
//                }
                
            }
            .onChange(of: topicViewModel.updatedEntry) {
                if let newEntry = topicViewModel.updatedEntry {
                    if showRecordingView {
                        showRecordingView = false
                    }
                    selectedEntry = newEntry
                }
            }
            .onChange(of: selectedEndOfTopicSection) {
                if selectedEndOfTopicSection == nil {
                    print("Checking eligibility for new realm")
                    //show unlock category alert
                    let checker = NewCategoryEligibilityChecker()
                    showInfoNewCategory = checker.checkEligibility(topics: topics, totalCategories: totalCategories)
                    
                }
            }
            .toolbar {
               
                ToolbarItem(placement: .principal) {
                    ToolbarTitleItem(title: topic.category?.categoryEmoji ?? "", largerFont: true)
                }
                
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showLaurelInfoSheet = true
                        
                        DispatchQueue.global(qos: .background).async {
                            Mixpanel.mainInstance().track(event: "Tapped laurel counter")
                        }
                    } label: {
                        LaurelItem(size: 15, points: "\(Int(points.total))")
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackgroundVisibility(.hidden)
            .accentColor(AppColors.textPrimary)
        }//NavigationStack
        .tint(AppColors.textPrimary)
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
            FocusAreaRecapView(topicViewModel: topicViewModel, focusArea: $selectedFocusArea, focusAreaScrollPosition: $focusAreaScrollPosition, totalFocusAreas: topic.topicFocusAreas.count, focusAreasLimit: Int(topic.focusAreasLimit))
                .presentationCornerRadius(20)
                .presentationBackground(AppColors.black4)
        }
//        .sheet(isPresented: $showTutorialFocusArea, onDismiss: {
//            showTutorialFocusArea = false
//        }) {
//            InfoPrimaryView(
//                backgroundColor: getCategoryBackground(),
//                useIcon: true,
//                iconName: "point.bottomleft.forward.to.point.topright.filled.scurvepath",
//                titleText: "Each quest has a number of paths you need to explore",
//                descriptionText: "Paths are sets of questions designed to\nhelp you explore certain parts of your life.\nThey are unique to you.",
//                useRectangleButton: false,
//                buttonAction: {
//                    firstFocusArea = true
//                })
//                .presentationDetents([.fraction(0.65)])
//                .presentationCornerRadius(30)
//                .interactiveDismissDisabled()
//            
//        }
        .sheet(isPresented: $showInfoNewCategory, onDismiss: {
            showInfoNewCategory = false
        }) {
            InfoPrimaryView(
                backgroundColor: getCategoryBackground(),
                useIcon: true,
                iconName: "mountain.2.fill",
                titleText: "A new realm emerges",
                descriptionText: "The path ahead is shifting.\nStep forward and see where it leads.",
                useRectangleButton: true,
                rectangleButtonText: "Unveil your next realm",
                buttonAction: {
                    startNewRealmFlow()
                })
                .presentationDetents([.fraction(0.65)])
                .presentationCornerRadius(30)
        }
        .sheet(isPresented: $showLaurelInfoSheet, onDismiss: {
            showLaurelInfoSheet = false
        }) {
            
            InfoPrimaryView(
                backgroundColor: getCategoryBackground(),
                useIcon: false,
                titleText: "You earn laurels by exploring paths and completing quests.",
                descriptionText: "You’ll be able to use them to unlock new abilities.",
                useRectangleButton: false,
                buttonAction: {}
            )
                .presentationDetents([.fraction(0.65)])
                .presentationCornerRadius(30)
        }
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
    
    private func getCategoryBackground() -> Color {
        if let category = topic.category {
            return Realm.getBackgroundColor(forName: category.categoryName)
        }
        
        return AppColors.backgroundCareer
    }
    
    private func startNewRealmFlow() {
        
        withAnimation(.snappy(duration: 0.5)) {
            currentAppView = 2
        }
        
        DispatchQueue.global(qos: .background).async {
            Mixpanel.mainInstance().track(event: "Started unveiling a new realm")
        }
    }
    
}





//#Preview {
//    TopicDetailView(selectedCategory: .work)
//}
