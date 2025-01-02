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
        VStack (spacing: 30) {
            Text("Uncover insights by logging your\nthoughts on this topic and\nexploring its path.")
                .multilineTextAlignment(.center)
                .font(.system(size: 22))
                .foregroundStyle(AppColors.whiteDefault)
            
            WhyBox(text: "Insights reveal patterns and opportunities.\nThey help you reflect, grow, and take\nmeaningful action.", backgroundColor: AppColors.black2)
            
        }
    }
}
