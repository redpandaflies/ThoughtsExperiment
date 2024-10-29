//
//  SectionBox.swift
//  Fearless2
//
//  Created by Yue Deng-Wu on 10/14/24.
//

import SwiftUI

struct SectionBox: View {
    
    let section: Section
    
    var body: some View {
        HStack {
            VStack (alignment: .leading, spacing: 8) {
                
                Text("\(section.sectionNumber)")
                     .multilineTextAlignment(.leading)
                     .font(.system(size: 20))
                     .fontWeight(.regular)
                     .foregroundStyle(AppColors.blackDefault)
                     .opacity(0.7)
                
                Text(section.sectionTitle)
                     .multilineTextAlignment(.leading)
                     .font(.system(size: 15))
                     .fontWeight(.light)
                     .foregroundStyle(AppColors.blackDefault)
                
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .font(.system(size: 15))
                .fontWeight(.light)
                .foregroundStyle(AppColors.blackDefault)
                
        }
        .padding()
        .contentShape(Rectangle())
        .background {
            RoundedRectangle(cornerRadius: 20)
                .stroke(Color(Color.white.opacity(0.4)), style: StrokeStyle(lineWidth: 1))
                .fill(Color.white)
                .shadow(color: .black.opacity(0.05), radius: 5.5, x: 0, y: 3)
            
        }
    }
}

//#Preview {
//    HomeSectionBox(title: "Identify all possible options")
//}
