//
//  Shadows.swift
//  Fearless2
//
//  Created by Yue Deng-Wu on 9/30/24.
//

import SwiftUI

extension View {
    func boxShadow() -> some View {
        self.shadow(color: Color.black.opacity(0.07), radius: 3, x: 0, y: 1)
    }
}
