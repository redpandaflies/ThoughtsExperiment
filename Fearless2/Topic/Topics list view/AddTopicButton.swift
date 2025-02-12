//
//  AddTopicButton.swift
//  Fearless2
//
//  Created by Yue Deng-Wu on 11/24/24.
//

import SwiftUI


struct AddTopicButton: View {
    
    let frameWidth: CGFloat
    
    var body: some View {
        VStack {
            Spacer()
            HStack {
                Spacer()
                
                Image(systemName: "plus")
                    .font(.system(size: 34, weight: .light))
                    .foregroundStyle(AppColors.textSecondary.opacity(0.4))
                
                Spacer()
            }
            Spacer()
        }
        .frame(width: frameWidth, height: 295)
        .contentShape(RoundedRectangle(cornerRadius: 25))
        .background {
            RoundedRectangle(cornerRadius: 25)
                .stroke(AppColors.boxPrimary.opacity(0.1), lineWidth: 0.5)
        }
    }
}

//#Preview {
//    AddTopicButton()
//}
