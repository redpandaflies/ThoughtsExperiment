//
//  RectangleButton.swift
//  Fearless2
//
//  Created by Yue Deng-Wu on 11/7/24.
//

import SwiftUI

struct RectangleButton: View {
    let buttonName: String
    let buttonColor: Color
    
    var body: some View {
        HStack {
            Spacer()
            Text(buttonName)
                .font(.system(size: 17, weight: .regular))
                .foregroundStyle(buttonColor)
                .opacity(0.6)
            Spacer()
        }
        .padding()
        .contentShape(Rectangle())
        .background {
            RoundedRectangle(cornerRadius: 20)
                .stroke(buttonColor)
                .shadow(color: Color.black, radius: 20, x: 0, y: 0)
        }
    }
}


