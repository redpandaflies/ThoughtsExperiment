//
//  InfoPrimaryView.swift
//  Fearless2
//
//  Created by Yue Deng-Wu on 3/7/25.
//

import SwiftUI

struct InfoPrimaryView: View {
    @Environment(\.dismiss) var dismiss
        let backgroundColor: Color
        let screenHeight = UIScreen.current.bounds.height
        
        // Customizable properties
        let useIcon: Bool
        let iconName: String?
        let iconWeight: Font.Weight?
        let titleText: String
        let descriptionText: String
        let useRectangleButton: Bool
        let rectangleButtonText: String?
        let roundButtonIcon: String
        let buttonAction: () -> Void
        
    init(backgroundColor: Color,
         useIcon: Bool,
         iconName: String? = nil,
         iconWeight: Font.Weight? = .light,
         titleText: String,
         descriptionText: String,
         useRectangleButton: Bool,
         rectangleButtonText: String? = nil,
         roundButtonIcon: String = "checkmark",
         buttonAction: @escaping () -> Void) {
       
        self.backgroundColor = backgroundColor
        self.useIcon = useIcon
        self.iconName = iconName
        self.iconWeight = iconWeight
        self.titleText = titleText
        self.descriptionText = descriptionText
        self.useRectangleButton = useRectangleButton
        self.rectangleButtonText = rectangleButtonText
        self.roundButtonIcon = roundButtonIcon
        self.buttonAction = buttonAction
    }
        
        
        var body: some View {
            VStack(spacing: 5) {
                
                if useIcon {
                    Image(systemName: iconName ?? "safari.fill")
                        .font(.system(size: 50, weight: iconWeight))
                        .foregroundStyle(AppColors.textPrimary)
                        .padding(.bottom, 35)
                } else {
                    LaurelWreath()
                }
                
                Text(titleText)
                    .multilineTextAlignment(.center)
                    .font(.system(size: 25, design: .serif))
                    .foregroundStyle(AppColors.textPrimary)
                    .lineSpacing(1.4)
                    .padding(.bottom, 20)
                
                Text(descriptionText)
                    .multilineTextAlignment(.center)
                    .font(.system(size: 17, weight: .light))
                    .foregroundStyle(AppColors.textPrimary)
                    .lineSpacing(1.4)
                   
                Spacer()
                
                if useRectangleButton {
                    RectangleButtonPrimary(
                        buttonText: rectangleButtonText ?? "Continue",
                        action: {
                            executeButtonAction()
                        },
                        buttonColor: .white
                    )
                } else {
                    RoundButton(
                        buttonImage: roundButtonIcon,
                        size: 30,
                        frameSize: 80,
                        buttonAction: {
                            executeButtonAction()
                        }
                    )
                }
            }
            .padding(.horizontal, 30)
            .padding(.top, 60)
            .padding(.bottom, 40)
            .frame(maxWidth: .infinity)
            .backgroundSecondary(backgroundColor: backgroundColor, height: screenHeight * 0.65, yOffset: -(screenHeight * 0.3))
        }
    
    private func executeButtonAction() {
        dismiss()
        buttonAction()
    }
}

//#Preview {
//    InfoPrimaryView()
//}
