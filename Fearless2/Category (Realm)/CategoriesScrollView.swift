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
    
    private let hapticImpact = UIImpactFeedbackGenerator(style: .medium)
    
    var body: some View {
        
        ScrollView(.horizontal, showsIndicators: false) {
            HStack (alignment: .center, spacing: 15) {
                
                ForEach(Array(categories.enumerated()), id: \.element.categoryId) { index, category in
                    getEmoji(index: index, category: category)
                 
                }
                
                if categories.count < 7 {
                    getEmoji(index: categories.count)
                }
            }
            .scrollTargetLayout()
        }
        .scrollPosition(id: $categoriesScrollPosition, anchor: .center)
        .contentMargins(.horizontal, safeAreaPadding, for: .scrollContent)
        .scrollClipDisabled(true)
        .scrollTargetBehavior(.viewAligned)
        .onChange(of: categoriesScrollPosition) {
            hapticImpact.prepare()
            hapticImpact.impactOccurred(intensity: 0.7)
        }
       
    }
    
    private func getEmoji(index: Int, category: Category? = nil) -> some View {
        Text(category?.categoryEmoji ?? "❓")
            .id(index)
            .font(.system(size: 50))
            .frame(width: frameWidth)
            .scaleEffect(getScaleFactor(for: index))
            .scrollTransition { content, phase in
                content
                    .opacity(phase.isIdentity ? 1 : 0.5)
                    .blur(radius: phase.isIdentity ? 0 : 5)
            }
    }
    
    private func getScaleFactor(for index: Int) -> CGFloat {
        guard let currentPosition = categoriesScrollPosition else {
            return 0.9 // Default scale when no position is selected
        }
        
        // Calculate the distance from the selected item
        let distance = abs(index - currentPosition)
        
        // The selected item (distance = 0) gets scale 1.0
        // Each step away reduces scale progressively
        let maxScale: CGFloat = 0.8
        let minScale: CGFloat = 0.35
        let scaleDrop: CGFloat = 0.15
        
        var calculatedScale: CGFloat = 1
        
        if index != currentPosition {
            calculatedScale = maxScale - CGFloat(distance) * scaleDrop
        }
        // Ensure the scale doesn't go below minimum
        return max(calculatedScale, minScale)
    }
}
