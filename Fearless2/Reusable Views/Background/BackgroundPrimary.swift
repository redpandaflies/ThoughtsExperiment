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
    let addBlur: Bool
    
    init(
        backgroundColor: S,
        backgroundImage: String = "backgroundPrimary",
        addBlur: Bool = false
    ) {
        self.backgroundColor = backgroundColor
        self.backgroundImage = backgroundImage
        self.addBlur = addBlur
    }
    
    
    var body: some View {
        
        GeometryReader { geo in
            //geometryreader needed to keep the image from being pushed up by keyboard
            
            Image(backgroundImage)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .blur(radius: addBlur ? 30 : 0)
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
