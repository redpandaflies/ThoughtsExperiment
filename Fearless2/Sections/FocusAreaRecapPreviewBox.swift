//
//  FocusAreaRecapPreviewBox.swift
//  Fearless2
//
//  Created by Yue Deng-Wu on 11/7/24.
//

import SwiftUI

struct FocusAreaRecapPreviewBox: View {
    
    let focusAreaCompleted: Bool
    
    var body: some View {
        VStack (spacing: 5) {
            
            HStack {
                Text("Section Recap")
                    .multilineTextAlignment(.center)
                    .font(.system(size: 17, weight: .regular))
                    .foregroundStyle(Color.white)
                
                Spacer()
            }
            
            Spacer()
            
            if focusAreaCompleted {
                Image(systemName: "checkmark")
                    .font(.system(size: 20))
                    .foregroundStyle(Color.white)
                
            } else {
                Image(systemName: "arrow.forward.circle.fill")
                    .font(.system(size: 20))
                    .foregroundStyle(Color.white)
            }

        }
        .opacity(focusAreaCompleted ? 0.6 : 1)
        .padding()
        .frame(width: 150, height: 180)
        .contentShape(Rectangle())
        .background {
            RoundedRectangle(cornerRadius: 20)
                .stroke(focusAreaCompleted ? Color.clear : Color.white, lineWidth: 1)
                .fill(focusAreaCompleted ? AppColors.sectionBoxBackground : Color.clear)
        }
    }
}

//#Preview {
//    SectionRecapPreviewBox()
//}
