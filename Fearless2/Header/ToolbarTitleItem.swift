//
//  ToolbarTitleItem.swift
//  Fearless2
//
//  Created by Yue Deng-Wu on 11/7/24.
//

import SwiftUI

struct ToolbarTitleItem: View {
    
    let title: String
    let largerFont: Bool
    
    init(title: String, largerFont: Bool = false) {
        self.title = title
        self.largerFont = largerFont
    }
    
    var body: some View {
        
        Text(title)
            .font(.system(size: largerFont == true ? 35 : 17, design: .serif))
            .foregroundStyle(AppColors.textPrimary)
            .textCase(.uppercase)
       
    }
}

