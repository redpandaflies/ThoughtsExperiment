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
    let fontWeight: Font.Weight
    let useSmallCaps: Bool
    
    init(size: CGFloat, points: String, primaryColor: Color = AppColors.textPrimary, fontWeight: Font.Weight = .light, useSmallCaps: Bool = false) {
        self.size = size
        self.points = points
        self.primaryColor = primaryColor
        self.fontWeight = fontWeight
        self.useSmallCaps = useSmallCaps
    }
    
    var body: some View {
        
        HStack (spacing: 3) {
            
            Image(systemName: "laurel.leading")
                .font(.system(size: size, weight: fontWeight))
                .fontWidth(.condensed)
                .foregroundStyle(primaryColor)
            
          
            Text(points)
                .font(useSmallCaps ? 
                      .system(size: size, weight: fontWeight).smallCaps() : 
                      .system(size: size, weight: fontWeight))
                .fontWidth(.condensed)
                .foregroundStyle(primaryColor)
            
            Image(systemName: "laurel.trailing")
                .font(.system(size: size, weight: fontWeight))
                .fontWidth(.condensed)
                .foregroundStyle(primaryColor)
                
        }
//        .background(.black)
    }
}

//#Preview {
//    ToolbarLaurelItem(points: "100")
//}
