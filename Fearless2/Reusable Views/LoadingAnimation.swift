//
//  LoadingAnimation.swift
//  Fearless2
//
//  Created by Yue Deng-Wu on 10/2/24.
//
import SwiftUI

struct LoadingAnimation: View {
    
    let selectedCategory: TopicCategoryItem
    
    var body: some View {
        VStack (alignment: .leading) {
            Text(selectedCategory.getFullName())
                .multilineTextAlignment(.leading)
                .font(.system(size: 11, weight: .regular))
                .foregroundStyle(selectedCategory.getCategoryColor())
                .textCase(.uppercase)
                .padding(.bottom, 5)
            
            HStack {
                Text("Thinking...")
                    .multilineTextAlignment(.leading)
                    .font(.system(size: 19))
                    .foregroundStyle(Color.white)
                
                Spacer()
            }
            
            Spacer()
    
        }
        .padding()
        .frame(width: 360, height: 340)
        .background {
            RoundedRectangle(cornerRadius: 20)
                .fill(AppColors.questionBoxBackground)
                .shadow(color: .black.opacity(0.07), radius: 3, x: 0, y: 1)
        }
    }
}

//#Preview {
//    LoadingAnimation()
//}
