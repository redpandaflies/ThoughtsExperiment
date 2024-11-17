//
//  EntryToolBarItem.swift
//  Fearless2
//
//  Created by Yue Deng-Wu on 11/15/24.
//

import SwiftUI

struct EntryToolBarItem: View {
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        HStack (spacing: 5) {
            Spacer()
            
            
            Menu {
                Button (role: .destructive) {
                    //tbd
                    
                } label: {
                    
                    Label("Delete", systemImage: "trash")
                    
                }
                
            } label: {
                Image(systemName: "ellipsis.circle.fill")
                    .font(.system(size: 20))
                    .foregroundStyle(AppColors.lightBrown)
            }
            
            Button {
                dismiss()
            } label: {
                Image(systemName: "xmark.circle.fill")
                    .font(.system(size: 20))
                    .foregroundStyle(AppColors.lightBrown)
            }
            
        }
        .padding(.vertical, 10)
    }
}
