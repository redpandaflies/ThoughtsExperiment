//
//  CategoryDescriptionView.swift
//  Fearless2
//
//  Created by Yue Deng-Wu on 2/7/25.
//

import SwiftUI

struct CategoryDescriptionView: View {
    
    let category: Category
    
    var body: some View {
        VStack (spacing: 13) {
            
            Text(category.categoryName)
                .font(.system(size: 25, design: .serif))
                .foregroundStyle(AppColors.textPrimary)
            
            Text(category.categoryDiscovered)
                .multilineTextAlignment(.center)
                .font(.system(size: 16, weight: .light))
                .foregroundStyle(AppColors.textPrimary)
                .opacity(0.8)
                .lineSpacing(1.5)
            
            Text("Discovered on January 31, 2025")
                .font(.system(size: 13, weight: .thin).smallCaps())
                .foregroundStyle(AppColors.textPrimary)
                .fontWidth(.condensed)
                .opacity(0.6)
                .textCase(.uppercase)
        }
//        .background(Color.black)
    }
}

//#Preview {
//    CategoryDescriptionView()
//}
