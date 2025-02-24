//
//  AddTopicButton.swift
//  Fearless2
//
//  Created by Yue Deng-Wu on 11/24/24.
//

import SwiftUI


struct AddTopicButton: View {
    
    let frameWidth: CGFloat
    let noTopics: Bool
    let buttonAction: () -> Void

    
    let buttonWidth: CGFloat = 200
    var buttonOutsideFrameWidth: CGFloat {
        let difference = (frameWidth - buttonWidth)/2
        return buttonWidth + difference
    }
    
    var body: some View {
        
        HStack {
            
            
            
            VStack {
                
                Text("Choose your next quest")
                    .multilineTextAlignment(.center)
                    .foregroundStyle(AppColors.textBlack)
                    .font(.system(size: 21))
                    .fontWidth(.condensed)
                    .lineSpacing(1.3)
                    .padding(.horizontal)
                
                
                Spacer()
                
                RoundButton(buttonImage: "plus", buttonAction: {
                    buttonAction()
                })
                
                
                
            }
            .padding(.vertical, 30)
            .frame(width: buttonWidth, height: 220)
            .contentShape(RoundedRectangle(cornerRadius: 25))
            .background {
                RoundedRectangle(cornerRadius: 15)
                    .stroke(AppColors.strokePrimary.opacity(0.50), lineWidth: 0.5)
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: [AppColors.boxYellow1, AppColors.boxYellow2]),
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .shadow(color: Color.black.opacity(0.30), radius: 15, x: 0, y: 3)
            }
            
           
            if !noTopics {
                Spacer()
            }
        
        }
        .frame(width: !noTopics ? buttonOutsideFrameWidth : frameWidth)
    }
}

//#Preview {
//    AddTopicButton()
//}
