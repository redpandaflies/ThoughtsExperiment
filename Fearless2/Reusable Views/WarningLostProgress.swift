//
//  WarningLostProgress.swift
//  Fearless2
//
//  Created by Yue Deng-Wu on 11/29/24.
//

import SwiftUI

struct WarningLostProgress: View {
    @Environment(\.dismiss) var dismiss
    var quitAction: () -> Void
    
    var body: some View {
        
        VStack (spacing: 10){
            Text("⚠️")
                .font(.system(size: 20))
            
            Text("You'll lose your progress on this section if you quit")
                .font(.system(size: 20))
                .foregroundStyle(AppColors.whiteDefault)
                .padding(.bottom, 20)
            
            Spacer()
            
            Button {
                dismiss()
            } label: {
                RectangleButton(buttonName: "Keep going", buttonColor: Color.black, backgroundColor: AppColors.yellow1)
            }
            
            
            Button {
                quitAction()
            } label: {
                RectangleButton(buttonName: "Quit", buttonColor: AppColors.whiteDefault)
            }
            
            
        }
        .padding(.bottom, 20)
        .padding()
        
    }
}
