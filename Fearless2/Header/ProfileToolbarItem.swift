//
//  ProfileToolbarItem.swift
//  Fearless2
//
//  Created by Yue Deng-Wu on 9/30/24.
//

import SwiftUI

struct ProfileToolbarItem: View {
    var body: some View {
        VStack {
            Button {
               //tbd
            } label: {
                Image(systemName: "person.crop.circle")
                    .font(.headline)
                    .fontWeight(.light)
                    .foregroundStyle(AppColors.blackDefault)
            }
            
        }
       
    }
}

#Preview {
    ProfileToolbarItem()
}
