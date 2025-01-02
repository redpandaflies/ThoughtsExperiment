//
//  UnderstandToolbarItem.swift
//  Fearless2
//
//  Created by Yue Deng-Wu on 11/21/24.
//

import SwiftUI

struct UnderstandToolbarItem: View {
    
    let action: () -> Void
    
    var body: some View {
        
        VStack {
            Button {
              action()
            } label: {
                Image(systemName: "book.circle")
                    .font(.system(size: 18))
                    .foregroundStyle(AppColors.whiteDefault)
                    .opacity(0.6)
            }
            
        }
    }
}

//#Preview {
//    UnderstandToolbarItem()
//}
