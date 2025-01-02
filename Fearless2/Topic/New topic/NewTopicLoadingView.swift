//
//  NewTopicLoadingView.swift
//  Fearless2
//
//  Created by Yue Deng-Wu on 12/31/24.
//

import SwiftUI

struct NewTopicLoadingView: View {
    @State private var animationValue: Bool = false
    @Binding var activeIndex: Int?
    
    let loadingText: [String] = ["Creating the topic", "Understanding the context…", "Figuring out possible starting points"]
    
    var body: some View {
        VStack (alignment: .leading, spacing: 10) {
            
            Spacer()
            
            ForEach(loadingText.indices, id: \.self) { index in
                
                HStack {
                    
                    Image(systemName: (activeIndex ?? -1) >= index ? "checkmark.circle.fill" : "arrow.right.circle")
                        .multilineTextAlignment(.leading)
                        .font(.system(size: 17))
                        .foregroundStyle((activeIndex ?? -1) >= index ? Color.green : AppColors.whiteDefault.opacity(0.5))
                        .contentTransition(.symbolEffect(.replace.offUp.byLayer))
                    
                    Text(loadingText[index])
                        .multilineTextAlignment(.leading)
                        .font(.system(size: 17))
                        .foregroundStyle((activeIndex ?? -1) >= index ? Color.green : AppColors.whiteDefault.opacity(0.5))
                    
                }//HStack
                .animation(.easeInOut, value: activeIndex)
            }//ForEach
            
            Spacer()
        }//VStack
        .onAppear {
            startAnimating()
        }

    }
    
    private func startAnimating() {
        var currentIndex = 0
        
        Timer.scheduledTimer(withTimeInterval: 1.5, repeats: true) { timer in
            if currentIndex < loadingText.count - 1 {
                activeIndex = currentIndex
                currentIndex += 1
            } else {
                timer.invalidate()
            }
        }
    }
    
}

//#Preview {
//    NewTopicLoadingView()
//}
