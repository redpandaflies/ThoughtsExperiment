//
//  FocusAreaBox.swift
//  Fearless2
//
//  Created by Yue Deng-Wu on 11/8/24.
//

import SwiftUI

struct FocusAreaBox: View {
    @Binding var showUpdateTopicView: Bool?
    @Binding var showSectionRecapView: Bool
    @Binding var selectedSection: Section?
   
    let focusArea: FocusArea
    let selectedCategory: TopicCategoryItem
    let index: Int
    
    var body: some View {
       
        VStack (alignment: .leading, spacing: 10){
            Group {
                
                Text("\(index + 1)")
                    .multilineTextAlignment(.leading)
                    .font(.system(size: 30))
                    .fontWeight(.regular)
                    .foregroundStyle(selectedCategory.getCategoryColor())
                
                Text(focusArea.focusAreaTitle)
                    .multilineTextAlignment(.leading)
                    .font(.system(size: 25))
                    .fontWeight(.regular)
                    .foregroundStyle(Color.white)
                
                
                Text(focusArea.focusAreaReasoning)
                    .multilineTextAlignment(.leading)
                    .font(.system(size: 16))
                    .fontWeight(.regular)
                    .foregroundStyle(Color.white)
                    .opacity(0.7)
                    .padding(.bottom, 10)
            }
            .padding(.horizontal, 30)
            
            ScrollView(.horizontal, showsIndicators: false) {
                SectionListView(showUpdateTopicView: $showUpdateTopicView, showSectionRecapView: $showSectionRecapView, selectedSection: $selectedSection, sections: focusArea.focusAreaSections, focusAreaCompleted: focusArea.completed)
            }
            .padding(.horizontal, 30)
            .scrollClipDisabled(true)
            
        }//VStack
        
    }
}

//#Preview {
//    FocusAreaBox()
//}
