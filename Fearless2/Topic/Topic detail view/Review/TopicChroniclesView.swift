//
//  TopicChroniclesView.swift
//  Fearless2
//
//  Created by Yue Deng-Wu on 1/4/25.
//

import SwiftUI

struct TopicChroniclesView: View {
    @State private var scrollPosition: Int?
    let focusAreas: [FocusArea]
    
    var sortedFocusAreas: [FocusArea] {
        let orderedList = focusAreas.sorted { $0.focusAreaCreatedAt < $1.focusAreaCreatedAt }
        return orderedList.filter { $0.endOfTopic != true }
    }
    
    var pageCount: Int {
        return sortedFocusAreas.count
    }
    
    let screenWidth = UIScreen.current.bounds.width
    
    var safeAreaPadding: CGFloat {
        return (screenWidth - 340) / 2
    }
    
    var body: some View {
        VStack (spacing: 20) {
            ScrollView (.horizontal) {
                
                HStack (spacing: 35) {
                    
                    //Path summaries
                    ForEach(Array(sortedFocusAreas.enumerated()), id: \.element.focusAreaId) { index, focusArea in
                        TopicPathSummaryBox(focusArea: focusArea)
                            .id(index)
                    }
                    
                }
                .scrollTargetLayout()
                
            }
            .scrollPosition(id: $scrollPosition, anchor: .center)
            .scrollIndicators(.hidden)
            .scrollClipDisabled()
            .contentMargins(.horizontal, safeAreaPadding, for: .scrollContent)
            .scrollTargetBehavior(.viewAligned(limitBehavior: .alwaysByOne))
            
            //Scroll indicators
            if pageCount > 1 {
                PageIndicatorView(scrollPosition: $scrollPosition, pagesCount: pageCount)
            }
        }
    }
}

struct TopicPathSummaryBox: View {
    
    let focusArea: FocusArea
    
    var body: some View {
        
        VStack (alignment: .leading, spacing: 5) {
            
          
            Text(focusArea.focusAreaTitle)
                .multilineTextAlignment(.leading)
                .font(.system(size: 21, weight: .light))
                .foregroundStyle(AppColors.textPrimary)
            
            
            Text(getSubtitle())
                .font(.system(size: 15, weight: .thin).smallCaps())
                .foregroundStyle(AppColors.textPrimary)
                .fontWidth(.condensed)
                .tracking(0.3)
                .opacity(0.6)
            
            Divider()
                .overlay(AppColors.dividerPrimary.opacity(0.4))
                .shadow(color: AppColors.dividerShadow.opacity(0.05), radius: 0, x: 0, y: 1)
                .padding(.vertical, 15)
            
            
            if let summary = focusArea.summary?.summarySummary {
              
                Text(summary)
                    .multilineTextAlignment(.leading)
                    .font(.system(size: 17, weight: .light))
                    .foregroundStyle(AppColors.textPrimary)
                    .lineSpacing(1.7)
            
            } else {
                VStack (alignment: .center) {
                        
                        Image(systemName: "lock.fill")
                            .multilineTextAlignment(.center)
                            .font(.system(size: 30))
                            .foregroundStyle(AppColors.textPrimary)
                            .opacity(0.5)
                            .padding(.bottom, 15)
                        
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                
            }
            
           
        }
        .padding(30)
        .frame(width: 340, height: 400, alignment: .top)
        .background {
            RoundedRectangle(cornerRadius: 25)
                .stroke(Color.white.opacity(0.2), lineWidth: 0.5)
                .fill(Color.clear)
        }
        
        
    }
    
    private func getSubtitle() -> String {
        if let _ = focusArea.summary?.summarySummary {
            return "Path completed on " + DateFormatter.displayString2(from: DateFormatter.incomingFormat.date(from: focusArea.focusAreaCompletedAt) ?? Date())
        } else {
            return "In progress"
        }
    }
    
}
