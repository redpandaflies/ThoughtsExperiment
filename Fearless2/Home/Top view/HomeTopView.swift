//
//  HomeTopView.swift
//  Fearless2
//
//  Created by Yue Deng-Wu on 9/30/24.
//

import SwiftUI

struct HomeTopView: View {
    
    let topicFeedback: String
    
    var body: some View {
       
        VStack (alignment: .leading) {
//            Text("tl;dr")
//                .multilineTextAlignment(.leading)
//                .font(.system(size: 14))
//                .fontWeight(.semibold)
//                .foregroundStyle(AppColors.blackDefault)
            
            HStack {
                Text(topicFeedback)
                    .multilineTextAlignment(.leading)
                    .font(.system(size: 15))
                    .fontWeight(.light)
                    .foregroundStyle(AppColors.blackDefault)
                    .lineSpacing(3)
                
                Spacer()
                
            }
            
            Spacer()
        }
        .padding()
        .frame(height: 190)
        .contentShape(Rectangle())
        .background {
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.white)
        }
        
    }
}

#Preview {
    HomeTopView(topicFeedback: "This and that and the other")
}
