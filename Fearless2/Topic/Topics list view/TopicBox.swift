//
//  TopicBox.swift
//  Fearless2
//
//  Created by Yue Deng-Wu on 11/7/24.
//

import SwiftUI

struct TopicBox: View {
    @ObservedObject var topicViewModel: TopicViewModel
    @ObservedObject var topic: Topic
    let buttonAction: () -> Void
    var latestFocusArea: FocusArea? {
        let sortedFocusArea = topic.topicFocusAreas.sorted { $0.focusAreaCreatedAt < $1.focusAreaCreatedAt }
        return sortedFocusArea.last
    }
    
    var totalFocusAreas: Int {
        return topic.topicFocusAreas.count
    }
    
    var body: some View {
            
        VStack (spacing: 5){
            
            Text(topic.topicTitle)
                .multilineTextAlignment(.center)
                .font(.system(size: 21, design:.serif))
                .foregroundStyle(AppColors.whiteDefault)
                .lineSpacing(0.5)
                .fixedSize(horizontal: false, vertical: true)
                .padding(.horizontal)
            
            Rectangle()
                .fill(Color.white.opacity(0.03))
                .frame(maxWidth: .infinity)
                .frame(height: 1)
                .padding(.vertical, (topic.completed != true) ? 15 : 30)
            
            
            Text((topic.completed != true) ? "Path \(totalFocusAreas)" : "Quest complete")
                .font(.system(size: 17, weight: .light).smallCaps())
                .fontWidth(.condensed)
                .foregroundStyle(AppColors.textSecondary.opacity(0.5))
                .fixedSize(horizontal: false, vertical: true)
                .padding(.top, (topic.completed != true) ? 0 : 20)
         
            
            if topic.completed != true {
                Text(latestFocusArea?.focusAreaTitle ?? "")
                    .multilineTextAlignment(.center)
                    .font(.system(size: 15, weight: .light))
                    .foregroundStyle(AppColors.textPrimary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            
            Spacer()
            
            if topic.completed != true {
                RoundButton(buttonImage: "arrow.right", buttonAction: {
                    buttonAction()
                })
                .disabled(true)
            } else {
                Image(systemName: "checkmark")
                    .font(.system(size: 21))
                    .foregroundStyle(Color.white.opacity(0.7))
            }
              
        
        }//VStack
        .padding()
        .padding(.vertical, (topic.completed != true) ? 10 : 20)
        .contentShape(Rectangle())
        .background {
            RoundedRectangle(cornerRadius: 25)
                .stroke(Color.white.opacity(0.1), lineWidth: 0.5)
                .fill(AppColors.boxGrey1.opacity(0.3))
                .shadow(color: Color.black.opacity(0.05), radius: 15, x: 0, y: 3)
                .blendMode(.colorDodge)
        }

    }
    
    
}


//#Preview {
//    TopicBox()
//}
