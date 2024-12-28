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
            
            HStack {
                Text("Section Recap")
                    .multilineTextAlignment(.center)
                    .font(.system(size: 17, weight: .regular))
                    .foregroundStyle(Color.white)
                
                Spacer()
            }
            
            Spacer()
            
            if focusAreaCompleted {
                getImage(name: "checkmark")
                
            } else if !available {
                getImage(name: "lock.fill")
            } else {
                getImage(name: "arrow.forward.circle.fill")
            }

        }
        .opacity((focusAreaCompleted || !available) ? 0.6 : 1)
        .padding()
        .frame(width: 150, height: 180)
        .contentShape(Rectangle())
        .background {
            RoundedRectangle(cornerRadius: 20)
                .stroke((focusAreaCompleted || !available) ? Color.clear : Color.white, lineWidth: 1)
                .fill((focusAreaCompleted || !available) ? AppColors.sectionBoxBackground : Color.clear)
        }
    }
    
    private func getImage(name: String) -> some View {
        Image(systemName: name)
            .font(.system(size: 20))
            .foregroundStyle(Color.white)
    }
}

//#Preview {
//    SectionRecapPreviewBox()
//}
