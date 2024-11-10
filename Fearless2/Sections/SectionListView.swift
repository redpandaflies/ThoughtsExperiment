//
//  SectionListView.swift
//  Fearless2
//
//  Created by Yue Deng-Wu on 10/14/24.
//

import SwiftUI

struct SectionListView: View {
    @Binding var showUpdateTopicView: Bool?
    @Binding var showSectionRecapView: Bool
    @Binding var selectedCategory: TopicCategoryItem
    @Binding var selectedSection: Section?
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
                        if let shortName = section.topic?.category {
                            selectedCategory = TopicCategoryItem.fromShortName(shortName) ?? .personal
                        }
                        selectedSection = section
                        showUpdateTopicView = true
                    }
            }
            
            SectionRecapPreviewBox(focusAreaCompleted: focusAreaCompleted)
                .onTapGesture {
                    showSectionRecapView = true
                }
        }
    }
}

//#Preview {
//    SectionListView()
//}
