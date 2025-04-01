//
//  TestRectangle.swift
//  Fearless2
//
//  Created by Yue Deng-Wu on 3/30/25.
//

import SwiftUI

struct TestRectangle: View {
    let topic: Topic
    
    var body: some View {
        
        VStack {
            RoundedRectangle(cornerRadius: 15)
                .foregroundStyle(
                    AppColors.boxGrey3.opacity(0.25)
                        .blendMode(.multiply)
                        .shadow(.inner(color: .black.opacity(0.7), radius: 5, x: 0, y: 2))
                        .shadow(.drop(color: .white.opacity(0.2), radius: 0, x: 0, y: 1))
                )
            //            .shadow(color: .white.opacity(0.12), radius: 0, x: 0, y: 1)
//                .blendMode(.multiply)
                .frame(width: 300, height: 300)
        }
        .frame(width: 300, height: 300)
        .padding(30)
        .background(
            AppColors.backgroundCareer
        )
    }
}

//#Preview {
//    TestRectangle()
//}
