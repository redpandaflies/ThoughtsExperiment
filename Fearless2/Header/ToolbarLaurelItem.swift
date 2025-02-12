//
//  ToolbarLaurelItem.swift
//  Fearless2
//
//  Created by Yue Deng-Wu on 11/7/24.
//

import SwiftUI

struct ToolbarLaurelItem: View {
    
    let points: String
    
    var body: some View {
        
        HStack (spacing: 3) {
            
            Image(systemName: "laurel.leading")
                .font(.system(size: 15, weight: .light))
                .fontWidth(.condensed)
                .foregroundStyle(AppColors.textPrimary)
            
            Text(points)
                .font(.system(size: 15, weight: .light))
                .fontWidth(.condensed)
                .foregroundStyle(AppColors.textPrimary)
            
            Image(systemName: "laurel.trailing")
                .font(.system(size: 15, weight: .light))
                .fontWidth(.condensed)
                .foregroundStyle(AppColors.textPrimary)
                
        }
//        .background(.black)
    }
}

//#Preview {
//    ToolbarLaurelItem(points: "100")
//}
