//
//  TopicsListView.swift
//  Fearless2
//
//  Created by Yue Deng-Wu on 1/22/25.
//
import CoreData
import SwiftUI

enum TopicsList {
    case active
    case archived
}

struct TopicsListView: View {
    
    @ObservedObject var topicViewModel: TopicViewModel
    @ObservedObject var transcriptionViewModel: TranscriptionViewModel
    
    @State private var showSectionRecapView: Bool = false
    @State private var showCreateNewTopicView: Bool = false
    @State private var selectedSection: Section? = nil
   
//    @State private var topicsList: TopicsList = .active
    @State private var topicScrollPosition: Int?
    @State private var focusAreasLimit: Int = 3
    
    @Binding var selectedTopic: Topic?
    @Binding var currentTabBar: TabBarType
    @Binding var selectedTabTopic: TopicPickerItem
    @Binding var navigateToTopicDetailView: Bool
    @Binding var categoriesScrollPosition: Int?
    
    
    @ObservedObject var category: Category
    @ObservedObject var points: Points
    
    @FetchRequest var topics: FetchedResults<Topic>
   
    
    var pageCount: Int {
        return topics.count + 1
    }
    
    init(topicViewModel: TopicViewModel,
         transcriptionViewModel: TranscriptionViewModel,
         selectedTopic: Binding<Topic?>,
         currentTabBar: Binding<TabBarType>,
         selectedTabTopic: Binding<TopicPickerItem>,
         navigateToTopicDetailView: Binding<Bool>,
         categoriesScrollPosition: Binding<Int?>,
         category: Category,
         points: Points) {
        
        self.topicViewModel = topicViewModel
        self.transcriptionViewModel = transcriptionViewModel
        self._selectedTopic = selectedTopic
        self._currentTabBar = currentTabBar
        self._selectedTabTopic = selectedTabTopic
        self._navigateToTopicDetailView = navigateToTopicDetailView
        self._categoriesScrollPosition = categoriesScrollPosition
        self.category = category
        self.points = points
        
        let request: NSFetchRequest<Topic> = Topic.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: "createdAt", ascending: false)]
        request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [
            NSPredicate(format: "status == %@", TopicStatusItem.active.rawValue),
            NSPredicate(format: "category == %@", category)
        ])
        self._topics = FetchRequest(fetchRequest: request)
    }
    
    var body: some View {

            VStack (spacing: 12) {
//                switch topicsList {
//                case .active:
                    ActiveTopicsView(topicViewModel: topicViewModel, transcriptionViewModel: transcriptionViewModel, showCreateNewTopicView: $showCreateNewTopicView, selectedTopic: $selectedTopic, currentTabBar: $currentTabBar, selectedTabTopic: $selectedTabTopic, navigateToTopicDetailView: $navigateToTopicDetailView,
                                     topicScrollPosition: $topicScrollPosition, categoriesScrollPosition: $categoriesScrollPosition, focusAreasLimit: $focusAreasLimit,
                        topics: topics,
                        points: points
                    )
//                case .archived:
//                    ArchivedTopicsView(topicViewModel: topicViewModel, transcriptionViewModel: transcriptionViewModel, selectedTopic: $selectedTopic, currentTabBar: $currentTabBar, selectedTabTopic: $selectedTabTopic, navigateToTopicDetailView: $navigateToTopicDetailView)
//                }
                
                if pageCount > 1 {
                    PageIndicatorView(scrollPosition: $topicScrollPosition, pagesCount: pageCount)
                }
                
            }//VStack
            .sheet(isPresented: $showCreateNewTopicView, onDismiss: {
                showCreateNewTopicView = false
            }) {
                NewTopicView(topicViewModel: topicViewModel, selectedTopic: $selectedTopic, navigateToTopicDetailView: $navigateToTopicDetailView, currentTabBar: $currentTabBar, focusAreasLimit: $focusAreasLimit, category: category)
                    .presentationDetents([.fraction(0.65)])
                    .presentationCornerRadius(30)
                
            }

    }
    
    
//    private func topBarLeading() -> some View {
//        HStack (spacing: 15) {
//            ToolbarTitleItem(title: "Top of mind")
//                .opacity(topicsList == .active ? 1 : 0.7)
//                .onTapGesture {
//                    topicsList = .active
//                }
//            
//            
//            ToolbarTitleItem(title: "Archived")
//                .opacity(topicsList == .archived ? 1 : 0.7)
//                .onTapGesture {
//                    topicsList = .archived
//                }
//        }
//    }
}


