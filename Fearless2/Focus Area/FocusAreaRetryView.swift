//
//  FocusAreaRetryView.swift
//  Fearless2
//
//  Created by Yue Deng-Wu on 2/3/25.
//

import SwiftUI

struct FocusAreaRetryView: View {
    @State private var playHapticEffect: Int = 0
    
    let action: () -> Void
    
    var body: some View {
        HStack {
            Spacer()
            
            RetryButton(action: {
                playHapticEffect += 1
                action()
            })
            .sensoryFeedback(.selection, trigger: playHapticEffect)
            
            Spacer()
            
        }
        .padding(.top, 20)
        .onAppear {
            if playHapticEffect != 0 {
                playHapticEffect = 0
            }
        }
    }
}


