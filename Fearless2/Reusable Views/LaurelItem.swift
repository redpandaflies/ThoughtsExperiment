//
//  LaurelItem.swift
//  Fearless2
//
//  Created by Yue Deng-Wu on 11/7/24.
//
import CoreData
import SwiftUI

struct LaurelItem: View {
    
    let size: CGFloat
    let points: String
    let primaryColor: Color
    
    init(size: CGFloat, points: String, primaryColor: Color = AppColors.textPrimary) {
        self.size = size
        self.points = points
        self.primaryColor = primaryColor
    }
    
    var body: some View {
        
        HStack (spacing: 3) {
            
            Image(systemName: "laurel.leading")
                .font(.system(size: size, weight: .light))
                .fontWidth(.condensed)
                .foregroundStyle(primaryColor)
            
          
            Text(points)
                .font(.system(size: size, weight: .light))
                .fontWidth(.condensed)
                .foregroundStyle(primaryColor)
            
            Image(systemName: "laurel.trailing")
                .font(.system(size: size, weight: .light))
                .fontWidth(.condensed)
                .foregroundStyle(primaryColor)
                
        }
//        .background(.black)
    }
}

//#Preview {
//    ToolbarLaurelItem(points: "100")
//}
