//
//  HomeCarouselCardView.swift
//  Fearless2
//
//  Created by Yue Deng-Wu on 9/30/24.
//

import SwiftUI

struct HomeCarouselCardView: View {
    @ObservedObject var topic: Topic
    
    var body: some View {
        ZStack (alignment: .top) {
            
            UnevenRoundedRectangle(cornerRadii: .init(topLeading: 20, topTrailing: 20))
                .fill(Color.white)
                .boxShadow()
//                .matchedGeometryEffect(id: "Background", in: animation)
            
            VStack (alignment: .center, spacing: 20) {
               
                HomeCarouselCardHeader(topic: topic)
                
                Text(topic.topicTitle)
                    .multilineTextAlignment(.center)
                    .font(.system(size: 17))
                    .fontWeight(.light)
                    .foregroundStyle(AppColors.blackDefault)
                    .lineSpacing(2)
                    .padding(.horizontal, 2)
                    .padding()
            }//VStack
            
        
        }//ZStack
    }
}

struct HomeCarouselCardHeader: View {
    
    @EnvironmentObject var dataController: DataController
    
    let topic: Topic
    
    var body: some View {
        HStack {
            
            Image(systemName: "ellipsis.circle.fill")
                .font(.system(size: 17))
                .foregroundStyle(Color.clear)
                .padding()
            
            Spacer()
            
            if let category = TopicCategoryItem.fromShortName(topic.topicCategory) {
                BubblesCategory(selectedCategory: category, useFullName: false)
            } else {
                BubblesCategory(selectedCategory: TopicCategoryItem.personal, useFullName: false)
            }
            
            Spacer()
            
            Menu {
                Button (role: .destructive) {
                    Task {
                       await dataController.deleteTopic(id: topic.topicId)
                    }
                    
                } label: {
                    
                    Label("Delete", systemImage: "trash")
                    
                }
                
            } label: {
                Image(systemName: "ellipsis.circle.fill")
                    .font(.system(size: 17))
                    .foregroundStyle(AppColors.ellipsisMenuColor)
                    .opacity(0.4)
                    .padding()
            }
        }
    }
}


//#Preview {
//    HomeCarouselCardView(topic: "Live in San Francisco or nearby", index: 1)
//}
