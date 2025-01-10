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
    
    var body: some View {
        VStack (spacing: 5) {
           
            Text("Recap")
                .font(.system(size: 17, weight: .regular))
                .foregroundStyle(focusAreaCompleted ? AppColors.whiteDefault : (available ? Color.black : AppColors.whiteDefault))
            
            Spacer()
            
            if focusAreaCompleted {
                getImage(name: "checkmark")
            } else if !available {
                getImage(name: "lock.fill")
            } else {
                getImage(name: "arrow.forward.circle.fill")
            }
            
        }
        .opacity(focusAreaCompleted ? 0.6 : (available ? 1 : 0.4))
        .padding()
        .frame(width: 150, height: 180)
        .contentShape(Rectangle())
        .background {
            RoundedRectangle(cornerRadius: 20)
                .fill(focusAreaCompleted ? AppColors.green2 : (available ? AppColors.yellow1 : AppColors.darkGrey4))
                .shadow(color: focusAreaCompleted ? AppColors.green3 : (available ? AppColors.lightBrown2 : Color.clear), radius: 0, x: 0, y: 3)
        }
    }
    
    private func getImage(name: String) -> some View {
        Image(systemName: name)
            .font(.system(size: 25))
            .foregroundStyle(focusAreaCompleted ? AppColors.whiteDefault : (available ? Color.black : AppColors.whiteDefault))
            .padding(.bottom)
    }
}

//#Preview {
//    SectionRecapPreviewBox()
//}
