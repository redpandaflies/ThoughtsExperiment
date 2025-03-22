//
//  FocusAreaRecapPreviewBox.swift
//  Fearless2
//
//  Created by Yue Deng-Wu on 11/7/24.
//

import SwiftUI

struct FocusAreaRecapPreviewBox: View {
    
    let choseSuggestion: Bool
    let focusAreaCompleted: Bool
    let available: Bool
    let buttonAction: () -> Void
    
    var body: some View {
        VStack (spacing: 5) {
           
            Text("Recap")
                .font(.system(size: 17, weight: (!choseSuggestion && focusAreaCompleted) ? .regular : ( focusAreaCompleted ? .light : (available ? .regular : .light))))
                .fontWidth(.condensed)
                .foregroundStyle((!choseSuggestion && focusAreaCompleted) ? Color.black : (focusAreaCompleted ? AppColors.textPrimary : (available ? Color.black : AppColors.textPrimary)))
                .padding(.bottom, 5)
            
            LaurelItem(size: 15, points: "+1", primaryColor: (!choseSuggestion && focusAreaCompleted) ? Color.black : (focusAreaCompleted ? AppColors.textPrimary : (available ? Color.black : AppColors.textPrimary)))
                .opacity((!choseSuggestion && focusAreaCompleted) ? 0.7 : (focusAreaCompleted ? 0.5 : (available ? 0.7 : 0.5)))
            
            Spacer()
            
            
            if !choseSuggestion && focusAreaCompleted {
                RoundButton(buttonImage: "arrow.right", buttonAction: {
                    buttonAction()
                })
            } else if focusAreaCompleted {
                getImage(name: "checkmark")
            } else if !available {
                getImage(name: "lock.fill")
            } else {
                RoundButton(buttonImage: "arrow.right", buttonAction: {
                    buttonAction()
                })
            }
            
        }
        .opacity((!choseSuggestion && focusAreaCompleted) ? 1 : (focusAreaCompleted ? 0.8 : (available ? 1 : 0.4)))
        .padding()
        .frame(width: 150, height: 180)
        .contentShape(Rectangle())
        .background {
            RoundedRectangle(cornerRadius: 20)
                .stroke(AppColors.strokePrimary.opacity((!choseSuggestion && focusAreaCompleted) ? 0.5 : (focusAreaCompleted ? 0.20 : (available ? 0.50 : 0.30))), lineWidth: 1)
                .fill(AnyShapeStyle(backgroundColor()))
                .shadow(
                    color: shadowProperties().color,
                    radius: shadowProperties().radius,
                    x: 0,
                    y: shadowProperties().y
                )
        }
    }
    
    private func getImage(name: String) -> some View {
        Image(systemName: name)
            .font(.system(size: 25))
            .foregroundStyle((!choseSuggestion && focusAreaCompleted) ? Color.black : (focusAreaCompleted ? AppColors.whiteDefault : (available ? Color.black : AppColors.whiteDefault)))
            .padding(.bottom)
    }
    
    private func backgroundColor() -> any ShapeStyle {
        switch (choseSuggestion, focusAreaCompleted, available) {
        case (false, true, _):
            return LinearGradient(
                gradient: Gradient(colors: [AppColors.boxYellow1, AppColors.boxYellow2]),
                startPoint: .top,
                endPoint: .bottom
            )
        
        case (true, true, _):
            return LinearGradient(
                gradient: Gradient(colors: [Color.white.opacity(0.03), Color.white.opacity(0.06)]),
                startPoint: .bottom,
                endPoint: .top
            )
        case (_, _, true):
            return LinearGradient(
                gradient: Gradient(colors: [AppColors.boxYellow1, AppColors.boxYellow2]),
                startPoint: .top,
                endPoint: .bottom
            )
        default:
            return Color.clear
        }
    }

    private func shadowProperties() -> (color: Color, radius: CGFloat, y: CGFloat) {
        switch (choseSuggestion, focusAreaCompleted, available) {
            
        case (false, true, _):
            return (Color.black.opacity(0.30), 15, 3)
        case (true, true, _):
            return (Color.black.opacity(0.05), 5, 2)
        case (_, _, true):
            return (Color.black.opacity(0.30), 15, 3)
        default:
            return (Color.clear, 0, 0)
        }
    }
}

//#Preview {
//    SectionRecapPreviewBox()
//}
