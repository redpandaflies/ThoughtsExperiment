//
//  BackgroundSecondary.swift
//  Fearless2
//
//  Created by Yue Deng-Wu on 2/27/25.
//

import SwiftUI

struct BackgroundSecondary<S: ShapeStyle>: ViewModifier {
    let backgroundColor: S
    let height: CGFloat
    let yOffset: CGFloat
    
    init(
        backgroundColor: S,
        height: CGFloat? = nil,
        yOffset: CGFloat? = nil
    ) {
        self.backgroundColor = backgroundColor
        
        // Default to 65% of screen height if no height provided
        let screenHeight = UIScreen.current.bounds.height
        self.height = height ?? (screenHeight * 0.65)
        
        // Default to negative 35% of screen height if no offset provided
        self.yOffset = yOffset ?? (-(screenHeight * 0.35))
        
        
    }
    
    func body(content: Content) -> some View {
        content
            .background(
                AppColors.boxGrey2.opacity(0.95)
                    .blendMode(.colorDodge)
                    .background {
                        BackgroundPrimary(backgroundColor: backgroundColor)
                            .frame(height: height)
                            .offset(y: yOffset)
                    }
                    .ignoresSafeArea()
            )
    }
}

extension View {
    func backgroundSecondary<S: ShapeStyle>(
        backgroundColor: S,
        height: CGFloat? = nil,
        yOffset: CGFloat? = nil
    ) -> some View {
        self.modifier(BackgroundSecondary(
            backgroundColor: backgroundColor,
            height: height,
            yOffset: yOffset
        ))
    }
    
    // Convenience method that directly takes a category name string
        func backgroundSecondary(
            forCategory categoryName: String,
            height: CGFloat? = nil,
            yOffset: CGFloat? = nil
        ) -> some View {
            self.modifier(BackgroundSecondary(
                backgroundColor: Realm.getBackgroundColor(forName: categoryName),
                height: height,
                yOffset: yOffset
            ))
        }

   
}
