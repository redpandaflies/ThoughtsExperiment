//
//  TopicDetailView.swift
//  Fearless2
//
//  Created by Yue Deng-Wu on 11/12/24.
//
import CoreData
import Mixpanel
import SwiftUI

struct TopicDetailView: View {
    @EnvironmentObject var dataController: DataController
    @ObservedObject var topicViewModel: TopicViewModel

    @State private var showRecordingView: Bool = false
    @State private var selectedEntry: Entry? = nil
    @State private var showFocusAreaRecapView: Bool = false
    @State private var selectedSection: Section? = nil
    @State private var selectedSectionSummary: SectionSummary? = nil
    @State private var selectedFocusArea: FocusArea? = nil
    @State private var selectedEndOfTopicSection: Section? = nil
    @State private var headerHeight: CGFloat = 0
    @State private var focusAreaScrollPosition: Int?
    @State private var showLaurelInfoSheet: Bool = false
    @State private var showInfoNotifications: Bool = false
    
    @Binding var selectedTabTopic: TopicPickerItem
    
    let topic: Topic
    let points: Int
    let screenWidth = UIScreen.current.bounds.width
    
    var body: some View {
        
//        NavigationStack {
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
                    TopicDetailViewHeader(topic: topic)
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
                //show notifications sheet
//                if !seenNotificationsInfoSheet {
//                    showInfoNotifications = true
//                }
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    let seenNotificationsInfoSheet = UserDefaults.standard.bool(forKey: "seenNotificationsInfoSheet")
                    
                    if !seenNotificationsInfoSheet {
                        showInfoNotifications = true
                    }
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
            .toolbar {
               
                ToolbarItem(placement: .principal) {
                    ToolbarTitleItemIcon(icon: topic.category?.categoryEmoji ?? "")
                }
                
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showLaurelInfoSheet = true
                        
                        DispatchQueue.global(qos: .background).async {
                            Mixpanel.mainInstance().track(event: "Tapped laurel counter")
                        }
                    } label: {
                        LaurelItem(size: 15, points: "\(points)")
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackgroundVisibility(.hidden)
//            .accentColor(AppColors.textPrimary)
//        }//NavigationStack
//        .tint(AppColors.textPrimary)
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
            FocusAreaRecapView(topicViewModel: topicViewModel, focusArea: $selectedFocusArea, focusAreaScrollPosition: $focusAreaScrollPosition, topic: topic)
                .presentationCornerRadius(20)
                .presentationBackground(AppColors.black4)
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
        .sheet(isPresented: $showInfoNotifications, onDismiss: {
            showInfoNotifications = false
        }) {
            
            InfoNotifications(backgroundColor: getCategoryBackground())
                .presentationDetents([.fraction(0.90)])
                .presentationCornerRadius(30)
                .interactiveDismissDisabled()
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
        return focusAreas.filter { $0.focusAreaStatus == FocusAreaStatusItem.completed.rawValue }.count
    }
    
    private func getCategoryBackground() -> Color {
        if let category = topic.category {
            return Realm.getBackgroundColor(forName: category.categoryName)
        }
        
        return AppColors.backgroundCareer
    }
    
}





//#Preview {
//    TopicDetailView(selectedCategory: .work)
//}
