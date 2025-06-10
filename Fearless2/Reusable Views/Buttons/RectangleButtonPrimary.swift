//
//  RectangleButtonPrimary.swift
//  Fearless2
//
//  Created by Yue Deng-Wu on 12/30/24.
//
import Pow
import SwiftUI

enum RectangleButtonColor {
    case yellow
    case white
    case clear
}

struct RectangleButtonPrimary: View {
    @State private var playHapticEffect: Int = 0
    
    let buttonText: String
    let action: () -> Void
    let imageName: String
    let showSkipButton: Bool
    let skipAction: () -> Void
    let disableMainButton: Bool
    let sizeSmall: Bool
    let buttonColor: RectangleButtonColor
    let cornerRadius: CGFloat
    
    let screenWidth = UIScreen.current.bounds.width
    
    init(
        buttonText: String,
        action: @escaping () -> Void,
        imageName: String = "",
        showSkipButton: Bool = false,
        skipAction: @escaping () -> Void = {},
        disableMainButton: Bool = false,
        sizeSmall: Bool = false,
        buttonColor: RectangleButtonColor = .yellow,
        cornerRadius: CGFloat = 15
    ) {
        self.buttonText = buttonText
        self.action = action
        self.imageName = imageName
        self.showSkipButton = showSkipButton
        self.skipAction = skipAction
        self.disableMainButton = disableMainButton
        self.sizeSmall = sizeSmall
        self.buttonColor = buttonColor
        self.cornerRadius = cornerRadius
    }
    
    var body: some View {
        
            HStack (spacing: 10){
                
                if showSkipButton {
                    
                    Button {
                        playHapticEffect += 1
                        skipAction()
                    } label: {
                        Text("Skip")
                            .font(.system(size: 15, weight: .medium))
                            .foregroundStyle(Color.black)
                            .frame(width: 71, height: 55)
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
                    }//button label
                    .buttonStyle(ButtonStylePushDown())
                    .sensoryFeedback(.selection, trigger: playHapticEffect)
                }
                
                
                Button {
                    playHapticEffect += 1
                    action()
                } label: {
                    //wrote it this way to avoid the automatic transition when button changes size
                    if showSkipButton {
                        mainButton(width: screenWidth - 105)
                            .transition(.identity)
                    } else {
                        mainButton(width: screenWidth - 32)
                            .transition(.identity)
                    }
                   
                }//button label
                .buttonStyle(ButtonStylePushDown(isDisabled: disableMainButton))
                .disabled(disableMainButton)
                .sensoryFeedback(.selection, trigger: playHapticEffect)
              
            }//HStack
            .onAppear {
                if playHapticEffect != 0 {
                    playHapticEffect = 0
                }
            }
    }
    
    private func mainButton(width: CGFloat) -> some View {
        HStack {
            
            if !imageName.isEmpty {
                Image(systemName: imageName)
                    .font(.system(size: 15, weight: .medium))
                    .foregroundStyle(Color.black)
            }
            
            Text(buttonText)
                .font(.system(size: sizeSmall ? 13 : 15, weight: .medium))
                .foregroundStyle(buttonColor == .clear ? AppColors.textPrimary : .black)

            
        }//HStack
        .frame(height: 55)
        .frame(maxWidth: width)
        .contentShape(RoundedRectangle(cornerRadius: 15))
        .background {
            RoundedRectangle(cornerRadius: 15)
                .stroke(buttonColor == .clear ? AppColors.textPrimary : Color.clear, lineWidth: 0.5)
                .fill(
                    LinearGradient(
                        gradient: Gradient(colors: getGradientColors()),
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .shadow(color: Color.black.opacity(0.15), radius: 5, x: 0, y: 3)
               
        }
        .opacity(disableMainButton ? 0.3 : 1)
        
    }
    
    func getGradientColors() -> [Color] {
        switch buttonColor {
        case .yellow:
            return [AppColors.buttonYellow1, AppColors.buttonYellow2]
        case .white:
            return [Color.white, AppColors.buttonLightGrey1]
        case .clear:
            return [Color.clear, Color.clear]
        }
    }
}

//#Preview {
//    RectangleButtonYellow()
//}
