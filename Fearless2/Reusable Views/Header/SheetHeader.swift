//
//  SheetHeader.swift
//  Fearless2
//
//  Created by Yue Deng-Wu on 4/24/25.
//

import SwiftUI

struct SheetHeader: View {
    let emoji: String
    let title: String
    let xmarkAction: () -> Void
    
    var body: some View {
        HStack (spacing: 8) {
  
            Text(emoji)
                .multilineTextAlignment(.leading)
                .font(.system(size: 19, weight: .light).smallCaps())
         
            
            Text(title)
                .multilineTextAlignment(.leading)
                .font(.system(size: 19, weight: .light).smallCaps())
                .fontWidth(.condensed)
                .foregroundStyle(AppColors.textPrimary.opacity(0.7))
            
            Spacer()
        
            
            Button {
                xmarkAction()
            } label: {
                
                Image(systemName: "xmark.circle.fill")
                    .font(.system(size: 25))
                    .foregroundStyle(AppColors.progressBarPrimary.opacity(0.3))
            }
    
        }//HStack
        .padding(.horizontal)
        .padding(.top)
        .padding(.bottom, 15)
    }
}


