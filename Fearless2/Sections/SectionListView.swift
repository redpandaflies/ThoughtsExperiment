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
    @EnvironmentObject var dataController: DataController
    @State private var sectionsComplete: Bool = false
    @State private var sectionsScrollPosition: Int?
    
    
    @Binding var showFocusAreaRecapView: Bool
    @Binding var selectedSection: Section?
    @Binding var selectedSectionSummary: SectionSummary?
    @Binding var selectedFocusArea: FocusArea?
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

   init(showFocusAreaRecapView: Binding<Bool>,
        selectedSection: Binding<Section?>,
        selectedSectionSummary: Binding<SectionSummary?>,
        selectedFocusArea: Binding<FocusArea?>,
        focusArea: FocusArea,
        focusAreaCompleted: Bool) {
       self._showFocusAreaRecapView = showFocusAreaRecapView
       self._selectedSection = selectedSection
       self._selectedSectionSummary = selectedSectionSummary
       self._selectedFocusArea = selectedFocusArea
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
                            startSection(section: section)
                        })
                        .scrollTransition { content, phase in
                            content
                                .scaleEffect(x: phase.isIdentity ? 1 : 0.9, y: phase.isIdentity ? 1 : 0.9)
                        }
                        .id(index)
                        .onTapGesture {
                            startSection(section: section)
                        }
                    }
                    
                    FocusAreaRecapPreviewBox(focusAreaCompleted: focusAreaCompleted, available: allSectionsCompleted, buttonAction: {
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
                }//HStack
                .scrollTargetLayout()
            }
            .scrollPosition(id: $sectionsScrollPosition, anchor: .center)
            .contentMargins(.horizontal, safeAreaPadding, for: .scrollContent)
            .scrollClipDisabled(true)
            .scrollTargetBehavior(.viewAligned)
            .scrollIndicators(.hidden)
            .onAppear {
                sectionsScrollPosition = firstIncompleteSectionIndex ?? sections.count
            }
            .onChange(of: selectedSection) {
                if let index = firstIncompleteSectionIndex {
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        withAnimation(.smooth) {
                            sectionsScrollPosition = index
                        }
                    }
                    
                } else {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        withAnimation(.smooth) {
                            sectionsScrollPosition = sections.count
                        }
                    }
                    DispatchQueue.global(qos: .background).async {
                        Mixpanel.mainInstance().track(event: "Finished path")
                    }
                }
            }
           

//        .onAppear {
//            sectionsComplete = checkSectionsStatus()
//        }
//        .onChange(of: dataController.allSectionsComplete) {
//            if dataController.allSectionsComplete {
//                sectionsComplete = checkSectionsStatus()
//            }
//        }
    }
    
    private func checkSectionsStatus() -> Bool {
        let completedSections = focusArea.focusAreaSections.filter { $0.completed == true }
        
        return completedSections.count == focusArea.focusAreaSections.count
    }
    
    private func startSection(section: Section) {
        guard let topic = section.topic else {
            logger.error("Topic not found for selected section")
            return
        }
        
        if section == firstIncompleteSection && topic.topicStatus != TopicStatusItem.archived.rawValue {
            selectedSection = section
        }
    }
    
    private func startRecap() {
        if allSectionsCompleted {
            selectedFocusArea = focusArea
            logger.log("Selected focus area: \(String(describing: selectedFocusArea))")
            showFocusAreaRecapView = true
        }
    }
}

//#Preview {
//    SectionListView()
//}
