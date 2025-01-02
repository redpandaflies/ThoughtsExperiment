//
//  SectionListView.swift
//  Fearless2
//
//  Created by Yue Deng-Wu on 10/14/24.
//

import SwiftUI

struct SectionListView: View {
    @Binding var showFocusAreaRecapView: Bool
    @Binding var selectedSection: Section?
    @Binding var selectedSectionSummary: SectionSummary?
    @Binding var selectedFocusArea: FocusArea?
    @Binding var selectedFocusAreaSummary: FocusAreaSummary?
    let sections: [Section]
    let focusAreaCompleted: Bool
    
    // Computed property to sort sections
    var sortedSections: [Section] {
        sections.sorted { $0.sectionNumber < $1.sectionNumber }
    }
    //determin if all sections are completed
    var sectionsAllComplete: Bool {
        let completedSections = sections.filter { $0.completed == true }
        
        return completedSections.count == sections.count ? true : false
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
            
            FocusAreaRecapPreviewBox(focusAreaCompleted: focusAreaCompleted, available: sectionsAllComplete)
                .onTapGesture {
                    if sectionsAllComplete {
                        selectedFocusArea = sections.first?.focusArea
                        print("Selected focus area: \(String(describing: selectedFocusArea))")
                        selectedFocusAreaSummary = selectedFocusArea?.summary
                        showFocusAreaRecapView = true
                    }
                }
        }
    }
}

//#Preview {
//    SectionListView()
//}
