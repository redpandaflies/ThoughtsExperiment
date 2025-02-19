//
//  PageIndicatorView.swift
//  Fearless2
//
//  Created by Yue Deng-Wu on 2/10/25.
//

import SwiftUI

struct PageIndicatorView: View {
    
    @Binding var scrollPosition: Int?
    
    let pagesCount: Int
    
    var body: some View {
       
        HStack(spacing: 5) {
            ForEach(0..<pagesCount, id: \.self) { index in
                Circle()
                    .stroke(AppColors.textSecondary, lineWidth: 0.5)
                    .fill(getDotColor(index: index))
                    .frame(width: 10, height: 10)
                    .opacity(0.5)
                
            }
        }//HStack
        
    }
    
    private func getDotColor(index: Int) -> Color {
        (index == scrollPosition ?? 0) ? AppColors.textSecondary : Color.clear
       }
}
