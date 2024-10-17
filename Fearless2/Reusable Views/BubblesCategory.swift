//
//  BubblesCategory.swift
//  Fearless2
//
//  Created by Yue Deng-Wu on 9/30/24.
//

import SwiftUI

struct BubblesCategory: View {
    
    let selectedCategory: CategoryItemProtocol
    let useFullName: Bool
    
    var body: some View {
        Text(useFullName ? selectedCategory.getFullName() : selectedCategory.getShortName())
            .font(.system(size: 10))
            .fontWeight(.regular)
            .foregroundStyle(selectedCategory.getBubbleTextColor())
            .textCase(.uppercase)
            .fixedSize(horizontal: true, vertical: true)
            .padding(.horizontal, 7)
            .padding(.vertical, 4)
            .background {
                Capsule(style: .circular)
                    .foregroundStyle (
                        selectedCategory.getBubbleColor()
                        .shadow(.inner(color: AppColors.blackDefault.opacity(0.15), radius: 2, x: 0, y: 1))
                    )
                    .shadow(color: .white.opacity(0.7), radius: 0, x: 0, y: 1)
            }
    }
}

#Preview {
    BubblesCategory(selectedCategory: TopicCategoryItem.decision, useFullName: true)
}
