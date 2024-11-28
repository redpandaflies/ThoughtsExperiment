//
//  SliderView.swift
//  Fearless2
//
//  Created by Yue Deng-Wu on 10/29/24.
//

import SwiftUI

struct SliderView: View {
    @Binding var selectedValue: Double
    
    let minLabel: String
    let maxLabel: String
    
    var body: some View {
        VStack {
            Slider(value: $selectedValue, in: 0...10, step: 1.0)
                .tint(AppColors.yellow1)
           
            HStack {
                Text(minLabel)
                    .font(.system(size: 11))
                    .fontWeight(.light)
                    .foregroundStyle(Color.white)
                    .textCase(.uppercase)
                
                Spacer()
                    
                
                Text(maxLabel)
                    .font(.system(size: 11))
                    .fontWeight(.light)
                    .foregroundStyle(Color.white)
                    .textCase(.uppercase)
            }
           
        }
    }
}

//#Preview {
//    SliderView()
//}
