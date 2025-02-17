//
//  XmarkToolbarItem.swift
//  Fearless2
//
//  Created by Yue Deng-Wu on 11/21/24.
//

import SwiftUI

struct XmarkToolbarItem: View {
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        Button {
            dismiss()
        } label: {
            Image(systemName: "xmark.circle.fill")
                .font(.system(size: 20))
                .foregroundStyle(AppColors.textPrimary.opacity(0.7))
        }
    }
}

#Preview {
    XmarkToolbarItem()
}
