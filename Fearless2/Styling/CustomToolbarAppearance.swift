//
//  CustomToolbarAppearance.swift
//  Fearless2
//
//  Created by Yue Deng-Wu on 9/30/24.
//

import SwiftUI

struct CustomToolbarAppearance: ViewModifier {
    func body(content: Content) -> some View {
        content
            .onAppear {
                let appearance = UINavigationBarAppearance()
        
                appearance.shadowColor = UIColor.clear
//                appearance.backgroundColor = UIColor.white.withAlphaComponent(0.3)
                appearance.backgroundColor = UIColor.clear
                appearance.backgroundEffect = UIBlurEffect(style: .systemUltraThinMaterialLight)
                appearance.titleTextAttributes = [
                    .font: UIFont.systemFont(ofSize: 17, weight: .regular),
                    .foregroundColor: UIColor.black
                ]
                UINavigationBar.appearance().standardAppearance = appearance
                UINavigationBar.appearance().compactAppearance = appearance
//                UINavigationBar.appearance().scrollEdgeAppearance = appearance
            }
    }
}

extension View {
    func customToolbarAppearance() -> some View {
        self.modifier(CustomToolbarAppearance())
    }
}