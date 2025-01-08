//
//  SectionBox.swift
//  Fearless2
//
//  Created by Yue Deng-Wu on 10/14/24.
//

import SwiftUI

struct SectionBox: View {
    
    @ObservedObject var section: Section
    
    var body: some View {
        VStack (spacing: 5) {
 
            Text(section.sectionTitle)
                .multilineTextAlignment(.center)
                .font(.system(size: 17, weight: .regular))
                .foregroundStyle(AppColors.whiteDefault)
                
          
            Text("\(section.sectionQuestions.count) prompts")
                .font(.system(size: 11))
                .foregroundStyle(AppColors.whiteDefault)
                .opacity(0.6)
                .textCase(.uppercase)
            
            Spacer()
            
            if section.completed {
                Image(systemName: "checkmark")
                    .font(.system(size: 20))
                    .foregroundStyle(AppColors.whiteDefault)
                
            } else {
                Image(systemName: "arrow.forward.circle.fill")
                    .font(.system(size: 20))
                    .foregroundStyle(AppColors.whiteDefault)
            }
                
        }
        .opacity(section.completed ? 0.6 : 1)
        .padding()
        .frame(width: 150, height: 180)
        .contentShape(Rectangle())
        .background {
            RoundedRectangle(cornerRadius: 20)
                .stroke(section.completed ? Color.clear : AppColors.whiteDefault.opacity(0.5), lineWidth: 1)
                .fill(section.completed ? AppColors.sectionBoxBackground : Color.clear)
        }
    }
}

//#Preview {
//    HomeSectionBox(title: "Identify all possible options")
//}
