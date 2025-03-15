//
//  CategoriesScrollView.swift
//  Fearless2
//
//  Created by Yue Deng-Wu on 2/7/25.
//

import SwiftUI

struct CategoriesScrollView: View {
    
    @Binding var categoriesScrollPosition: Int?
    @Binding var isProgrammaticScroll: Bool
    
    var categories: FetchedResults<Category>
    let lockedCategories: [Realm]
    let totalTopics: Int
    
    let frameWidth: CGFloat = 50
    var safeAreaPadding: CGFloat {
        return (UIScreen.main.bounds.width - frameWidth)/2
    }
    
    private let hapticImpact = UIImpactFeedbackGenerator(style: .medium)
    
    var body: some View {
        
        ScrollView(.horizontal, showsIndicators: false) {
            HStack (alignment: .center, spacing: 15) {
                
                ForEach(Array(categories.enumerated()), id: \.element.categoryId) { index, category in
                    getEmoji(index: index, emoji: category.categoryEmoji)
                 
                }
                
                if totalTopics > 0 {
                    ForEach(Array(lockedCategories.enumerated()), id: \.element.orderIndex) { index, category in
                        getEmoji(index: categories.count + index, emoji: "🗝️")
                    }
                }
            }
            .scrollTargetLayout()
        }
        .scrollPosition(id: $categoriesScrollPosition, anchor: .center)
        .contentMargins(.horizontal, safeAreaPadding, for: .scrollContent)
        .scrollClipDisabled(true)
        .scrollTargetBehavior(.viewAligned)
        .onChange(of: categoriesScrollPosition) {
            if !isProgrammaticScroll {
                hapticImpact.prepare()
                hapticImpact.impactOccurred(intensity: 0.7)
            } else {
                isProgrammaticScroll = false
            }
        }
       
    }
    
    private func getEmoji(index: Int, emoji: String) -> some View {
        Text(emoji)
            .id(index)
            .font(.system(size: 50))
            .frame(width: frameWidth)
            .scaleEffect(getScaleFactor(for: index))
            .scrollTransition { content, phase in
                content
                    .opacity(phase.isIdentity ? 1 : 0.75)
                    .blur(radius: phase.isIdentity ? 0 : 3)
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
    
    private func getLockedCategories() -> [Realm] {
        let existingCategories = categories.compactMap { category in
            return category.categoryName
        }
        
        let undiscoveredCategories = Realm.realmsData.filter { realm in
            !existingCategories.contains(realm.name)
        }
        
        return undiscoveredCategories
        
    }
}
