//
//  NextButton.swift
//  Fearless2
//
//  Created by Yue Deng-Wu on 10/5/24.
//

import SwiftUI

struct NextButton: View {
    
    let action: () -> Void
    let asyncAction: (() async -> Void)?
    
    var body: some View {
        HStack {
            Spacer()
            
            Button {
                if let asyncAction = asyncAction {
                    Task {
                        await asyncAction()
                    }
                } else {
                    action()
                }
            } label: {
                Image(systemName: "arrow.right.circle.fill")
                    .font(.system(size: 40))
                    .foregroundStyle(AppColors.blackDefault)
            }
        }
    }
}
