//
//  RoundButton.swift
//  Fearless2
//
//  Created by Yue Deng-Wu on 2/12/25.
//

import SwiftUI

struct RoundButton: View {
    
    let buttonImage: String
    let size: CGFloat
    let frameSize: CGFloat
    let buttonAction: () -> Void
    
    init(buttonImage: String, size: CGFloat = 15, frameSize: CGFloat = 50, buttonAction: @escaping () -> Void) {
        self.buttonImage = buttonImage
        self.size = size
        self.frameSize = frameSize
        self.buttonAction = buttonAction
    }
    
    var body: some View {
        
        Button {
            buttonAction()
            
        } label: {
            Image(systemName: buttonImage)
                .font(.system(size: size, weight: .medium))
                .foregroundColor(Color.black)
                .frame(width: frameSize, height: frameSize)
                .background {
                    Circle()
                        .stroke(Color.white.opacity(0.9))
                        .fill(
                            LinearGradient(
                            stops: [
                            Gradient.Stop(color: .white, location: 0.00),
                            Gradient.Stop(color: AppColors.buttonPrimary, location: 1.00),
                            ],
                            startPoint: UnitPoint(x: 0.5, y: 0),
                            endPoint: UnitPoint(x: 0.5, y: 1)
                            )
                        )
                        .shadow(color: Color.black.opacity(0.15), radius: 5, x: 0, y: 3)
                }
        }
       
    }
}

//
//#Preview {
//    NextButtonRound()
//}
