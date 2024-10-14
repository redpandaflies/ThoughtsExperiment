//
//  SettingsToolbarItem.swift
//  Fearless2
//
//  Created by Yue Deng-Wu on 9/30/24.
//

import SwiftUI

struct SettingsToolbarItem: View {
    var body: some View {
        VStack {
            Button {
               //tbd
            } label: {
                Image(systemName: "gearshape")
                    .font(.headline)
                    .fontWeight(.light)
                    .foregroundStyle(AppColors.blackDefault)
            }
            
        }
    }
}

#Preview {
    SettingsToolbarItem()
}
