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
   
    @Binding var showFocusAreasView: Bool
    @State private var showUpdateTopicView: Bool? = nil
    @State private var showSectionRecapView: Bool = false
    @State private var selectedSection: Section? = nil
    @Binding var selectedCategory: TopicCategoryItem
 
    let topicId: UUID?
    
    @FetchRequest var focusAreas: FetchedResults<FocusArea>
    
    init(topicViewModel: TopicViewModel, showFocusAreasView: Binding<Bool>, selectedCategory: Binding<TopicCategoryItem>, topicId: UUID?) {
        self.topicViewModel = topicViewModel
        self._showFocusAreasView = showFocusAreasView
        self._selectedCategory = selectedCategory
        self.topicId = topicId
        
        let request: NSFetchRequest<FocusArea> = FocusArea.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: "createdAt", ascending: false)]
        if let currentTopicId = topicId {
            request.predicate = NSPredicate(format: "topic.id == %@", currentTopicId as CVarArg)
        }
        self._focusAreas = FetchRequest(fetchRequest: request)
    }
    
    var body: some View {
       
            ZStack {
                ScrollView (showsIndicators: false) {
                    VStack (alignment: .leading) {
                        ForEach(Array(focusAreas.enumerated()), id: \.element.focusAreaId) { index, area in
                            
                            FocusAreaBox(showUpdateTopicView: $showUpdateTopicView, showSectionRecapView: $showSectionRecapView, selectedCategory: $selectedCategory, selectedSection: $selectedSection, focusArea: area, index: index)
                                .padding(.bottom, 20)
                            
                        }//ForEach
                    }//VStack
                }//ScrollView
                .padding()
                .scrollClipDisabled(true)
                .safeAreaInset(edge: .top, content: {
                    Rectangle()
                        .foregroundStyle(.clear)
                        .frame(height: 80)
                })
                .safeAreaInset(edge: .bottom, content: {
                    Rectangle()
                        .foregroundStyle(.clear)
                        .frame(height: 40)
                })
                
                VStack {
                    FocusAreaHeader(showFocusAreasView: $showFocusAreasView, topicId: topicId)
                    
                    Spacer()
                }
                .ignoresSafeArea(.all)
                
            }
            .ignoresSafeArea(.all)
            .ignoresSafeArea(.keyboard)
            .background {
                Color.black
                  .ignoresSafeArea()
            }
            .overlay {
                if let showingUpdateTopicView = showUpdateTopicView, showingUpdateTopicView {
                    UpdateTopicView(topicViewModel: topicViewModel, showUpdateTopicView: $showUpdateTopicView, selectedCategory: selectedCategory, topicId: topicId, section: selectedSection)
                } else if showSectionRecapView {
                    if let currentTopicId = topicId {
                        SectionRecapView(topicViewModel: topicViewModel, showSectionRecapView: $showSectionRecapView, topicId: currentTopicId, selectedCategory: selectedCategory)
                    }
                    
                }
            }
        
    }
}



//#Preview {
//    FocusAreaView()
//}
