//
//  UpdateTopicView.swift
//  Fearless2
//
//  Created by Yue Deng-Wu on 10/3/24.
//
import CoreData
import SwiftUI

struct UpdateTopicView: View {
    @ObservedObject var topicViewModel: TopicViewModel
    
    @State private var topicText = ""
    @State private var showCard: Bool = false
    @State private var selectedTab: Int = 0
    
    @Binding var showUpdateTopicView: Bool?
    
    let selectedCategory: TopicCategoryItem
    let topicId: UUID?
    let question: String
    let section: Section?
    
    @FetchRequest var entries: FetchedResults<Entry>
    
    init(topicViewModel: TopicViewModel, showUpdateTopicView: Binding<Bool?> = .constant(nil), selectedCategory: TopicCategoryItem, topicId: UUID?, question: String, section: Section?) {
        self.topicViewModel = topicViewModel
        self._showUpdateTopicView = showUpdateTopicView
        self.selectedCategory = selectedCategory
        self.topicId = topicId
        self.question = question
        self.section = section
        
        let request: NSFetchRequest<Entry> = Entry.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: "createdAt", ascending: false)]
        if let entrySection = self.section {
            request.predicate = NSPredicate(format: "section.id == %@", entrySection.sectionId as CVarArg)
        }
        request.fetchLimit = 1
        self._entries = FetchRequest(fetchRequest: request)
    }
    
    var body: some View {
        
        if let currentSection = section, currentSection.completed {
            if let entry = entries.first {
                SectionSummaryView(entry: entry, showUpdateTopicView: $showUpdateTopicView, isFullScreen: true)
            }
        } else {
            
            ZStack {
                Rectangle()
                    .fill(Material.ultraThin)
                    .ignoresSafeArea()
                    .onTapGesture {
                        withAnimation(.snappy(duration: 0.2)) {
                            self.showCard = false
                        }
                        showUpdateTopicView = false
                    }
                
                
                switch selectedTab {
                case 0:
                    if showCard {
                        
                        if let sectionQuestions = section?.sectionQuestions {
                            UpdateTopicBox(topicViewModel: topicViewModel, showCard: $showCard, selectedTab: $selectedTab, selectedCategory: selectedCategory, section: section, questions: sectionQuestions)
                                .padding(.horizontal)
                                .transition(.move(edge: .bottom))
                        }
                    }
                case 1:
                    LoadingAnimation()
                    
                default:
                    if let entry = entries.first {
                        SectionSummaryView(entry: entry, showUpdateTopicView: $showUpdateTopicView, isFullScreen: true)
                    }
                    
                }
                
            }
            .environment(\.colorScheme, .light)
            .onAppear {
                withAnimation(.snappy(duration: 0.2)) {
                    self.showCard = true
                }
            }
            .onChange(of: topicViewModel.topicUpdated) {
                if topicViewModel.topicUpdated {
                    withAnimation(.snappy(duration: 0.2)) {
                        selectedTab += 1
                    }
                    
                }
            }
        }//else
    }
}

//#Preview {
//    UpdateTopicView()
//}
