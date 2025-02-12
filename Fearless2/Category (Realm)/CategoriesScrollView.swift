//
//  CategoriesScrollView.swift
//  Fearless2
//
//  Created by Yue Deng-Wu on 2/7/25.
//

import SwiftUI

struct CategoriesScrollView: View {
    
    @Binding var categoriesScrollPosition: Int?
    var categories: FetchedResults<Category>
    
    let frameWidth: CGFloat = 50
    var safeAreaPadding: CGFloat {
        return (UIScreen.main.bounds.width - frameWidth)/2
    }
    
    var body: some View {
        
        ScrollView(.horizontal, showsIndicators: false) {
            HStack (alignment: .center, spacing: 15) {
                
                ForEach(Array(categories.enumerated()), id: \.element.categoryId) { index, category in
                    Text(category.categoryEmoji)
                        .id(index)
                        .font(.system(size: index == categoriesScrollPosition ? 45 : 35))
                        .frame(width: frameWidth)
                        .scrollTransition { content, phase in
                            content
                                .opacity(phase.isIdentity ? 1 : 0.5)
                                .scaleEffect(y: phase.isIdentity ? 1 : 0.85)
                                .blur(radius: phase.isIdentity ? 0 : 5)
                        }
                 
                }
            }
            .scrollTargetLayout()
        }
        .scrollPosition(id: $categoriesScrollPosition, anchor: .center)
        .contentMargins(.horizontal, safeAreaPadding, for: .scrollContent)
        .scrollClipDisabled(true)
        .scrollTargetBehavior(.viewAligned)
       
       
    }
    
}
