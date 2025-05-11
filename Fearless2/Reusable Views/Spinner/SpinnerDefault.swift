//
//  SpinnerDefault.swift
//  Fearless2
//
//  Created by Yue Deng-Wu on 5/7/25.
//

import SwiftUI

struct SpinnerDefault: View {
    
    let frameSize: CGFloat
    
    init(frameSize: CGFloat = 80) {
        self.frameSize = frameSize
    }
    
    var body: some View {
        Image("spinner")
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(width: frameSize)
    }
}

#Preview {
    SpinnerDefault()
}
