//
//  ToolbarTitleItem.swift
//  Fearless2
//
//  Created by Yue Deng-Wu on 11/7/24.
//

import SwiftUI

struct ToolbarTitleItem: View {
    
    let title: String
    
    var body: some View {
        
        Text(title)
            .font(.system(size: 17, design: .serif))
            .foregroundStyle(AppColors.textPrimary)
            .textCase(.uppercase)
       
    }
}

