//
//  SectionListView.swift
//  Fearless2
//
//  Created by Yue Deng-Wu on 10/14/24.
//
import CoreData
import Mixpanel
import OSLog
import SwiftUI

struct SectionListView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var dataController: DataController
    @ObservedObject var topicViewModel: TopicViewModel
    @State private var sectionsComplete: Bool = false
    @State private var sectionsScrollPosition: Int?
    @State private var playHapticEffect: Int = 0
    
    @Binding var showFocusAreaRecapView: Bool
    @Binding var selectedSection: Section?
    @Binding var selectedSectionSummary: SectionSummary?
    @Binding var selectedFocusArea: FocusArea?
    @Binding var selectedEndOfTopicSection: Section?
    @ObservedObject var focusArea: FocusArea
    let focusAreaCompleted: Bool
    
    @FetchRequest var sections: FetchedResults<Section>
    
    let logger = Logger.uiEvents
    
    var firstIncompleteSection: Section? {
            sections.first { !$0.completed }
        }
    
    var firstIncompleteSectionIndex: Int? {
        sections.firstIndex(where: { !$0.completed })
    }
    
    var allSectionsCompleted: Bool {
        let completedSections = sections.filter { $0.completed == true }
        
        return completedSections.count == sections.count
    }
    
    let frameWidth: CGFloat = 150
    var safeAreaPadding: CGFloat {
        return (UIScreen.main.bounds.width - frameWidth)/2
    }

    init(topicViewModel: TopicViewModel,
        showFocusAreaRecapView: Binding<Bool>,
        selectedSection: Binding<Section?>,
        selectedSectionSummary: Binding<SectionSummary?>,
        selectedFocusArea: Binding<FocusArea?>,
        selectedEndOfTopicSection: Binding<Section?>,
        focusArea: FocusArea,
        focusAreaCompleted: Bool) {
        self.topicViewModel = topicViewModel
       self._showFocusAreaRecapView = showFocusAreaRecapView
       self._selectedSection = selectedSection
       self._selectedSectionSummary = selectedSectionSummary
       self._selectedFocusArea = selectedFocusArea
       self._selectedEndOfTopicSection = selectedEndOfTopicSection
       self.focusArea = focusArea
       self.focusAreaCompleted = focusAreaCompleted

       self._sections = FetchRequest(
           entity: Section.entity(),
           sortDescriptors: [NSSortDescriptor(keyPath: \Section.sectionNumber, ascending: true)],
           predicate: NSPredicate(format: "focusArea.id == %@", focusArea.focusAreaId as CVarArg)
       )
   }
    
    var body: some View {
       
            ScrollView (.horizontal) {
                
                HStack(spacing: 12) {
                    ForEach(Array(sections.enumerated()), id: \.element.sectionId) { index, section in
                        SectionBox(section: section, isNextSection: section == firstIncompleteSection, buttonAction: {
                            startSection(section: section, index: index)
                        }, isEndOfTopic: (focusArea.endOfTopic == true), sectionIndex: index)
                        .scrollTransition { content, phase in
                            content
                                .scaleEffect(x: phase.isIdentity ? 1 : 0.9, y: phase.isIdentity ? 1 : 0.9)
                        }
                        .id(index)
                        .onTapGesture {
                            startSection(section: section, index: index)
                        }
                        .sensoryFeedback(.selection, trigger: playHapticEffect)
                    }
                    
                    if focusArea.endOfTopic != true {
                        FocusAreaRecapPreviewBox(
                            focusAreaCompleted: focusAreaCompleted,
                            available: allSectionsCompleted,
                            buttonAction: {
                            startRecap()
                        })
                        .scrollTransition { content, phase in
                            content
                                .scaleEffect(x: phase.isIdentity ? 1 : 0.9, y: phase.isIdentity ? 1 : 0.9)
                        }
                        .id(sections.count)
                        .onTapGesture {
                            startRecap()
                        }
                        .sensoryFeedback(.selection, trigger: playHapticEffect)
                    }
                }//HStack
                .scrollTargetLayout()
            }
            .scrollPosition(id: $sectionsScrollPosition, anchor: .center)
            .contentMargins(.horizontal, safeAreaPadding, for: .scrollContent)
            .scrollClipDisabled(true)
            .scrollTargetBehavior(.viewAligned(limitBehavior: .alwaysByOne))
            .scrollIndicators(.hidden)
            .onAppear {
                if playHapticEffect != 0 {
                    playHapticEffect = 0
                }
                sectionsScrollPosition = firstIncompleteSectionIndex ?? sections.count
            }
            .onChange(of: selectedSection) {
                if selectedSection == nil {
                    manageSectionScroll()
                }
            }
            .onChange(of: selectedEndOfTopicSection) {
                if selectedEndOfTopicSection == nil {
                    manageSectionScroll()
                }
            }
    }
    
    private func checkSectionsStatus() -> Bool {
        let completedSections = focusArea.focusAreaSections.filter { $0.completed == true }
        
        return completedSections.count == focusArea.focusAreaSections.count
    }
    
    private func startSection(section: Section, index: Int) {
        playHapticEffect += 1
        
        guard let topic = section.topic else {
            logger.error("Topic not found for selected section")
            return
        }
        
        if section == firstIncompleteSection && topic.topicStatus != TopicStatusItem.archived.rawValue && focusArea.endOfTopic != true {
            selectedSection = section
        }
        
        if focusArea.endOfTopic == true {
            if index == 0 {
                selectedEndOfTopicSection = section
            } else {
                if section == firstIncompleteSection {
                    goToAddTopic(section: section)
                }
            }
        }
        
    }
    
    private func startRecap() {
        if allSectionsCompleted {
            playHapticEffect += 1
            selectedFocusArea = focusArea
            logger.log("Selected focus area: \(String(describing: selectedFocusArea))")
            showFocusAreaRecapView = true
        }
    }
    
    private func manageSectionScroll() {
        if let index = firstIncompleteSectionIndex {
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                withAnimation(.smooth(duration: 0.2)) {
                    sectionsScrollPosition = index
                }
            }
            
        } else {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                withAnimation(.smooth(duration: 0.2)) {
                    sectionsScrollPosition = sections.count
                }
            }
        }
    }
    
    private func goToAddTopic(section: Section) {

        Task {
           
            //return to home view
            await MainActor.run {
                
                topicViewModel.scrollToAddTopic = true
                dismiss()
            }
        }
        
    }
}

//#Preview {
//    SectionListView()
//}
