//
//  RecordingLoadingAnimation.swift
//  Fearless2
//
//  Created by Yue Deng-Wu on 11/13/24.
//

import SwiftUI

struct RecordingLoadingAnimation: View {
    @State private var animationValue: Bool = false
    
    var body: some View {
        VStack {
            Image(systemName: "ellipsis")
                .font(.system(size: 40))
                .foregroundStyle(AppColors.whiteDefault)
                .symbolEffect(.variableColor.cumulative.dimInactiveLayers.nonReversing, options: animationValue ? .repeating : .nonRepeating, value: animationValue)
                .padding(.top, 40)
            
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
