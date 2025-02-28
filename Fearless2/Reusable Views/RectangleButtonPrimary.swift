//
//  RectangleButtonPrimary.swift
//  Fearless2
//
//  Created by Yue Deng-Wu on 12/30/24.
//

import SwiftUI

enum RectangleButtonColor {
    case yellow
    case white
}

struct RectangleButtonPrimary: View {
    let buttonText: String
    let action: () -> Void
    let showChevron: Bool
    let showSkipButton: Bool
    let skipAction: () -> Void
    let disableMainButton: Bool
    let sizeSmall: Bool
    let buttonColor: RectangleButtonColor
    
    init(
        buttonText: String,
        action: @escaping () -> Void,
        showChevron: Bool = false,
        showSkipButton: Bool = false,
        skipAction: @escaping () -> Void = {},
        disableMainButton: Bool = false,
        sizeSmall: Bool = false,
        buttonColor: RectangleButtonColor = .yellow
    ) {
        self.buttonText = buttonText
        self.action = action
        self.showChevron = showChevron
        self.showSkipButton = showSkipButton
        self.skipAction = skipAction
        self.disableMainButton = disableMainButton
        self.sizeSmall = sizeSmall
        self.buttonColor = buttonColor
    }
    
    var body: some View {
        
        HStack {
            
            if showSkipButton {
              
                Text("Skip")
                    .font(.system(size: 15, weight: .medium))
                    .foregroundStyle(Color.black)
                    .padding(.horizontal, 20)
                    .frame(height: 55)
                    .contentShape(RoundedRectangle(cornerRadius: 15))
                    .background {
                        RoundedRectangle(cornerRadius: 15)
                            .stroke(Color.white.opacity(0.9), lineWidth: 1)
                            .fill(
                                LinearGradient(
                                    gradient: Gradient(colors: [Color.white, AppColors.buttonLightGrey1]),
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                            )
                            .shadow(color: Color.black.opacity(0.15), radius: 5, x: 0, y: 3)
                    }
                    .onTapGesture {
                        skipAction()
                    }
            }
            
          
            HStack {
                
                Spacer()
                
                Text(buttonText)
                    .font(.system(size: sizeSmall ? 13 : 15, weight: .medium))
                    .foregroundStyle(Color.black)
                
                if showChevron {
                    Image(systemName: "chevron.right")
                        .font(.system(size: 15, weight: .medium))
                        .foregroundStyle(Color.black)
                }
                
                Spacer()
                
            }//HStack
            .padding(.horizontal, 20)
            .frame(height: 55)
            .contentShape(RoundedRectangle(cornerRadius: 15))
            .background {
                RoundedRectangle(cornerRadius: 15)
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: buttonColor == .yellow ? [AppColors.buttonYellow1, AppColors.buttonYellow2] : [Color.white, AppColors.buttonLightGrey1]),
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .shadow(color: Color.black.opacity(0.15), radius: 5, x: 0, y: 3)
            }
            .opacity(disableMainButton ? 0.3 : 1)
            .onTapGesture {
                if !disableMainButton {
                    action()
                }
            }
        }
    }
    
    
}

//#Preview {
//    RectangleButtonYellow()
//}
