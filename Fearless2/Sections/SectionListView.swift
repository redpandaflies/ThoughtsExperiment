//
//  SectionListView.swift
//  Fearless2
//
//  Created by Yue Deng-Wu on 10/14/24.
//
import CoreData
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
        ScrollViewReader { proxy in
            
            ScrollView (.horizontal) {
                
                HStack(spacing: 12) {
                    ForEach(Array(sections.enumerated()), id: \.element.sectionId) { index, section in
                        SectionBox(section: section, isNextSection: section == firstIncompleteSection)
                            .id(index)
                            .onTapGesture {
                                if section == firstIncompleteSection {
                                    selectedSection = section
                                }
                            }
                    }
                    
                    FocusAreaRecapPreviewBox(focusAreaCompleted: focusAreaCompleted, available: allSectionsCompleted)
                        .id(sections.count)
                        .onTapGesture {
                            if allSectionsCompleted {
                                selectedFocusArea = focusArea
                                print("Selected focus area: \(String(describing: selectedFocusArea))")
                                showFocusAreaRecapView = true
                            }
                        }
                }//HStack
            }
            .padding(.horizontal)
            .scrollIndicators(.hidden)
            .scrollClipDisabled(true)
            .onAppear {
                if let index = firstIncompleteSectionIndex {
                    proxy.scrollTo(index, anchor: .center)
                } else {
                    proxy.scrollTo(sections.count, anchor: .center)
                }
            }
            .onChange(of: firstIncompleteSectionIndex) {
                if let index = firstIncompleteSectionIndex {
                    proxy.scrollTo(index, anchor: .center)
                } else {
                    proxy.scrollTo(sections.count, anchor: .center)
                }
            }
           
        }//scrollview reader
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
    
//    private func getNextSection() -> Section? {
//        return sortedSections.first { !$0.completed }
//    }
}

//#Preview {
//    SectionListView()
//}
