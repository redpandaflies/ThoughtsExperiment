//
//  FocusAreaView.swift
//  Fearless2
//
//  Created by Yue Deng-Wu on 11/3/24.
//
import CoreData
import SwiftUI

struct FocusAreaView: View {
    @ObservedObject var topicViewModel: TopicViewModel
    
    @Binding var showUpdateTopicView: Bool?
    @Binding var showSectionRecapView: Bool
    @Binding var selectedCategory: TopicCategoryItem
    @Binding var selectedSection: Section?
    let topicId: UUID?
    
    @FetchRequest var focusAreas: FetchedResults<FocusArea>
    
    init(topicViewModel: TopicViewModel, showUpdateTopicView: Binding<Bool?>, showSectionRecapView: Binding<Bool>, selectedCategory: Binding<TopicCategoryItem>, selectedSection: Binding<Section?>, topicId: UUID?) {
        self.topicViewModel = topicViewModel
        self._showUpdateTopicView = showUpdateTopicView
        self._showSectionRecapView = showSectionRecapView
        self._selectedCategory = selectedCategory
        self._selectedSection = selectedSection
        self.topicId = topicId
        
        let request: NSFetchRequest<FocusArea> = FocusArea.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: "createdAt", ascending: false)]
        if let currentTopicId = topicId {
            request.predicate = NSPredicate(format: "topic.id == %@", currentTopicId as CVarArg)
        }
        self._focusAreas = FetchRequest(fetchRequest: request)
    }
    
    var body: some View {
        
        ForEach(Array(focusAreas.enumerated()), id: \.element.focusAreaId) { index, area in
            VStack (alignment: .leading) {
                Text("\(index + 1)")
                    .multilineTextAlignment(.leading)
                    .font(.system(size: 30))
                    .fontWeight(.regular)
                    .foregroundStyle(selectedCategory.getBubbleColor())
                    
                Text(area.focusAreaTitle)
                    .multilineTextAlignment(.leading)
                    .font(.system(size: 25))
                    .fontWeight(.regular)
                    .foregroundStyle(AppColors.blackDefault)
                    
                
                Text(area.focusAreaReasoning)
                    .multilineTextAlignment(.leading)
                    .font(.system(size: 16))
                    .fontWeight(.regular)
                    .foregroundStyle(AppColors.blackDefault)
                    .opacity(0.7)
                
                SectionListView(showUpdateTopicView: $showUpdateTopicView, showSectionRecapView: $showSectionRecapView, selectedCategory: $selectedCategory, selectedSection: $selectedSection, sections: area.focusAreaSections)
                
            }//VStack
        }
        
        
    }
}

//#Preview {
//    FocusAreaView()
//}
