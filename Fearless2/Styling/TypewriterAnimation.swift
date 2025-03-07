//
//  TypewriterAnimation.swift
//  Fearless2
//
//  Created by Yue Deng-Wu on 3/3/25.
//

import SwiftUI


final class TextAnimator {
    // MARK: - Properties
    private var text: String
    private var speed: Double
    private var hapticIntensity: Double
    
    // MARK: - Published properties for views to observe
    @Binding var animatedText: String
    private let hapticImpact = UIImpactFeedbackGenerator(style: .medium)
    
    // MARK: - Initialization
    init(
        text: String,
        animatedText: Binding<String>,
        speed: Double = 0.05,
        hapticIntensity: Double = 0.5
    ) {
        self.text = text
        self._animatedText = animatedText
        self.speed = speed
        self.hapticIntensity = hapticIntensity
    }
    
    // MARK: - Animation Methods
    func animate() {
        // Prevent multiple animations from running simultaneously
        hapticImpact.prepare()
        animatedText = ""
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
           self?.animateText(at: 0)
        }
    }
    
    private func animateText(at position: Int = 0) {
        if position == 0 {
            animatedText = ""
        }
        let sleepTime = UInt64(speed * 1_000_000_000)
        
        if position < text.count {
            DispatchQueue.main.asyncAfter(deadline: .now() + speed) { [weak self] in
                guard let self = self else { return }
                let index = self.text.index(self.text.startIndex, offsetBy: position)
                self.animatedText.append(self.text[index])
                
                if position % 3 == 0 && position > 0 {
                    self.hapticImpact.impactOccurred(intensity: self.hapticIntensity)
                }
    
                Task {
                    if position % 16 == 0 && position > 0 {
                       try? await Task.sleep(nanoseconds: sleepTime * 2)
                   }
                    self.animateText(at: position + 1)
                }
            }
            
            
        }
    }
    
    func updateText(_ newText: String) {
            self.text = newText
    }
}

extension String {
    subscript(offset: Int) -> Character {
        self[index(startIndex, offsetBy: offset)]
    }
}
