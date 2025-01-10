//
//  FocusAreaLoadingView.swift
//  Fearless2
//
//  Created by Yue Deng-Wu on 1/3/25.
//

import SwiftUI

struct FocusAreaLoadingView: View {
    @ObservedObject var topicViewModel: TopicViewModel
    @State private var activeIndex: Int? = -1
    
    @Binding var recapReady: Bool
    @Binding var animationValue: Bool
   
    let focusArea: FocusArea
    var sortedSections: [Section] {
        focusArea.focusAreaSections.sorted { $0.sectionNumber < $1.sectionNumber }
    }
    
    var body: some View {
        VStack (alignment: .leading, spacing: 10){
            
            HStack {
                Text(focusArea.focusAreaEmoji)
                    .multilineTextAlignment(.leading)
                    .font(.system(size: 29))
                
                Spacer()
                
            }
            .padding(.top, 40)
            
            Text(focusArea.focusAreaTitle)
                .multilineTextAlignment(.leading)
                .font(.system(size: 25, weight: .light))
                .foregroundStyle(AppColors.whiteDefault)
            
            Text(focusArea.focusAreaReasoning)
                .multilineTextAlignment(.leading)
                .font(.system(size: 16, weight: .light))
                .foregroundStyle(AppColors.whiteDefault.opacity(0.7))
                .padding(.bottom, 15)
            
            ForEach(Array(sortedSections.enumerated()), id: \.element.sectionId) { index, section in
                
                HStack {
                    
                    getIcon(
                        icon: (activeIndex ?? -1) >= index ? "checkmark.circle.fill" : "arrow.right.circle",
                        color: (activeIndex ?? -1) >= index ? Color.green : AppColors.whiteDefault.opacity(0.5)
                    )
                    .contentTransition(.symbolEffect(.replace.offUp.byLayer))
                    
                    getText(text: section.sectionTitle, color: (activeIndex ?? -1) >= index ? Color.green : AppColors.whiteDefault.opacity(0.5))
                    
                    
                    Spacer()
                }
                .animation(.easeInOut, value: activeIndex)
                
            }//ForEach
            
            
            HStack {
                
                if recapReady {
                    getIcon(
                        icon: "arrow.right.circle",
                        color: AppColors.yellow1
                    )
                    .symbolEffect(.variableColor.cumulative.dimInactiveLayers.nonReversing, options: animationValue ? .repeating : .nonRepeating, value: animationValue)
                    
                } else {
                    getIcon(
                        icon: "ellipsis.circle",
                        color: AppColors.whiteDefault.opacity(0.5)
                    )
                    .symbolEffect(.variableColor.cumulative.dimInactiveLayers.nonReversing, options: animationValue ? .repeating : .nonRepeating, value: animationValue)
                }
               
                
                getText(
                    text: recapReady ? "Recap ready" : "Generating recap",
                    color: recapReady ? AppColors.yellow1 : AppColors.whiteDefault.opacity(0.5)
                )
                
                Spacer()
            }
            
        }//VStack
        .onAppear {
            startAnimating()
        }
        
    }
    
    private func startAnimating() {
        var currentIndex = 0
        let totalSections = sortedSections.count
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            activeIndex = currentIndex
            currentIndex += 1
            
            updateIndicesSequentially(currentIndex: currentIndex, totalSections: totalSections, interval: 1.0)
        }
        
    }
    
   private func updateIndicesSequentially(currentIndex: Int, totalSections: Int, interval: TimeInterval) {
        guard currentIndex <= totalSections - 1 else {
            // Finish sequence
            DispatchQueue.main.asyncAfter(deadline: .now() + interval) {
                activeIndex = currentIndex
                animationValue = true
            }
            return
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + interval) {
            activeIndex = currentIndex
            updateIndicesSequentially(currentIndex: currentIndex + 1, totalSections: totalSections, interval: interval)
        }
    }
    
    private func getIcon(icon: String, color: Color) -> some View {
        Image(systemName: icon)
            .multilineTextAlignment(.leading)
            .font(.system(size: 17))
            .foregroundStyle(color)
    }
    
    private func getText(text: String, color: Color) -> some View {
        Text(text)
            .multilineTextAlignment(.leading)
            .font(.system(size: 17, weight: .light))
            .fontWidth(.condensed)
            .foregroundStyle(color)
    }
}
