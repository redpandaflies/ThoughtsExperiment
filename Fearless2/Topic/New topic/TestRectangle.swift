//
//  TestRectangle.swift
//  Fearless2
//
//  Created by Yue Deng-Wu on 3/30/25.
//
import Pow
import SwiftUI

//enum DefaultAnimationState: Hashable {
//    case animation(Int)
//}
//
//struct TestRectangle: View {
//    @State private var animationSet: Set<Int> = [0, 1, 2]
//    
//    let texts = ["Hello", "Bye", "Oh no!"]
//    
//    var body: some View {
//        
//       
//       
//                VStack {
//                    ForEach(Array(texts.enumerated()), id: \.offset) { (index, text) in
//                        if animationSet.contains(index) {
//                            HelloView(text: text)
//                                .transition(.movingParts.poof)
//                                .contentShape(Rectangle())
//                                .onTapGesture {
//                                    let newSet = Set([0, 1])
//                                    let removed = animationSet.subtracting(newSet)
//                                    
//                                    withAnimation {
//                                        animationSet.subtract(removed)
//                                    }
//                                }
//                        }
//                    }
//                }
//            
//        
//   
//    }
//    
//    private func HelloView(text: String) -> some View {
//        VStack {
//        Text(text)
//        }
//        .frame(width: 200, height: 200)
//        .background {
//            RoundedRectangle(cornerRadius: 20)
//                .fill(Color.blue)
//        }
//    }
//}

//#Preview {
//    TestTextBox()
//}
