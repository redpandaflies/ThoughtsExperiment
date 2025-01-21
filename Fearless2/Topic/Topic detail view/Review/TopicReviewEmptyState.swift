//
//  TopicReviewEmptyState.swift
//  Fearless2
//
//  Created by Yue Deng-Wu on 1/15/25.
//

import SwiftUI

struct TopicReviewEmptyState: View {
    
    let text: String
    
    var body: some View {
        
        HStack {
           
            Text(text)
                .multilineTextAlignment(.leading)
                .font(.system(size: 13))
                .foregroundStyle(AppColors.whiteDefault.opacity(0.7))
               
           
            Spacer()
        }
        .padding()
        .background {
            RoundedRectangle(cornerRadius: 10)
                .stroke(Color.white.opacity(0.2), lineWidth: 0.5)
        }
    }
}
