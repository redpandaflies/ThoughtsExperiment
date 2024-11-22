//
//  DetailViewToolBarItem.swift
//  Fearless2
//
//  Created by Yue Deng-Wu on 11/15/24.
//

import SwiftUI

struct DetailViewToolBarItem: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var dataController: DataController
    
    let entryId: UUID?
    
    init(entryId: UUID? = nil) {
        self.entryId = entryId
    }

    var body: some View {
        HStack (spacing: 5) {
            Spacer()
            
            
            Menu {
                Button (role: .destructive) {
                    //tbd
                    Task {
                        if let currentEntryId = entryId {
                            await dataController.deleteEntry(id: currentEntryId)
                        }
                    }
                    dismiss()
                    
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
