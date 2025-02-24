//
//  CategoryQuestsHeading.swift
//  Fearless2
//
//  Created by Yue Deng-Wu on 2/22/25.
//

import SwiftUI

struct CategoryQuestsHeading: View {
    
    let screenWidth = UIScreen.current.bounds.width
  
    var body: some View {
     
        HStack {
            shortLine()
            
            Text("Quests")
                .font(.system(size: 20, weight: .light).smallCaps())
                .fontWidth(.condensed)
                .foregroundStyle(AppColors.textPrimary.opacity(0.7))
                .fixedSize(horizontal: true, vertical: true)
                .padding(.horizontal)

            
            shortLine()
            
        }
       
            
    }
    
    private func shortLine() -> some View {
        Rectangle()
            .fill(Color.white.opacity(0.05))
            .frame(maxWidth: .infinity)
            .frame(height: 1)
    }
}

#Preview {
    CategoryQuestsHeading()
}
