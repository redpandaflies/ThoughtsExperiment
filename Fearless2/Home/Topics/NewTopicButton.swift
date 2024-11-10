//
//  NewTopicButton.swift
//  Fearless2
//
//  Created by Yue Deng-Wu on 11/7/24.
//

import SwiftUI

struct RectangleButton: View {
    let buttonName: String
    
    var body: some View {
        HStack {
            Spacer()
            Text(buttonName)
                .font(.system(size: 17, weight: .regular))
                .foregroundStyle(Color.white)
                .opacity(0.6)
            Spacer()
        }
        .padding()
        .contentShape(Rectangle())
        .background {
            RoundedRectangle(cornerRadius: 20)
                .stroke(Color.white.opacity(0.6), lineWidth: 1)
                .shadow(color: Color.black, radius: 20, x: 0, y: 0)
        }
    }
}


