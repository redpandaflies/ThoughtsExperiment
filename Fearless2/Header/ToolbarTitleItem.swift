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
            .font(.system(size: 25, weight: .light))
            .foregroundStyle(Color.white)
            .opacity(0.6)
            .textCase(.uppercase)
    }
}

