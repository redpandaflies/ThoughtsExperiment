//
//  SettingsToolbarItem.swift
//  Fearless2
//
//  Created by Yue Deng-Wu on 9/30/24.
//

import SwiftUI

struct SettingsToolbarItem: View {
    
    let action: () -> Void
    
    var body: some View {
       
        Button {
           action()
        } label: {
            Image(systemName: "gearshape.fill")
                .font(.system(size: 17, weight: .thin))
                .foregroundStyle(AppColors.textPrimary)
        }
            
        
    }
}

//#Preview {
//    SettingsToolbarItem()
//}
