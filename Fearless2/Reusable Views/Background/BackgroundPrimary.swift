//
//  BackgroundPrimary.swift
//  Fearless2
//
//  Created by Yue Deng-Wu on 2/13/25.
//

import SwiftUI

struct BackgroundPrimary<S: ShapeStyle>: View {
    let backgroundColor: S
    let backgroundImage: String
    
    init(
        backgroundColor: S,
        backgroundImage: String = "backgroundPrimary"
    ) {
        self.backgroundColor = backgroundColor
        self.backgroundImage = backgroundImage
    }
    
    
    var body: some View {
        
        GeometryReader { geo in
            //geometryreader needed to keep the image from being pushed up by keyboard
            
            Image(backgroundImage)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .ignoresSafeArea()
                .background {
                    Rectangle()
                        .fill(backgroundColor)
                        .ignoresSafeArea()
                }
        }
        .ignoresSafeArea(.keyboard, edges: .all)
    }
    
   
}

//#Preview {
//    AppBackground()
//}
