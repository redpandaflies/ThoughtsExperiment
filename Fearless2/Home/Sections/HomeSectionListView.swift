//
//  SectionListView.swift
//  Fearless2
//
//  Created by Yue Deng-Wu on 10/14/24.
//

import SwiftUI

struct SectionListView: View {
    @Binding var showUpdateTopicView: Bool
    @Binding var selectedSection: Section?
    let sections: [Section]
    
    // Computed property to sort sections
    var sortedSections: [Section] {
        sections.sorted { $0.sectionNumber < $1.sectionNumber }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            ForEach(sortedSections, id: \.sectionId) { section in
                HomeSectionBox(title: section.sectionTitle)
                    .onTapGesture {
                        selectedSection = section
                        showUpdateTopicView = true
                    }
            }
        }
    }
}

//#Preview {
//    SectionListView()
//}
