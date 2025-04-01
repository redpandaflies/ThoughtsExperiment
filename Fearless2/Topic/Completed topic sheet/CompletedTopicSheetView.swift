//
//  CompletedTopicSheetView.swift
//  Fearless2
//
//  Created by Yue Deng-Wu on 3/31/25.
//

import SwiftUI

struct CompletedTopicSheetView: View {
    @Environment(\.dismiss) var dismiss
    let topic: Topic
    let backgroundColor: Color
    
    let screenHeight = UIScreen.current.bounds.height
    
    var sortedFocusAreas: [FocusArea] {
        let focusAreas = topic.topicFocusAreas
        let orderedList = focusAreas.sorted { $0.focusAreaCreatedAt < $1.focusAreaCreatedAt }
        return orderedList.filter { $0.endOfTopic != true }
    }

    var body: some View {
        VStack {
            Text(topic.topicEmoji)
                .font(.system(size: 50))
                .padding(.bottom, 10)
            
            Text(topic.topicTitle)
                .multilineTextAlignment(.center)
                .font(.system(size: 25, design: .serif))
                .foregroundStyle(AppColors.textPrimary)
                .lineSpacing(1.4)
                .padding(.horizontal, 30)
                .padding(.bottom, 40)
            
            
            FocusAreaSummariesList(sortedFocusAreas: sortedFocusAreas)
            
            
            Spacer()
            
            RoundButton(
                buttonImage: "checkmark",
                size: 30,
                frameSize: 80,
                buttonAction: {
                    dismiss()
                }
            )
            
        }
        .padding(.top, 60)
        .padding(.bottom, 40)
        .frame(maxWidth: .infinity, maxHeight: screenHeight * 0.95)
        .backgroundSecondary(backgroundColor: backgroundColor, height: screenHeight * 0.95, yOffset: -(screenHeight * 0.025))
    }
}

struct FocusAreaSummariesList: View {
    @State private var scrollPosition: Int?
    
    let sortedFocusAreas: [FocusArea]
    
    var pageCount: Int {
        return sortedFocusAreas.count
    }
    
    let screenWidth = UIScreen.current.bounds.width
    
    let frameWidth: CGFloat = 320
    
    var safeAreaPadding: CGFloat {
        return (screenWidth - frameWidth) / 2
    }
    
    var body: some View {
        VStack (spacing: 20) {
            ScrollView (.horizontal) {
                
                HStack (spacing: 35) {
                    
                    //Path summaries
                    ForEach(Array(sortedFocusAreas.enumerated()), id: \.element.focusAreaId) { index, focusArea in
                        summaryBox(focusArea: focusArea)
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
    
    private func summaryBox(focusArea: FocusArea) -> some View {
        VStack (alignment: .leading) {
            ScrollView {
                VStack(alignment: .leading, spacing: 15) {
                    Text(DateFormatter.displayString(from: DateFormatter.incomingFormat.date(from: focusArea.focusAreaCompletedAt) ?? Date()))
                        .font(.system(size: 15, weight: .thin).smallCaps())
                        .foregroundStyle(AppColors.textPrimary)
                        .fontWidth(.condensed)
                        .tracking(0.3)
                        .opacity(0.6)
                    
                    if let summary = focusArea.summary?.summarySummary {
                        
                        Text(summary)
                            .multilineTextAlignment(.leading)
                            .font(.system(size: 17, weight: .light))
                            .foregroundStyle(AppColors.textPrimary)
                            .lineSpacing(1.7)
                        
                    }
                }
                .padding()
            }
            .scrollIndicators(.hidden)
            .frame(width: frameWidth, height: 300)
        }
        .background {
            RoundedRectangle(cornerRadius: 25)
                .stroke(Color.white.opacity(0.2), lineWidth: 0.5)
                .fill(Color.clear)
        }
    }
    
}

//#Preview {
//    CompletedTopicSheetView()
//}
