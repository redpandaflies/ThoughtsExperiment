//
//  FocusAreaRetryView.swift
//  Fearless2
//
//  Created by Yue Deng-Wu on 2/3/25.
//

import SwiftUI

struct FocusAreaRetryView: View {
    let action: () -> Void
    
    var body: some View {
        HStack {
            Spacer()
            
            RetryButton(action: {
                action()
            })
            
            Spacer()
            
        }
        .padding(.top, 20)
    }
}


