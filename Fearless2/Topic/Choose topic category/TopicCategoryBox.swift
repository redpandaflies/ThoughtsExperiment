//
//  TopicCategoryBox.swift
//  Fearless2
//
//  Created by Yue Deng-Wu on 10/1/24.
//

import SwiftUI

struct TopicCategoryBox: View {
    
    let category: TopicCategoryItem
    
    var body: some View {
        VStack (alignment: .leading, spacing: 8){
            HStack {
                BubblesCategory(selectedCategory: category, useFullName: true)
                
                Spacer()
            }
            
            Text(category.getDescription())
                .multilineTextAlignment(.leading)
                .font(.system(size: 13))
                .fontWeight(.regular)
                .foregroundStyle(AppColors.blackDefault)
            
        }
        .padding()
        .background {
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.white)
                .stroke(Color(Color.white.opacity(0.4)), style: StrokeStyle(lineWidth: 1))
                .shadow(color: .black.opacity(0.07), radius: 3, x: 0, y: 1)
        }
    }
}

#Preview {
    TopicCategoryBox(category: .emotions)
}
