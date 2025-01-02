//
//  UnderstandLoadingView.swift
//  Fearless2
//
//  Created by Yue Deng-Wu on 11/21/24.
//

import SwiftUI

struct UnderstandLoadingView: View {
    @State private var animationValue: Bool = false
    
    var body: some View {
        HStack {
            Spacer()
            
            VStack (alignment: .center, spacing: 15) {
                Spacer()
                
                
                Text("Thinking")
                    .multilineTextAlignment(.leading)
                    .font(.system(size: 19))
                    .foregroundStyle(AppColors.whiteDefault)
                
                Image(systemName: "ellipsis")
                    .font(.system(size: 40))
                    .foregroundStyle(AppColors.whiteDefault)
                    .symbolEffect(.variableColor.cumulative.dimInactiveLayers.nonReversing, options: animationValue ? .repeating : .nonRepeating, value: animationValue)
                
                Spacer()
                
            }
            
            Spacer()
        }
      
        .onAppear {
            animationValue = true
        }
        .onDisappear {
            animationValue = false
        }
    }
}

#Preview {
    UnderstandLoadingView()
}
