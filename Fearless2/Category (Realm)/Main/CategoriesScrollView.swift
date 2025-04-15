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
    let totalTopics: Int
    
    let frameWidth: CGFloat = 100
    var safeAreaPadding: CGFloat {
        return (UIScreen.main.bounds.width - frameWidth)/2
    }
    
    private let hapticImpact = UIImpactFeedbackGenerator(style: .medium)
    
    var body: some View {
        
        ScrollView(.horizontal, showsIndicators: false) {
            HStack (alignment: .center, spacing: 12) {
                
                getIcon(index: 0, icon: "realm66" )
                
                ForEach(Array(categories.enumerated()), id: \.element.categoryId) { index, category in
                    getIcon(index: index + 1, icon: category.categoryEmoji)
                 
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
    
    private func getIcon(index: Int, icon: String) -> some View {
        Image(icon)
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(width: getFrameSize(for: index))
//            .scaleEffect(getScaleFactor(for: index))
            .id(index)
            .scrollTransition { content, phase in
                content
                    .opacity(phase.isIdentity ? 1 : 0.75)
                    .blur(radius: phase.isIdentity ? 0 : 3)
                    .scaleEffect(phase.isIdentity ? 1 : 0.6)
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
        let maxScale: CGFloat = 0.65
        let minScale: CGFloat = 0.43
        let scaleDrop: CGFloat = 0.22
        
        var calculatedScale: CGFloat = 1
        
        if index != currentPosition {
            calculatedScale = maxScale - CGFloat(distance) * scaleDrop
        }
        // Ensure the scale doesn't go below minimum
        return max(calculatedScale, minScale)
    }
    
    private func getOpacity(for index: Int) -> CGFloat {
        guard let currentPosition = categoriesScrollPosition else {
            return 0.9 // Default scale when no position is selected
        }
        
        // Calculate the distance from the selected item
        let distance = abs(index - currentPosition)
        
        // The selected item (distance = 0) gets scale 1.0
        // Each step away reduces scale progressively
        let maxOpacity: CGFloat = 0.9
        let minOpacity: CGFloat = 0.0
        let opacityDrop: CGFloat = 0.3
        
        var calculatedOpacity: CGFloat = 1
        
        if index != currentPosition {
            calculatedOpacity = maxOpacity - CGFloat(distance) * opacityDrop
        }
        
        // Ensure the scale doesn't go below minimum
        return max(calculatedOpacity, minOpacity)
    }
    
    private func getFrameSize(for index: Int) -> CGFloat {
        guard let currentPosition = categoriesScrollPosition else {
            return 90 // Default scale when no position is selected
        }
        
        // Calculate the distance from the selected item
//        let distance = abs(index - currentPosition)
        
        // The selected item (distance = 0) gets scale 1.0
        // Each step away reduces scale progressively
//        let maxFrame: CGFloat = 65
        let minFrame: CGFloat = 40
//        let frameDrop: CGFloat = 22
        
        var calculatedFrame: CGFloat = 100
        
        if index != currentPosition {
//            calculatedFrame = maxFrame - CGFloat(distance) * frameDrop
            calculatedFrame = 65
        }
        
        // Ensure the scale doesn't go below minimum
        return max(calculatedFrame, minFrame)
    }
    
    private func getBlur(for index: Int) -> CGFloat {
        guard let currentPosition = categoriesScrollPosition else {
            return 0 // Default blur when no position is selected
        }
        
        // Calculate the distance from the selected item
        let distance = abs(index - currentPosition)
        
        // The selected item (distance = 0) gets minimum blur
        // Each step away increases blur progressively
        let minBlur: CGFloat = 0
        let maxBlur: CGFloat = 10
        let blurIncrease: CGFloat = 5
        
        var calculatedBlur: CGFloat = minBlur
        
        if index != currentPosition {
            calculatedBlur = minBlur + CGFloat(distance) * blurIncrease
        }
        
        // Ensure the blur doesn't exceed maximum
        return min(calculatedBlur, maxBlur)
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
