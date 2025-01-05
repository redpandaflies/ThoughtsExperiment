//
//  SectionListView.swift
//  Fearless2
//
//  Created by Yue Deng-Wu on 10/14/24.
//

import SwiftUI

struct SectionListView: View {
    @EnvironmentObject var dataController: DataController
    @State private var sectionsComplete: Bool = false
    
    @Binding var showFocusAreaRecapView: Bool
    @Binding var selectedSection: Section?
    @Binding var selectedSectionSummary: SectionSummary?
    @Binding var selectedFocusArea: FocusArea?
    @ObservedObject var focusArea: FocusArea
    let focusAreaCompleted: Bool
    
    // Computed property to sort sections
    var sortedSections: [Section] {
        focusArea.focusAreaSections.sorted { $0.sectionNumber < $1.sectionNumber }
    }
    
    var body: some View {
        HStack(spacing: 12) {
            ForEach(sortedSections, id: \.sectionId) { section in
                SectionBox(section: section)
                    .onTapGesture {
                        if section.completed {
                            selectedSectionSummary = section.summary
                        } else {
                            selectedSection = section
                        }
                    }
            }
            
            FocusAreaRecapPreviewBox(focusAreaCompleted: focusAreaCompleted, available: sectionsComplete)
                .onTapGesture {
                    if sectionsComplete {
                        selectedFocusArea = focusArea
                        print("Selected focus area: \(String(describing: selectedFocusArea))")
                        showFocusAreaRecapView = true
                    }
                }
        }//HStack
        .onAppear {
            sectionsComplete = checkSectionsStatus()
        }
        .onChange(of: dataController.allSectionsComplete) {
            if dataController.allSectionsComplete {
                sectionsComplete = checkSectionsStatus()
            }
        }
    }
    
    private func checkSectionsStatus() -> Bool {
        let completedSections = focusArea.focusAreaSections.filter { $0.completed == true }
        
        return completedSections.count == focusArea.focusAreaSections.count
    }
}

//#Preview {
//    SectionListView()
//}
