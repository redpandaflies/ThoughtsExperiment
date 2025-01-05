//
//  FocusAreaView.swift
//  Fearless2
//
//  Created by Yue Deng-Wu on 11/3/24.
//
import CoreData
import SwiftUI

struct FocusAreasView: View {
    @ObservedObject var topicViewModel: TopicViewModel
    @State private var selectedTab: Int = 0
    
    @Binding var showFocusAreaRecapView: Bool
    @Binding var selectedSection: Section?
    @Binding var selectedSectionSummary: SectionSummary?
    @Binding var selectedFocusArea: FocusArea?
    @Binding var focusAreaScrollPosition: Int?
    
    let topicId: UUID
  
    let screenHeight = UIScreen.current.bounds.height
    
    @FetchRequest var focusAreas: FetchedResults<FocusArea>
    
    init(topicViewModel: TopicViewModel, showFocusAreaRecapView: Binding<Bool>, selectedSection: Binding<Section?>, selectedSectionSummary: Binding<SectionSummary?>, selectedFocusArea: Binding<FocusArea?>, focusAreaScrollPosition: Binding<Int?>, topicId: UUID) {
        self.topicViewModel = topicViewModel
        self._showFocusAreaRecapView = showFocusAreaRecapView
        self._selectedSection = selectedSection
        self._selectedSectionSummary = selectedSectionSummary
        self._selectedFocusArea = selectedFocusArea
        self._focusAreaScrollPosition = focusAreaScrollPosition
        self.topicId = topicId
        
        let request: NSFetchRequest<FocusArea> = FocusArea.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: "createdAt", ascending: true)]
        request.predicate = NSPredicate(format: "topic.id == %@", topicId as CVarArg)
        
        self._focusAreas = FetchRequest(fetchRequest: request)
        
    }
    
    var body: some View {
        
        VStack {
            switch selectedTab {
            case 0:
                FocusAreaEmptyState(topicViewModel: topicViewModel, selectedTab: $selectedTab, topicId: topicId)
            default:
                FocusAreaList(topicViewModel: topicViewModel, showFocusAreaRecapView: $showFocusAreaRecapView, selectedSection: $selectedSection, selectedSectionSummary: $selectedSectionSummary, selectedFocusArea: $selectedFocusArea, focusAreaScrollPosition: $focusAreaScrollPosition, focusAreas: focusAreas)
                
                
            }
        }
        .ignoresSafeArea(.keyboard)
        .onAppear {
            if !focusAreas.isEmpty {
                selectedTab = 1
            }
        }
    }
    
}


struct FocusAreaList: View {
    @EnvironmentObject var dataController: DataController
   @ObservedObject var topicViewModel: TopicViewModel
    @State private var scrollViewHeight: CGFloat = 0
   
   @Binding var showFocusAreaRecapView: Bool
   @Binding var selectedSection: Section?
    @Binding var selectedSectionSummary: SectionSummary?
    @Binding var selectedFocusArea: FocusArea?
    @Binding var focusAreaScrollPosition: Int?
       
    let focusAreas: FetchedResults<FocusArea>
    let screenHeight = UIScreen.current.bounds.height
    
    var body: some View {
        ScrollView (showsIndicators: false) {
            VStack (alignment: .leading) {
                ForEach(Array(focusAreas.enumerated()), id: \.element.focusAreaId) { index, area in
                    
                    FocusAreaBox(topicViewModel: topicViewModel, showFocusAreaRecapView: $showFocusAreaRecapView, selectedSection: $selectedSection, selectedSectionSummary: $selectedSectionSummary, selectedFocusArea: $selectedFocusArea, focusArea: area, index: index)
                        .id(index)
                        .containerRelativeFrame(.vertical, alignment: .top)
                        .scrollTransition { content, phase in
                            content
                            .opacity(phase.isIdentity ? 1 : 0)
                            .scaleEffect(phase.isIdentity ? 1 : 0.8)
                            .blur(radius: phase.isIdentity ? 0 : 30)
                        }
                    
                }//ForEach
            }//VStack
            
        }//ScrollView
        .frame(height: screenHeight * 0.6)
        .scrollPosition(id: $focusAreaScrollPosition)
        .scrollTargetLayout()
        .scrollTargetBehavior(.paging)
        .scrollBounceBehavior(.basedOnSize)
        .scrollClipDisabled(true)
        .contentMargins(.vertical, 10, for: .scrollContent)
        .onChange(of: dataController.newFocusArea) {
            focusAreaScrollPosition = dataController.newFocusArea
        }
        .onAppear {
            focusAreaScrollPosition = focusAreas.count - 1
        }
    }
}


//#Preview {
//    FocusAreaView()
//}
