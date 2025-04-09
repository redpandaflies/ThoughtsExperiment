//
//  TopicRecapFragmentBox.swift
//  Fearless2
//
//  Created by Yue Deng-Wu on 4/4/25.
//

import SwiftUI

struct TopicRecapFragmentBox: View {
    
    let fragmentText: String
    let boxBorder: CGFloat = 10
    
    var body: some View {
       
        VStack (spacing: 0){
            
            HStack {
                Text(fragmentText)
                    .multilineTextAlignment(.center)
                    .font(.system(size: 20, design: .serif))
                    .foregroundStyle(AppColors.textBlack)
                    .lineSpacing(1.3)
            }
            .frame(minHeight: 310)
           
            
        }
        .padding(.horizontal, 35)
        .frame(width: 310, alignment: .center)
        .background {
            RoundedRectangle(cornerRadius: 25)
                .stroke(Color.white.opacity(0.4), lineWidth: 0.5)
                .fill(
                    LinearGradient(colors: [Color.white, AppColors.boxSecondary], startPoint: .top, endPoint: .bottom)
                )
                .shadow(color: Color.white.opacity(0.25), radius: 30, x: 0, y: 0)
                .padding(boxBorder)
                .background {
                    RoundedRectangle(cornerRadius: 30)
                        .stroke(Color.white.opacity(0.2), lineWidth: 0.5)
                        .fill(AppColors.boxGrey1.opacity(0.2))
                        .blendMode(.colorDodge)
                    
                }
                
        }

        
    }
    
    private func shortLine() -> some View {
        Rectangle()
            .fill(Color.black.opacity(0.1))
            .shadow(color: Color.white.opacity(0.5), radius: 0, x: 0, y: 1)
            .frame(maxWidth: .infinity)
            .frame(height: 1)
    }
}

#Preview {
    TopicRecapFragmentBox(fragmentText: "You observe the moment, but do you let it transform you?")
}
