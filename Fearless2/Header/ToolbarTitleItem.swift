//
//  ToolbarTitleItem.swift
//  Fearless2
//
//  Created by Yue Deng-Wu on 11/7/24.
//

import SwiftUI

struct ToolbarTitleItem: View {
    
    let title: String
    let regularSize: Bool
    
    var body: some View {
        Text(title)
            .font(.system(size: regularSize ? 20 : 20, weight: .light))
            .foregroundStyle(Color.white)
            .textCase(.uppercase)
    }
}

