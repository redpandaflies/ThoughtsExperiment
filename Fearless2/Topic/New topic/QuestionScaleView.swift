//
//  QuestionScaleView.swift
//  Fearless2
//
//  Created by Yue Deng-Wu on 10/5/24.
//

import SwiftUI

struct QuestionScaleView: View {
    @Binding var selectedValue: Double
 
    let question: String
    let minLabel: String
    let maxLabel: String
    
    var body: some View {
        VStack (alignment: .leading, spacing: 10) {
            
            Text(question)
                .multilineTextAlignment(.leading)
                .font(.system(size: 19))
                .fontWeight(.semibold)
                .foregroundStyle(Color.white)
                .fixedSize(horizontal: false, vertical: true)
                .padding(.vertical, 10)
            
            SliderView(selectedValue: $selectedValue, minLabel: minLabel, maxLabel: maxLabel)
                .padding(.bottom, 30)
            
        }
       
    }
}


//#Preview {
//    QuestionScaleView()
//}
