//
//  UpdateSectionCompleteView.swift
//  Fearless2
//
//  Created by Yue Deng-Wu on 1/2/25.
//
import Pow
import SwiftUI

struct UpdateSectionCompleteView: View {
    
    @State private var lastCompleteSectionIndex: Int? = nil
    @State private var nextSectionIndex: Int? = nil
    @State private var playAnimation: Bool = false
    
    let focusArea: FocusArea
    var sortedSections: [Section] {
        focusArea.focusAreaSections.sorted { $0.sectionNumber < $1.sectionNumber }
    }
    
    var sectionsComplete: Int {
        return focusArea.focusAreaSections.filter {
        $0.completed == true
        }.count
    }
    
    private let hapticImpact = UIImpactFeedbackGenerator(style: .medium)
    
    var body: some View {
        VStack (alignment: .leading, spacing: 10){
            
            HStack {
                Image(focusArea.category?.categoryEmoji ?? "")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 29)
                
                Spacer()
                
            }
            .padding(.top)
            
            Text(focusArea.focusAreaTitle)
                .multilineTextAlignment(.leading)
                .font(.system(size: 30, design: .serif))
                .foregroundStyle(AppColors.textPrimary)
            
            Text(focusArea.focusAreaReasoning)
                .multilineTextAlignment(.leading)
                .font(.system(size: 16, weight: .light))
                .foregroundStyle(AppColors.textPrimary.opacity(0.7))
                .padding(.bottom, 15)
            
            ForEach(sortedSections.indices, id: \.self) { index in
                
                getContent(index: index, text: sortedSections[index].sectionTitle)
                
            }//ForEach
           
            getContent(index: sortedSections.count, text: "Recap")
            
            
            Spacer()
            
        }//VStack
        .onAppear {
            startAnimating()
        }
        
    }
    
    private func getContent(index: Int, text: String) -> some View {
        
        HStack {
            
            if lastCompleteSectionIndex == index {
                Image(systemName: "checkmark.circle.fill")
                    .multilineTextAlignment(.leading)
                    .font(.system(size: 19))
                    .foregroundStyle(getColor(index: index))
                    .transition(
                        .movingParts.pop(AppColors.textPrimary)
                    )
                
            } else {
                
                Image(systemName: getIcon(index: index))
                    .multilineTextAlignment(.leading)
                    .font(.system(size: 19))
                    .foregroundStyle(getColor(index: index))
                    .contentTransition(.symbolEffect(.replace.offUp.byLayer))
            }
            
           
            HStack (spacing: 3) {
                Text(text)
                    .multilineTextAlignment(.leading)
                    .font(.system(size: 19, weight: .light))
                    .fontWidth(.condensed)
                    .foregroundStyle(getColor(index: index))
                
                if index == sortedSections.count {
                    
                    LaurelItem(size: 19, points: "+1")
                        .opacity(index == nextSectionIndex ? 1 : 0.5)
                    
                }
            }
          
            
        }//HStack
        
    }
    
    private func getIcon(index: Int) -> String {
        
        if index < sectionsComplete - 1 {
            return "checkmark.circle.fill"
        } else if lastCompleteSectionIndex == index {
            return "checkmark.circle.fill"
        } else if nextSectionIndex == index {
            return "arrow.right.circle"
        } else {
            return "circle"
        }
        
    }
    
    private func getColor(index: Int) -> Color {
        if index < sectionsComplete - 1 {
            return AppColors.textPrimary
        } else if lastCompleteSectionIndex == index {
            return AppColors.textPrimary
        } else if nextSectionIndex == index {
            return AppColors.textPrimary
        } else {
            return AppColors.textPrimary.opacity(0.5)
        }
    }
    
    private func startAnimating() {
        
        print("Sections complete: \(sectionsComplete)")
        hapticImpact.prepare()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.75) {
            withAnimation(.snappy(duration: 0.7)) {
                let currentIndex = sectionsComplete - 1
                hapticImpact.impactOccurred(intensity: 0.5)
                lastCompleteSectionIndex = currentIndex
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                withAnimation(.smooth(duration: 0.2)) {
                    let nextIndex = sectionsComplete
                    hapticImpact.impactOccurred(intensity: 0.7)
                    nextSectionIndex = nextIndex
                }
            }
        }
       
    }
}
