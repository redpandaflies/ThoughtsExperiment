//
//  SelectButtonRound.swift
//  Fearless2
//
//  Created by Yue Deng-Wu on 2/12/25.
//

import SwiftUI

struct SelectButtonRound: View {
    let buttonAction: () -> Void
    
    var body: some View {
        
        Button {
            buttonAction()
            
        } label: {
            Image(systemName: "checkmark")
                .font(.system(size: 15, weight: .medium))
                .foregroundColor(Color.black)
                .padding(15)
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
