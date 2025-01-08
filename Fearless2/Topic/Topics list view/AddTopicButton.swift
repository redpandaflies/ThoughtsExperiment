//
//  AddTopicButton.swift
//  Fearless2
//
//  Created by Yue Deng-Wu on 11/24/24.
//

import SwiftUI


struct AddTopicButton: View {
    
    var body: some View {
        VStack {
            Spacer()
            HStack {
                Spacer()
                
                Image(systemName: "plus")
                    .font(.system(size: 34, weight: .light))
                    .foregroundStyle(AppColors.whiteDefault)
                    .opacity(0.5)
                
                Spacer()
            }
            Spacer()
        }
        .frame(minHeight: 230)
        .contentShape(RoundedRectangle(cornerRadius: 25))
        .background {
            RoundedRectangle(cornerRadius: 25)
                .stroke(AppColors.whiteDefault.opacity(0.5))
        }
        .background(AppColors.black4)
    }
}

#Preview {
    AddTopicButton()
}
