//
//  RectangleButton.swift
//  Fearless2
//
//  Created by Yue Deng-Wu on 11/7/24.
//

import SwiftUI

struct RectangleButton: View {
    let buttonName: String?
    let buttonImage: String?
    let buttonColor: Color
    let backgroundColor: Color?

    init(buttonName: String? = nil, buttonImage: String? = nil, buttonColor: Color, backgroundColor: Color? = nil) {
        self.buttonName = buttonName
        self.buttonImage = buttonImage
        self.buttonColor = buttonColor
        self.backgroundColor = backgroundColor
    }
    
    var body: some View {
        HStack {
            Spacer()
            
            Group {
                if let currentButtonName = buttonName {
                    Text(currentButtonName)
                        .font(.system(size: 17, weight: .regular))
                } else if let currentButtonImage = buttonImage {
                    Image(systemName: currentButtonImage)
                        .font(.system(size: 30, weight: .regular))
                }
            }
            .foregroundStyle(buttonColor)
               
            Spacer()
        }
        .padding()
        .contentShape(Rectangle())
        .background {
            RoundedRectangle(cornerRadius: 15)
                .stroke(buttonColor)
                .foregroundStyle(backgroundColor ?? Color.clear)
                .shadow(color: Color.black, radius: 20, x: 0, y: 0)
        }
    }
}


