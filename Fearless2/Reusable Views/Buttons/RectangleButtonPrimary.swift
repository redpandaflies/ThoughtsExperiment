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
    case clearStroke
    case clearNoStroke
    case blendDark
}

enum DeepDiveButtonState {
    case diveDeeper
    case goToTopic
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
    
    /// dive deeper button
    let showDiveDeeperButton: Bool
    let diveDeeperButtonState: DeepDiveButtonState
    let diveDeeperAction: () -> Void
    
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
        cornerRadius: CGFloat = 15,
        showDiveDeeperButton: Bool = false,
        diveDeeperButtonState: DeepDiveButtonState = .diveDeeper,
        diveDeeperAction: @escaping () -> Void = {}
       
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
        
        /// dive deeper button
        self.showDiveDeeperButton = showDiveDeeperButton
        self.diveDeeperButtonState = diveDeeperButtonState
        self.diveDeeperAction = diveDeeperAction
    }
    
    var body: some View {
        
        HStack (spacing: 10){
            
            /// Skip button for questions
            if showSkipButton {
                skipButton()
            }
            
            
            /// Main button
            mainButton()
            
            /// Dive deeper button for daily topics
            if showDiveDeeperButton {
                diveDeeperButton()
            }
            
        }//HStack
        .onAppear {
            if playHapticEffect != 0 {
                playHapticEffect = 0
            }
        }
    }
    
    // MARK: Main button
    private func mainButton() -> some View {
        Button {
            playHapticEffect += 1
            action()
        } label: {
            //wrote it this way to avoid the automatic transition when button changes size
            if showSkipButton {
                mainButtonUI(width: screenWidth - 105)
                    .transition(.identity)
            } else if showDiveDeeperButton {
                mainButtonUI(width: screenWidth - 160)
                    .transition(.identity)
            } else {
                mainButtonUI(width: screenWidth - 32)
                    .transition(.identity)
            }
           
        }//button label
        .buttonStyle(ButtonStylePushDown(isDisabled: disableMainButton))
        .disabled(disableMainButton)
        .sensoryFeedback(.selection, trigger: playHapticEffect)
    }
    
    
    private func mainButtonUI(width: CGFloat) -> some View {
        HStack {
            
            if !imageName.isEmpty {
                Image(systemName: imageName)
                    .font(.system(size: 15))
                    .foregroundStyle(getTextColor)
            }
            
            Text(buttonText)
                .font(.system(size: sizeSmall ? 13 : 15, weight: buttonColor == .clearNoStroke || buttonColor == .blendDark ? .light : .medium))
                .foregroundStyle(getTextColor)

            
        }//HStack
        .frame(height: 55)
        .frame(maxWidth: width)
        .contentShape(RoundedRectangle(cornerRadius: cornerRadius))
        .background {
            RoundedRectangle(cornerRadius: cornerRadius)
                .stroke(buttonColor == .clearStroke ? AppColors.textPrimary : Color.clear, lineWidth: 0.5)
                .fill(getGradientStyle())
                .shadow(color: buttonColor == .clearStroke || buttonColor == .clearNoStroke ? Color.clear : Color.black.opacity(0.15), radius: 5, x: 0, y: 3)
                .blendMode(buttonColor == .blendDark ? .colorDodge : .normal)
               
        }
        .opacity(disableMainButton ? 0.3 : 1)
        
    }
    
    // main button styling
    private var getTextColor: Color {
        switch buttonColor {
        case .yellow, .white:
            Color.black
        case .clearNoStroke:
            AppColors.textPrimary.opacity(0.7)
        default:
            AppColors.textPrimary
        }
    }
    
    // Replace your old getGradientColors() with this:
    private func getGradientStyle() -> AnyShapeStyle {
        switch buttonColor {
        case .yellow:
            return AnyShapeStyle(
                LinearGradient(
                    gradient: Gradient(colors: [AppColors.buttonYellow1, AppColors.buttonYellow2]),
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
            
        case .white:
            return AnyShapeStyle(
                LinearGradient(
                    gradient: Gradient(colors: [Color.white, AppColors.buttonLightGrey1]),
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
            
        case .clearStroke, .clearNoStroke:
            return AnyShapeStyle(Color.clear)
        
        case .blendDark:
            return AnyShapeStyle(AppColors.boxGrey1.opacity(0.3))
        }
    }
    
    // MARK: skip button
    private func skipButton() -> some View {
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
    
    // MARK: dive deeper button
    private func diveDeeperButton() -> some View {
        Button {
            diveDeeperAction()
        } label: {
            HStack (spacing: 5) {
                Image(systemName: "square.2.layers.3d.bottom.filled")
                    .font(.system(size: 20, weight: .medium))
                    .foregroundStyle(Color.black)
                
                Text(diveDeeperButtonState == .diveDeeper ? "Go deeper" : "Go to topic" )
                    .font(.system(size: 15, weight: .medium))
                    .foregroundStyle(Color.black)
                
            }
            .frame(width: 160, height: 55)
            .contentShape(RoundedRectangle(cornerRadius: 10))
            .background {
                RoundedRectangle(cornerRadius: 10)
                    .stroke(Color.white.opacity(0.9), lineWidth: 1)
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: [AppColors.buttonYellow1, AppColors.buttonYellow2]),
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
}

