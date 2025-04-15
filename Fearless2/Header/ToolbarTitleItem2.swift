//
//  ToolbarTitleItem2.swift
//  Fearless2
//
//  Created by Yue Deng-Wu on 11/7/24.
//
// MARK: used for recap

import SwiftUI

struct ToolbarTitleItem2: View {
    let emoji: String
    let title: String
    
    var body: some View {
        HStack (spacing: 8) {
            if !emoji.isEmpty {
                Image(emoji)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 19)
            }
            
            Text(title)
                .multilineTextAlignment(.leading)
                .font(.system(size: 19, weight: .light).smallCaps())
                .fontWidth(.condensed)
                .foregroundStyle(AppColors.textPrimary.opacity(0.7))
            
            Spacer()
        }
    }
}

