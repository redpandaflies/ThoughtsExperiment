//
//  FocusAreaRecapTimelineView.swift
//  Fearless2
//
//  Created by Yue Deng-Wu on 2/16/25.
//

import SwiftUI

struct FocusAreaRecapTimelineView: View {
    
    let topic: Topic?
    var totalFocusAreas: Int {
        return topic?.topicFocusAreas.count ?? 0
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            
            if let focusAreas = topic?.topicFocusAreas {
                ForEach(Array(focusAreas.enumerated()), id: \.element.focusAreaId) { index, focusArea in
                    timelineItem(number: index, text: focusArea.focusAreaTitle)
                    connectingLine()
                }
            }
            
            timelineItem(number: totalFocusAreas, text: "Choose next path")
            
        }
        .mask(
            LinearGradient(
                gradient: Gradient(stops: [
                    .init(color: .white.opacity(0.4), location: 0.0),
                    .init(color: .white.opacity(0.8), location: 0.65),
                    .init(color: .white, location: 1)
                ]),
                startPoint: .top,
                endPoint: .bottom
            )
        )
        .padding()
    }
    
    private func timelineItem(number: Int, text: String) -> some View {
           HStack(spacing: 10) {
            
               
               Image(systemName: "\(number + 1).circle.fill")
                   .font(.system(size: 19))
                   .foregroundStyle(AppColors.textPrimary)
                   
                
               HStack (spacing: 3) {
                   Text(text)
                       .font(.system(size: 19, weight: .light))
                       .fontWidth(.condensed)
                       .foregroundStyle(AppColors.textPrimary)
                   
                   if number == totalFocusAreas {
                   Image(systemName: "arrow.turn.right.down")
                       .font(.system(size: 19, weight: .light))
                       .fontWidth(.condensed)
                       .foregroundStyle(AppColors.textPrimary)
                   }
               }
               
               Spacer()
                
           }
          
       }
       
       private func connectingLine() -> some View {
           RoundedRectangle(cornerRadius: 30)
               .fill(Color.white.opacity(0.8))
               .frame(width: 1, height: 15)
               .padding(.leading, 11.5)
               
       }
    
}

//#Preview {
//    FocusAreaRecapTimelineView()
//}
