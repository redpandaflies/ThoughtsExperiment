//
//  RetryButton.swift
//  Fearless2
//
//  Created by Yue Deng-Wu on 11/24/24.
//

import SwiftUI

struct RetryButton: View {
    
    let action: () -> Void
    
    var body: some View {
        Button {
            action()
            
        } label: {
            VStack (spacing: 10) {
                Image(systemName: "arrow.clockwise")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundStyle(AppColors.whiteDefault)
                    .textCase(.uppercase)
                    .opacity(0.5)
                
                Text("Tap to try again.\nGive it a few seconds.")
                    .multilineTextAlignment(.center)
                    .font(.system(size: 13))
                    .foregroundStyle(AppColors.whiteDefault)
                    .lineSpacing(0.5)
                    .opacity(0.8)
                
            }
            .padding()
            .contentShape(Rectangle())
        }
       
    }
}

//#Preview {
//    WhyBox()
//}
