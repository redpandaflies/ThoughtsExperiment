//
//  SectionBox.swift
//  Fearless2
//
//  Created by Yue Deng-Wu on 10/14/24.
//

import SwiftUI

struct SectionBox: View {
    
    @ObservedObject var section: Section
    let isNextSection: Bool
    
    var body: some View {
        VStack (spacing: 5) {
            
            Text(section.sectionTitle)
                .multilineTextAlignment(.center)
                .font(.system(size: 17, weight: isNextSection ? .regular : .light))
                .fontWidth(.condensed)
                .foregroundStyle(isNextSection ? Color.black : AppColors.whiteDefault)
                .padding(.bottom, 5)
            
            
            Text("\(section.sectionQuestions.count) prompts")
                .font(.system(size: 11, weight: isNextSection ? .regular : .light))
                .fontWidth(.condensed)
                .foregroundStyle(isNextSection ? Color.black : AppColors.whiteDefault)
                .opacity(0.6)
                .textCase(.uppercase)
              
            Spacer()
          
            
            if section.completed {
                getImage(name: "checkmark")
                
            } else if isNextSection {
                getImage(name: "arrow.forward.circle.fill")
            } else {
                getImage(name: "lock.fill")
            }
            
           
                
        }
        .opacity(section.completed ? 0.6 : (isNextSection ? 1 : 0.4))
        .padding()
        .frame(width: 150, height: 180)
        .contentShape(Rectangle())
        .background {
            RoundedRectangle(cornerRadius: 20)
                .fill(section.completed ? AppColors.green2 : (isNextSection ? AppColors.yellow1 : AppColors.darkGrey4))
                .shadow(color: section.completed ? AppColors.green3 : (isNextSection ? AppColors.lightBrown2 : Color.clear), radius: 0, x: 0, y: 3)
        }
    }
    
    private func getImage(name: String) -> some View {
        Image(systemName: name)
            .font(.system(size: 25))
            .foregroundStyle(isNextSection ? Color.black : AppColors.whiteDefault)
            .padding(.bottom)
    }
}

//#Preview {
//    HomeSectionBox(title: "Identify all possible options")
//}
