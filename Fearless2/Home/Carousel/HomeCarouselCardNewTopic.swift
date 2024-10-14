//
//  HomeCarouselCardNewTopic.swift
//  Fearless2
//
//  Created by Yue Deng-Wu on 10/1/24.
//

import SwiftUI

struct HomeCarouselCardNewTopic: View {
    var body: some View {
        ZStack (alignment: .top) {
            
            UnevenRoundedRectangle(cornerRadii: .init(topLeading: 20, topTrailing: 20))
                .fill(Color.white)
                .boxShadow()
//                .matchedGeometryEffect(id: "Background", in: animation)
            
            VStack (alignment: .center, spacing: 10) {
                
               Text("💡")
                    .font(.system(size: 30))
                    .foregroundStyle(AppColors.blackDefault)
                    .padding(.top, 30)
                
                Text("Add new topic")
                    .multilineTextAlignment(.center)
                    .font(.system(size: 17))
                    .fontWeight(.medium)
                    .foregroundStyle(AppColors.blackDefault)
                    .lineSpacing(2)
                    .padding(.horizontal, 2)
                
            }//VStack
            .padding()
        
        }//ZStack
    }
}

#Preview {
    HomeCarouselCardNewTopic()
}
