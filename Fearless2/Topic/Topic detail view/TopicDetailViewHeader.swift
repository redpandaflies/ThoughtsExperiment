//
//  TopicDetailViewHeader.swift
//  Fearless2
//
//  Created by Yue Deng-Wu on 11/24/24.
//

import SwiftUI

struct TopicDetailViewHeader: View {
    
    let title: String
    let screenWidth = UIScreen.current.bounds.width
    
    var body: some View {
        VStack (spacing: 10){
            
            Text(title)
                .multilineTextAlignment(.center)
                .font(.system(size: 17, weight: .light))
                .foregroundStyle(AppColors.whiteDefault)
                .padding(.horizontal, 5)
            
            Image("squiggleLine")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .padding(.bottom, 15)
        }
        .padding(.top)
        .frame(width: 270)     
    }
}

#Preview {
    TopicDetailViewHeader(title: "Meaningful and rewarding work")
}
