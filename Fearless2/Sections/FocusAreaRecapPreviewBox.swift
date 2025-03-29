//
//  FocusAreaRecapPreviewBox.swift
//  Fearless2
//
//  Created by Yue Deng-Wu on 11/7/24.
//

import SwiftUI

struct FocusAreaRecapPreviewBox: View {
    
    let focusAreaCompleted: Bool
    let available: Bool
    let buttonAction: () -> Void
    
    var body: some View {
        VStack (spacing: 5) {
           
            Text("Recap")
                .font(.system(size: 17, weight: focusAreaCompleted ? .light : (available ? .regular : .light)))
                .fontWidth(.condensed)
                .foregroundStyle(focusAreaCompleted ? AppColors.textPrimary : (available ? Color.black : AppColors.textPrimary))
                .padding(.bottom, 5)
            
            LaurelItem(size: 15, points: "+1", primaryColor: focusAreaCompleted ? AppColors.textPrimary : (available ? Color.black : AppColors.textPrimary))
                .opacity(focusAreaCompleted ? 0.5 : (available ? 0.7 : 0.5))
            
            Spacer()
            
            
           if focusAreaCompleted {
                getImage(name: "checkmark")
            } else if !available {
                getImage(name: "lock.fill")
            } else {
                RoundButton(buttonImage: "arrow.right", buttonAction: {
                    buttonAction()
                })
            }
            
        }
        .opacity(focusAreaCompleted ? 0.8 : (available ? 1 : 0.4))
        .padding()
        .frame(width: 150, height: 180)
        .contentShape(Rectangle())
        .background {
            RoundedRectangle(cornerRadius: 20)
                .stroke(AppColors.strokePrimary.opacity(focusAreaCompleted ? 0.10 : (available ? 0.50 : 0.30)), lineWidth: 1)
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
            .foregroundStyle(focusAreaCompleted ? AppColors.whiteDefault : (available ? Color.black : AppColors.whiteDefault))
            .padding(.bottom)
    }
    
    private func backgroundColor() -> any ShapeStyle {
        switch (focusAreaCompleted, available) {
        
        case (true, _):
            return LinearGradient(
                gradient: Gradient(colors: [Color.white.opacity(0.03), Color.white.opacity(0.06)]),
                startPoint: .bottom,
                endPoint: .top
            )
        case (_, true):
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
        switch ( focusAreaCompleted, available) {
        case (true, _):
            return (Color.black.opacity(0.05), 5, 2)
        case (_, true):
            return (Color.black.opacity(0.30), 15, 3)
        default:
            return (Color.clear, 0, 0)
        }
    }
}

//#Preview {
//    SectionRecapPreviewBox()
//}
