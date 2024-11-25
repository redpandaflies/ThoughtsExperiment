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
   
    @Binding var showUpdateTopicView: Bool?
    @Binding var showSectionRecapView: Bool
    @Binding var selectedSection: Section?
    
    let topicId: UUID
    let selectedCategory: TopicCategoryItem
    let screenHeight = UIScreen.current.bounds.height
    
    @FetchRequest var focusAreas: FetchedResults<FocusArea>
    
    init(topicViewModel: TopicViewModel, showUpdateTopicView: Binding<Bool?>, showSectionRecapView: Binding<Bool>, selectedSection: Binding<Section?>, topicId: UUID, selectedCategory: TopicCategoryItem) {
        self.topicViewModel = topicViewModel
        self._showUpdateTopicView = showUpdateTopicView
        self._showSectionRecapView = showSectionRecapView
        self._selectedSection = selectedSection
        self.topicId = topicId
        self.selectedCategory = selectedCategory
        
        let request: NSFetchRequest<FocusArea> = FocusArea.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: "createdAt", ascending: true)]
        request.predicate = NSPredicate(format: "topic.id == %@", topicId as CVarArg)
        
        self._focusAreas = FetchRequest(fetchRequest: request)
        
    }
    
    var body: some View {
       
            ScrollView (showsIndicators: false) {
                VStack (alignment: .leading) {
                    ForEach(Array(focusAreas.enumerated()), id: \.element.focusAreaId) { index, area in
                        
                        FocusAreaBox(showUpdateTopicView: $showUpdateTopicView, showSectionRecapView: $showSectionRecapView, selectedSection: $selectedSection, focusArea: area, index: index)
                            .containerRelativeFrame(.vertical, alignment: .top)
                            .scrollTransition { content, phase in
                                content
                                .opacity(phase.isIdentity ? 1 : 0)
                                .scaleEffect(phase.isIdentity ? 1 : 0.8)
                                .blur(radius: phase.isIdentity ? 0 : 10)
                            }
                        
                    }//ForEach
                }//VStack
            }//ScrollView
            .scrollTargetLayout()
            .scrollTargetBehavior(.paging)
            .scrollBounceBehavior(.basedOnSize)
            .scrollClipDisabled(true)
            .ignoresSafeArea(.keyboard)
            .onAppear {
                if !focusAreas.isEmpty {
                   //tbd
                }
            }
//            .onChange(of: topicViewModel.topicUpdated) {
//                if topicViewModel.topicUpdated {
//                    selectedTab = 2
//                }
//            }
  
        
    }
    
}



//#Preview {
//    FocusAreaView()
//}
