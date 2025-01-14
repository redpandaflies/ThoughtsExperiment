//
//  NewTopicHeader.swift
//  Fearless2
//
//  Created by Yue Deng-Wu on 12/31/24.
//

import SwiftUI

struct NewTopicHeader: View {
    
    let xmarkAction: () -> Void
    
    var body: some View {
        
        HStack (spacing: 30) {
            Text("New topic")
                .font(.system(size: 20, weight: .light).smallCaps())
                .fontWidth(.condensed)
                .foregroundStyle(AppColors.yellow1)
                
            
            Spacer()
            
            Button {
                xmarkAction()
            } label: {
                
                Image(systemName: "xmark.circle.fill")
                    .font(.system(size: 25))
                    .foregroundStyle(AppColors.whiteDefault.opacity(0.3))
            }
    
        }//HStack
        .padding(.vertical)
        
    }
}
