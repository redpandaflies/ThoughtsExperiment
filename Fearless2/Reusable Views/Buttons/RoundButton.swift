//
//  RoundButton.swift
//  Fearless2
//
//  Created by Yue Deng-Wu on 2/12/25.
//
import Pow
import SwiftUI

enum RoundButtonColor {
    case white
    case dark
}

struct RoundButton: View {
    
    @State private var playHapticEffect: Int = 0
    
    let buttonImage: String
    let size: CGFloat
    let frameSize: CGFloat
    let buttonAction: () -> Void
    let disableButton: Bool
    let buttonColor: RoundButtonColor
    
    init(buttonImage: String, size: CGFloat = 15, frameSize: CGFloat = 50, buttonAction: @escaping () -> Void = {}, disableButton: Bool = false, buttonColor: RoundButtonColor = .white) {
        self.buttonImage = buttonImage
        self.size = size
        self.frameSize = frameSize
        self.buttonAction = buttonAction
        self.disableButton = disableButton
        self.buttonColor = buttonColor
    }
    
    var body: some View {
        
        Button {
            playHapticEffect += 1
            buttonAction()
          
        } label: {
            Image(systemName: buttonImage)
                .font(.system(size: size, weight: .medium))
                .foregroundColor(buttonColor == .white ? Color.black : AppColors.textPrimary)
                .frame(width: frameSize, height: frameSize)
                .opacity(disableButton ? 0.3: 1)
                .background {
                    Circle()
                        .stroke(disableButton || buttonColor == .dark ? Color.white.opacity(0.1) : Color.white.opacity(0.9))
                        .fill(
                            LinearGradient(
                            stops: [
                                Gradient.Stop(color: buttonColor == .white ? .white : AppColors.buttonBlack1, location: 0.00),
                                Gradient.Stop(color: buttonColor == .white ? AppColors.buttonPrimary : AppColors.buttonBlack2, location: 1.00),
                            ],
                            startPoint: UnitPoint(x: 0.5, y: 0),
                            endPoint: UnitPoint(x: 0.5, y: 1)
                            )
                        )
                        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 3)
                        .opacity(disableButton ? 0.3: 1)
                        .blendMode(buttonColor == .white ? .normal : .plusLighter)
                        
                }
               
        }
        .buttonStyle(ButtonStylePushDown(isDisabled: disableButton))
        .disabled(disableButton)
        .sensoryFeedback(.selection, trigger: playHapticEffect)
        .onAppear {
            if playHapticEffect != 0 {
                playHapticEffect = 0
            }
        }
       
       
    }
}



//
//#Preview {
//    NextButtonRound()
//}
