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
    
    var body: some View {
        
        ZStack (alignment: .top) {
            RoundedRectangle(cornerRadius: 25)
                .fill(AppColors.darkGrey3)
                .shadow(color: Color.black.opacity(0.05), radius: 7, x: 0, y: 1)
            
            VStack (spacing: 18){
                
                TopicImageView(topicViewModel: topicViewModel, topic: topic)
                
                Text(topic.topicTitle)
                    .multilineTextAlignment(.center)
                    .font(.system(size: 15, weight: .light))
                    .foregroundStyle(AppColors.whiteDefault)
                    .lineSpacing(0.5)
                    .padding(.horizontal, 9)
                    .padding(.bottom, 13)
                
            }
            .padding(5)
        }
        .contentShape(Rectangle())

    }
}

//#Preview {
//    TopicBox()
//}
