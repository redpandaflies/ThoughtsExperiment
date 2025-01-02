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
                    .font(.system(size: 18))
                    .foregroundStyle(AppColors.whiteDefault)
                    .opacity(0.6)
            }
            
        }
       
    }
    
}

#Preview {
    ProfileToolbarItem()
}
