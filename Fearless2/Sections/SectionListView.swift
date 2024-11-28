//
//  SectionListView.swift
//  Fearless2
//
//  Created by Yue Deng-Wu on 10/14/24.
//

import SwiftUI

struct SectionListView: View {
    @Binding var showUpdateSectionView: Bool?
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
    
    var body: some View {
        HStack(spacing: 12) {
            ForEach(sortedSections, id: \.sectionId) { section in
                SectionBox(section: section)
                    .onTapGesture {
                        selectedSection = section
                        if section.completed {
                            selectedSectionSummary = section.summary
                        } else {
                            showUpdateSectionView = true
                        }
                    }
            }
            
            FocusAreaRecapPreviewBox(focusAreaCompleted: focusAreaCompleted)
                .onTapGesture {
                    selectedFocusArea = sections.first?.focusArea
                    print("Selected focus area: \(String(describing: selectedFocusArea))")
                    selectedFocusAreaSummary = selectedFocusArea?.summary
                    showFocusAreaRecapView = true
                }
        }
    }
}

//#Preview {
//    SectionListView()
//}
