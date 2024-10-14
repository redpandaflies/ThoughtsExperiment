//
//  HomeCarouselView.swift
//  Fearless2
//
//  Created by Yue Deng-Wu on 9/30/24.
//

import SwiftUI

struct HomeCarouselView: View {
    
    @Binding var scrollPosition: Int?
    
    let pageWidth: CGFloat = 180
    let pageHeight: CGFloat = 200
    var widthDifference: CGFloat {
        return UIScreen.current.bounds.width - pageWidth
    }
    let topics: [Topic]
    var numberOfTopics: Int {
        return topics.count
    }
    
    var body: some View {
        ScrollView(.horizontal) {
            HStack (alignment: .bottom){
                
               
                ForEach(Array(topics.enumerated()), id: \.element.objectID) { index, topic in
                    
                    HomeCarouselCardView(topic: topic)
                        .id(index)
                        .frame(width: pageWidth, height: (index == scrollPosition) ? pageHeight * 1.15 : pageHeight)
                        .opacity((index == scrollPosition) ? 1 : 0.5)
                        .animation(.smooth, value: scrollPosition)
                        .onTapGesture {
                            //TBD
                        }
                }//ForEach
               
                
                HomeCarouselCardNewTopic()
                    .id(numberOfTopics)
                    .frame(width: pageWidth, height: (scrollPosition == numberOfTopics) ? pageHeight * 1.15 : pageHeight)
                    .opacity((scrollPosition == numberOfTopics) ? 1: 0.5)
                    .animation(.smooth, value: scrollPosition)
               
            }//HStack
            .scrollTargetLayout()
        }
        .scrollPosition(id: $scrollPosition, anchor: .center)
        .safeAreaPadding(.horizontal, (widthDifference)/2)
        .scrollIndicators(.hidden)
        .scrollTargetBehavior(.viewAligned)
        .frame(height: pageHeight * 1.15)
        .onAppear {
            if numberOfTopics > 0 {
                scrollPosition = topics.count - 1
            } else {
                scrollPosition = 0
            }
        }
        .onChange(of: scrollPosition) {
            print("scroll position: \(String(describing: scrollPosition))")
            if let index = scrollPosition, index < topics.count {
                print("topic questions: \(String(describing: topics[index].questions?.count))")
            }
            
        }
    }
}

//#Preview {
//    AppViewsManager()
//}
