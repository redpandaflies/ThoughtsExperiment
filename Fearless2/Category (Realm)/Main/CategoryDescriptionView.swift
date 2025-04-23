//
//  CategoryDescriptionView.swift
//  Fearless2
//
//  Created by Yue Deng-Wu on 2/7/25.
//
import Pow
import SwiftUI

struct CategoryDescriptionView: View {
    @Binding var animationStage: Int
    @Binding var showNewCategory: Bool
    let category: Category
    
    @AppStorage("unlockNewCategory") var newCategory: Bool = false
    
    var body: some View {
        VStack (spacing: 13) {
            
            if showNewCategory || newCategory {
                Text(category.categoryName)
                    .multilineTextAlignment(.center)
                    .font(.system(size: 25, design: .serif))
                    .foregroundStyle(AppColors.textPrimary)
                    .transition(
                        .identity
                            .animation(.linear(duration: 1).delay(2))
                            .combined(
                                with: .movingParts.anvil
                            )
                    )
                    .sensoryFeedback(.impact, trigger: showNewCategory) { oldValue, newValue in
                        return oldValue != newValue && newValue == true
                    }
            }
            
        }
//        .background(Color.black)
    }
}

//#Preview {
//    CategoryDescriptionView()
//}
