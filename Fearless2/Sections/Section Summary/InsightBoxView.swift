//
//  InsightBoxView.swift
//  Tinyverse
//
//  Created by Yue Deng-Wu on 10/23/24.
//

import SwiftUI

struct InsightBoxView: View {
    
    @ObservedObject var insight: Insight
    
    var body: some View {
        HStack (alignment: .top, spacing: 10){
           
            Image(systemName: "plus.circle")
                .font(.system(size: 25))
                .fontWeight(.light)
                .foregroundStyle(Color.white)
                .contentTransition(.symbolEffect(.replace.offUp.byLayer))
                
            HStack {
                Text(insight.insightContent)
                    .font(.system(size: 15))
                    .foregroundStyle(Color.white)
                    .fixedSize(horizontal: false, vertical: true)
                
                Spacer()
            }//HStack
           

        }//HStack
        .contentShape(Rectangle())
    }
}

//#Preview {
//    InsightBoxView()
//}
