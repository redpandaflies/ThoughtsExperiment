//
//  ProgressBarThin.swift
//  Fearless2
//
//  Created by Yue Deng-Wu on 4/26/25.
//

import SwiftUI

struct ProgressBarThin: View {
    let totalTopics: Int
    let totalCompletedTopics: Int
    
    var body: some View {
        GeometryReader { geo in
            // total width available
            let fullWidth = geo.size.width
            // minimum “tap‐target” width (5% of the bar)
            let minWidth = fullWidth * 0.05
            // proportional width based on progress
            let filledWidth: CGFloat = {
                guard totalTopics > 0 else { return minWidth }
                let step   = fullWidth / CGFloat(totalTopics)
                let width  = step * CGFloat(totalCompletedTopics)
                return max(width, minWidth)
            }()
            ZStack (alignment: .leading) {
                RoundedRectangle(cornerRadius: 50)
                    .fill(AppColors.progressBarPrimary.opacity(0.3))
                    .frame(height: 2)
                    .frame(maxWidth: .infinity)
                
                
                RoundedRectangle(cornerRadius: 50)
                    .fill(AppColors.progressBarPrimary)
                    .frame(width: filledWidth, height: 2)
                    .contentTransition(.interpolate)
                
            }//ZStack
            .frame(maxHeight: .infinity, alignment: .center)
            
        }
    }
}

