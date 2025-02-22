//
//  AppBackground.swift
//  Fearless2
//
//  Created by Yue Deng-Wu on 2/13/25.
//

import SwiftUI

struct AppBackground: View {
    let backgroundColor: Color
    
    
    var body: some View {
        
        GeometryReader { geo in
            //geometryreader needed to keep the image from being pushed up by keyboard
            
            Image("backgroundPrimary")
                .resizable()
                .aspectRatio(contentMode: .fill)
                .ignoresSafeArea()
                .background {
                    backgroundColor
                        .ignoresSafeArea()
                }
        }
        .ignoresSafeArea(.keyboard, edges: .all)
    }
    
   
}

//#Preview {
//    AppBackground()
//}
