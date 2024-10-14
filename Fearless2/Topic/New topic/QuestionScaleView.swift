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
                .foregroundStyle(AppColors.blackDefault)
                .padding(.vertical, 10)
            
            SliderView(selectedValue: $selectedValue, minLabel: minLabel, maxLabel: maxLabel)
                .padding(.bottom, 30)
            
        }
       
    }
}


struct SliderView: View {
    @Binding var selectedValue: Double
    
    let minLabel: String
    let maxLabel: String
    
    var body: some View {
        VStack {
            Slider(value: $selectedValue, in: 0...10, step: 1.0)
                .tint(Color.yellow)
           
            HStack {
                Text(minLabel)
                    .font(.system(size: 11))
                    .fontWeight(.light)
                    .foregroundStyle(AppColors.blackDefault)
                    .textCase(.uppercase)
                
                Spacer()
                    
                
                Text(maxLabel)
                    .font(.system(size: 11))
                    .fontWeight(.light)
                    .foregroundStyle(AppColors.blackDefault)
                    .textCase(.uppercase)
            }
            
           
        }
    }
}

//#Preview {
//    QuestionScaleView()
//}
