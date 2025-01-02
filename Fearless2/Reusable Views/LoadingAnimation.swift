//
//  LoadingAnimation.swift
//  Fearless2
//
//  Created by Yue Deng-Wu on 10/2/24.
//
import SwiftUI

struct LoadingAnimation: View {
    
    var body: some View {
        VStack (alignment: .leading) {
            Text("Finding insights")
                .multilineTextAlignment(.leading)
                .font(.system(size: 11, weight: .regular))
                .foregroundStyle(AppColors.yellow1)
                .textCase(.uppercase)
                .padding(.bottom, 5)
            
            HStack {
                Text("Thinking...")
                    .multilineTextAlignment(.leading)
                    .font(.system(size: 19))
                    .foregroundStyle(AppColors.whiteDefault)
                
                Spacer()
            }
            
            Spacer()
    
        }
        .padding()
        .frame(width: 360, height: 340)
        .background {
            RoundedRectangle(cornerRadius: 20)
                .fill(AppColors.questionBoxBackground)
                .shadow(color: .black.opacity(0.07), radius: 3, x: 0, y: 1)
        }
    }
}

//#Preview {
//    LoadingAnimation()
//}
