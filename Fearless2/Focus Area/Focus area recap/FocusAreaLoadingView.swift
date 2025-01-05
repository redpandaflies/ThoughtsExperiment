//
//  FocusAreaLoadingView.swift
//  Fearless2
//
//  Created by Yue Deng-Wu on 1/3/25.
//

import SwiftUI

struct FocusAreaLoadingView: View {
    @ObservedObject var topicViewModel: TopicViewModel
    
    @Binding var recapReady: Bool
   
    let focusArea: FocusArea
    var sortedSections: [Section] {
        focusArea.focusAreaSections.sorted { $0.sectionNumber < $1.sectionNumber }
    }
    
    var body: some View {
        VStack (alignment: .leading, spacing: 10){
            
            HStack {
                Text(focusArea.focusAreaEmoji)
                    .multilineTextAlignment(.leading)
                    .font(.system(size: 29))
                
                Spacer()
                
            }
            .padding(.top, 40)
            
            Text(focusArea.focusAreaTitle)
                .multilineTextAlignment(.leading)
                .font(.system(size: 25, weight: .light))
                .foregroundStyle(AppColors.whiteDefault)
            
            Text(focusArea.focusAreaReasoning)
                .multilineTextAlignment(.leading)
                .font(.system(size: 16, weight: .light))
                .foregroundStyle(AppColors.whiteDefault.opacity(0.7))
                .padding(.bottom, 15)
            
            ForEach(sortedSections, id: \.sectionId) { section in
                
                getContent(icon: "checkmark.circle.fill", text: section.sectionTitle, color: AppColors.green1)
                
            }//ForEach
            
            
            getContent(icon: "arrow.right.circle",
                       text: recapReady ? "Recap ready" : "Generating recap...",
                       color: recapReady ? AppColors.yellow1 : AppColors.whiteDefault.opacity(0.5)
            )
            
            
        }//VStack
        
    }
    
    private func getContent(icon: String, text: String, color: Color) -> some View {
        
        HStack {

            Image(systemName: icon)
                .multilineTextAlignment(.leading)
                .font(.system(size: 17))
                .foregroundStyle(color)
                .contentTransition(.symbolEffect(.replace.offUp.byLayer))
            
            Text(text)
                .multilineTextAlignment(.leading)
                .font(.system(size: 17))
                .foregroundStyle(color)
            
        }//HStack
       
        
    }
}
