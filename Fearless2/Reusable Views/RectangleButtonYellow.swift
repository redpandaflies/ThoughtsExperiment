//
//  RectangleButtonYellow.swift
//  Fearless2
//
//  Created by Yue Deng-Wu on 12/30/24.
//

import SwiftUI

struct RectangleButtonYellow: View {
    let buttonText: String
    let action: () -> Void
    let showChevron: Bool
    let showBackButton: Bool
    let backAction: () -> Void
    let disableMainButton: Bool
    let sizeSmall: Bool
    
    init(
        buttonText: String,
        action: @escaping () -> Void,
        showChevron: Bool = false,
        showBackButton: Bool = false,
        backAction: @escaping () -> Void = {},
        disableMainButton: Bool = false,
        sizeSmall: Bool = false
    ) {
        self.buttonText = buttonText
        self.action = action
        self.showChevron = showChevron
        self.showBackButton = showBackButton
        self.backAction = backAction
        self.disableMainButton = disableMainButton
        self.sizeSmall = sizeSmall
    }
    
    var body: some View {
        
        HStack {
            
            if showBackButton {
              
                Image(systemName: "chevron.left")
                    .font(.system(size: 15))
                    .foregroundStyle(Color.black)
                    .padding(.horizontal, 20)
                    .frame(height: 55)
                    .contentShape(RoundedRectangle(cornerRadius: 15))
                    .background {
                        RoundedRectangle(cornerRadius: 15)
                            .fill(AppColors.lightGrey1)
                            .shadow(color: AppColors.lightGrey2, radius: 0, x: 0, y: 3)
                    }
                    .onTapGesture {
                        backAction()
                    }
            }
            
          
            HStack {
                
                Spacer()
                
                Text(buttonText)
                    .font(.system(size: sizeSmall ? 13 : 15))
                    .foregroundStyle(Color.black)
                
                if showChevron {
                    Image(systemName: "chevron.right")
                        .font(.system(size: 15))
                        .foregroundStyle(Color.black)
                }
                
                Spacer()
                
            }//HStack
            .padding(.horizontal, 20)
            .frame(height: 55)
            .contentShape(RoundedRectangle(cornerRadius: 15))
            .background {
                RoundedRectangle(cornerRadius: 15)
                    .fill(disableMainButton ?  AppColors.darkGrey1 : AppColors.yellow1)
                    .shadow(color: disableMainButton ? AppColors.darkGrey2 : AppColors.lightBrown2, radius: 0, x: 0, y: 3)
            }
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
