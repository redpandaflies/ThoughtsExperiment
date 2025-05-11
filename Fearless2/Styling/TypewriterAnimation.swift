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
    private var segments: [String]
    
    // MARK: - Published properties for views to observe
    @Binding var animatedText: String
    @Binding var completedAnimation: Bool
    private let hapticImpact = UIImpactFeedbackGenerator(style: .medium)
    
    // MARK: - Parsing Method
    private func parseTextIntoSegments(_ text: String) -> [String] {
        // First, split the text by paragraphs (double line breaks)
        let paragraphs = text.components(separatedBy: "\n\n")
        
        var segments: [String] = []
        
        for paragraph in paragraphs {
            // For each paragraph, split by single line breaks
            let lines = paragraph.components(separatedBy: "\n")
            
            for (lineIndex, line) in lines.enumerated() {
                // Split each line into words
                let words = line.components(separatedBy: CharacterSet.whitespaces)
                    .filter { !$0.isEmpty }
                
                for (wordIndex, word) in words.enumerated() {
                    segments.append(word)
                    
                    // Add space after word if it's not the last word in the line
                    if wordIndex < words.count - 1 {
                        segments.append(" ")
                    }
                }
                
//                // Add line break if it's not the last line in the paragraph
                if lineIndex < lines.count - 1 {
                    segments.append("\n")
                }
            }
            
            // Add paragraph break (double line break) if it's not the last paragraph
            if paragraph != paragraphs.last {
                segments.append("\n\n")
            }
        }
        
        return segments
    }
    
    // MARK: - Initialization
    init(
        text: String,
        animatedText: Binding<String>,
        completedAnimation: Binding<Bool>,
        speed: Double = 0.05,
        hapticIntensity: Double = 0.5
    ) {
        self.text = text
        self._animatedText = animatedText
        self._completedAnimation = completedAnimation
        self.speed = speed
        self.hapticIntensity = hapticIntensity
        
        self.segments = []
        // Split the text into segments that respect line breaks
        self.segments = self.parseTextIntoSegments(text)
    }
   
    
    // MARK: - Animation Methods
    func animate() {
        // Prevent multiple animations from running simultaneously
        hapticImpact.prepare()
        animatedText = ""
        completedAnimation = false
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
            self?.animateSegment(at: 0)
        }
    }
    
    private func animateSegment(at index: Int) {
        guard index < segments.count else {
            // mark animation as complete
            completedAnimation = true
            return
        }
        
        // Append next segment
        animatedText += segments[index]
        
        // Apply haptic feedback for words (not for spaces or line breaks)
        if segments[index] != " " && segments[index] != "\n" && segments[index] != "\n\n" {
            if index % 2 == 0 && index > 0 {
                hapticImpact.impactOccurred(intensity: hapticIntensity)
            }
        }
        
        // Determine delay for the next segment
        var delay = speed
        
        // Add slight pause at line breaks and paragraph breaks
        if segments[index] == "\n\n" {
            delay *= 1 // Longer pause for line breaks
        } 
        
        DispatchQueue.main.asyncAfter(deadline: .now() + delay) { [weak self] in
            self?.animateSegment(at: index + 1)
        }
    }
    
    func updateText(_ newText: String) {
        self.text = newText
        self.segments = self.parseTextIntoSegments(newText)
    }
}


extension String {
    subscript(offset: Int) -> Character {
        self[index(startIndex, offsetBy: offset)]
    }
}
