//
//  WhyBox.swift
//  Fearless2
//
//  Created by Yue Deng-Wu on 11/24/24.
//

import SwiftUI

struct WhyBox: View {
    let text: String
    let backgroundColor: Color
    
    var body: some View {
        VStack (spacing: 7) {
            Text("Why")
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(Color.white)
                .textCase(.uppercase)
                .opacity(0.5)
            
            Text(text)
                .multilineTextAlignment(.center)
                .font(.system(size: 13))
                .foregroundStyle(Color.white)
                .lineSpacing(0.5)
                .opacity(0.8)
            
        }
        .padding()
        .background {
            RoundedRectangle(cornerRadius: 15)
                .fill(backgroundColor)
        }
    }
}

//#Preview {
//    WhyBox()
//}
