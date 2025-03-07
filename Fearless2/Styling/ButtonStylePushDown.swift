//
//  ButtonStylePushDown.swift
//  Fearless2
//
//  Created by Yue Deng-Wu on 3/2/25.
//
import Pow
import SwiftUI

struct ButtonStylePushDown: ButtonStyle {
    let isDisabled: Bool
    
    init(isDisabled: Bool = false) {
        self.isDisabled = isDisabled
    }
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .opacity(configuration.isPressed && !isDisabled ? 0.75 : 1)
            .scaleEffect(configuration.isPressed && !isDisabled ? 0.95 : 1)
            .conditionalEffect(
                .pushDown,
                condition: configuration.isPressed && !isDisabled
            )
    }
}
