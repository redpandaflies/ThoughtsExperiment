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
                .stroke(AppColors.darkBrown)
                .fill(AppColors.darkBrown)
            
            VStack (spacing: 18){
                
                TopicImageView(topicViewModel: topicViewModel, topic: topic)
                
                Text(topic.topicTitle)
                    .multilineTextAlignment(.center)
                    .font(.system(size: 15, weight: .light))
                    .foregroundStyle(Color.white)
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
