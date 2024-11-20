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
                        
                        FocusAreaBox(showUpdateTopicView: $showUpdateTopicView, showSectionRecapView: $showSectionRecapView, selectedSection: $selectedSection, focusArea: area, selectedCategory: selectedCategory, index: index)
                            .padding(.bottom, 20)
                        
                    }//ForEach
                }//VStack
            }//ScrollView
            .padding(.vertical)
            .ignoresSafeArea(.keyboard)
            .safeAreaInset(edge: .bottom, content: {
                Rectangle()
                    .foregroundStyle(.clear)
                    .frame(height: 50)
            })
        
    }
}



//#Preview {
//    FocusAreaView()
//}
