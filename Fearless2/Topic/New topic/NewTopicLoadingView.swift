//
//  NewTopicLoadingView.swift
//  Fearless2
//
//  Created by Yue Deng-Wu on 12/31/24.
//

import SwiftUI

struct NewTopicLoadingView: View {
    
    @Binding var activeIndex: Int?
    @Binding var animationValue: Bool
    
    let loadingText: [String] = ["Creating the topic", "Understanding the context"]
    
    var body: some View {
        VStack (alignment: .leading, spacing: 10) {
            
            Spacer()
            
            ForEach(loadingText.indices, id: \.self) { index in
                
                HStack {
                    
                    getIcon(index: index, icon: (activeIndex ?? -1) >= index ? "checkmark.circle.fill" : "arrow.right.circle")
                        .contentTransition(.symbolEffect(.replace.offUp.byLayer))
                        
                    
                    getText(index: index, text: loadingText[index])
                    
                    Spacer()
                    
                }//HStack
                .animation(.easeInOut, value: activeIndex)
                
            }//ForEach
            
            HStack {
                
                if (activeIndex ?? -1) == 2 {
                    getIcon(index: 2, icon: "checkmark.circle.fill")
                } else {
                    getIcon(index: 2, icon: "ellipsis.circle")
                        .symbolEffect(.variableColor.cumulative.dimInactiveLayers.nonReversing, options: animationValue ? .repeating : .nonRepeating, value: animationValue)
                }
                
                getText(index: 2, text: "Figuring out possible paths")
                
                Spacer()
                
            }
            
            Spacer()
        }//VStack
        .onAppear {
            startAnimating()
        }
        .onDisappear {
            animationValue = false
        }

    }
    
    private func startAnimating() {
        var currentIndex = 0
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            activeIndex = currentIndex
            currentIndex += 1
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                activeIndex = currentIndex
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    animationValue = true
                }
            }

        }
        
    }
    
    private func getIcon(index: Int, icon: String) -> some View {
       
        Image(systemName: icon)
            .multilineTextAlignment(.leading)
            .font(.system(size: 17, weight: .light))
            .foregroundStyle((activeIndex ?? -1) >= index ? Color.green : AppColors.whiteDefault.opacity(0.5))
            
    }
    
    private func getText(index: Int, text: String) -> some View {
        Text(text)
            .multilineTextAlignment(.leading)
            .font(.system(size: 17, weight: .light))
            .fontWidth(.condensed)
            .foregroundStyle((activeIndex ?? -1) >= index ? Color.green : AppColors.whiteDefault.opacity(0.5))
    }
    
}

//#Preview {
//    NewTopicLoadingView()
//}
