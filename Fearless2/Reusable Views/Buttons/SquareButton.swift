//
// SquareButton.swift
//  Fearless2
//
//  Created by Yue Deng-Wu on 2/12/25.
//
import SwiftUI

struct SquareButton: View {
    
    @State private var playHapticEffect: Int = 0
    
    let buttonImage: String
    let size: CGFloat
    let frameSize: CGFloat
    let buttonAction: () -> Void
    
    init(
        buttonImage: String,
        size: CGFloat = 23,
        frameSize: CGFloat = 60,
        buttonAction: @escaping () -> Void = {}
    ) {
        self.buttonImage = buttonImage
        self.size = size
        self.frameSize = frameSize
        self.buttonAction = buttonAction
    }
    
    var body: some View {
        
        Button {
            playHapticEffect += 1
            buttonAction()
          
        } label: {
            Image(systemName: buttonImage)
                .font(.system(size: size, weight: .medium))
                .foregroundColor(Color.black)
                .frame(width: frameSize, height: frameSize)
                .background {
                    RoundedRectangle(cornerRadius: 15)
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
                        .padding(5)
                        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 3)
                        .background {
                            RoundedRectangle(cornerRadius: 18)
                                .stroke(AppColors.textSecondary.opacity(0.1))
                                .fill(AppColors.boxGrey1.opacity(0.3))
                                .shadow(color: Color.black.opacity(0.5), radius: 15, x: 0, y: 3)
                                .blendMode(.colorDodge)
                        }
                        
                }
               
        }
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
