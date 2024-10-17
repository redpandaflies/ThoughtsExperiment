//
//  LottieView.swift
//  Fearless2
//
//  Created by Yue Deng-Wu on 10/2/24.
//

import SwiftUI
import Lottie

struct LottieView: UIViewRepresentable {
    let name: String
    let loopMode: LottieLoopMode
    @Binding var animationSpeed: CGFloat
    let contentMode: UIView.ContentMode
    @Binding var play: Bool
    var backgroundColor: UIColor = .clear // Default background color is clear
    
    let animationView: LottieAnimationView
    
    init(name: String, loopMode: LottieLoopMode = .loop, animationSpeed: Binding<CGFloat> = .constant(2.5), contentMode: UIView.ContentMode = .scaleAspectFit, play: Binding<Bool> = .constant(true), backgroundColor: UIColor = .clear) {
        self.name = name
        self.loopMode = loopMode
        self._animationSpeed = animationSpeed
        self.contentMode = contentMode
        self._play = play
        self.backgroundColor = backgroundColor
        self.animationView = LottieAnimationView(name: name)
    }
    
    func makeUIView(context: Context) -> UIView {
        let view = UIView(frame: .zero)
        view.backgroundColor = backgroundColor // Use the specified background color
        view.addSubview(animationView)
        animationView.contentMode = contentMode
        animationView.translatesAutoresizingMaskIntoConstraints = false
        animationView.heightAnchor.constraint(equalTo: view.heightAnchor).isActive = true
        animationView.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
        animationView.loopMode = loopMode
        animationView.animationSpeed = animationSpeed
        
        return view
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {
        if play {
            animationView.play()
        } else {
            animationView.stop()
        }
    }
}
