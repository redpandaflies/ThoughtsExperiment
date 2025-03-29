//
//  CategoryMissionBox.swift
//  Fearless2
//
//  Created by Yue Deng-Wu on 2/7/25.
//

import SwiftUI

struct CategoryMissionBox: View {
    
   
    
    var body: some View {
        HStack (spacing: 4) {
            
            Spacer()
            
            Text("Reach")
                .font(.system(size: 15, weight: .light))
                .fontWidth(.condensed)
                .foregroundStyle(AppColors.whiteDefault)
            
            getLaurel(points: 25)
            
            Text("to unlock a new topic")
                .font(.system(size: 15, weight: .light))
                .fontWidth(.condensed)
                .foregroundStyle(AppColors.whiteDefault)
            Spacer()
        }
        .opacity(0.9)
        .padding(.vertical)
        .background {
            RoundedRectangle(cornerRadius: 60)
                .fill(
                    AppColors.darkGrey5.opacity(0.5)
                        .shadow(.inner(color:  AppColors.blackDefault.opacity(0.2), radius: 3, x: 0, y: 2))
                )
                .shadow(color: .white.opacity(0.03), radius: 0, x: 0, y: 1)
                .blendMode(.softLight)
        }
        
    }
    
    private func getLaurel(points: Int) -> some View {
        HStack (spacing: 3) {
            
            Image(systemName: "laurel.leading")
                .font(.system(size: 15, weight: .light))
                .fontWidth(.condensed)
                .foregroundStyle(AppColors.whiteDefault)
            
            Text("\(points)")
                .font(.system(size: 15, weight: .light))
                .fontWidth(.condensed)
                .foregroundStyle(AppColors.whiteDefault)
            
            Image(systemName: "laurel.trailing")
                .font(.system(size: 15, weight: .light))
                .fontWidth(.condensed)
                .foregroundStyle(AppColors.whiteDefault)
                
        }
        
    }
}

#Preview {
    CategoryMissionBox()
}
