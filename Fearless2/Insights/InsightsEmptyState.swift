//
//  InsightsEmptyState.swift
//  Fearless2
//
//  Created by Yue Deng-Wu on 11/24/24.
//
import OSLog
import SwiftUI

struct InsightsEmptyState: View {
    
    var body: some View {
        
        Text("Explore this topic’s paths to uncover insights. Collect the ones that resonate with you during the path recap.")
            .multilineTextAlignment(.leading)
            .font(.system(size: 13))
            .foregroundStyle(AppColors.whiteDefault.opacity(0.7))
            .padding()
            .background {
                RoundedRectangle(cornerRadius: 10)
                    .stroke(Color.white.opacity(0.2), lineWidth: 0.5)
            }
            
        
    }
}
