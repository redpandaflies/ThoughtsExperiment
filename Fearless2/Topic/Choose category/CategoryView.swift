//
//  CategoryView.swift
//  Fearless2
//
//  Created by Yue Deng-Wu on 10/1/24.
//

import SwiftUI

struct CategoryView: View {
    
    @Binding var showCreateNewTopicView: Bool
    @Binding var selectedCategory: CategoryItem
    
    
    private let boxArray: [CategoryItem] = Array(CategoryItem.allCases)
    
    
    var body: some View {
        VStack (alignment: .leading, spacing: 15) {
            Text("What do you want help with?")
                .multilineTextAlignment(.leading)
                .font(.system(size: 25))
                .fontWeight(.bold)
                .foregroundStyle(AppColors.blackDefault)
            
            
            ForEach(boxArray, id: \.self) { item in
                CategoryBox(category: item)
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
    CategoryView(showCreateNewTopicView: .constant(false), selectedCategory: .constant(.decision))
}
