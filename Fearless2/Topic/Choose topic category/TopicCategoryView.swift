//
//  TopicCategoryView.swift
//  Fearless2
//
//  Created by Yue Deng-Wu on 10/1/24.
//

import SwiftUI

struct TopicCategoryView: View {
    
    @Binding var showCreateNewTopicView: Bool
    @Binding var selectedCategory: TopicCategoryItem
    
    
    private let boxArray: [TopicCategoryItem] = Array(TopicCategoryItem.allCases)
    
    
    var body: some View {
        VStack (alignment: .leading, spacing: 15) {
            Text("What do you want help with?")
                .multilineTextAlignment(.leading)
                .font(.system(size: 25))
                .fontWeight(.bold)
                .foregroundStyle(AppColors.blackDefault)
            
            
            ForEach(boxArray, id: \.self) { item in
                TopicCategoryBox(category: item)
                    .onTapGesture {
                        selectedCategory = item
                        withAnimation(.snappy(duration: 0.2)) {
                            showCreateNewTopicView = true
                        }
                    }
            }
            
        }
    }
}

#Preview {
    TopicCategoryView(showCreateNewTopicView: .constant(false), selectedCategory: .constant(.personal))
}
