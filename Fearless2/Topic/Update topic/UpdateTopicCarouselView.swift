//
//  UpdateTopicCarouselView.swift
//  Fearless2
//
//  Created by Yue Deng-Wu on 4/14/25.
//
import Mixpanel
import OSLog
import SwiftUI

struct UpdateTopicCarouselView<Item>: View {
    
    @Binding var scrollPosition: Int?
    
    let title: String
    let items: [Item]
    let extractContent: (Item) -> String
    
    let frameWidth: CGFloat = 310
    
    init(
        title: String,
        items: [Item],
        scrollPosition: Binding<Int?>,
        extractContent: @escaping (Item) -> String
      ) {
        self.title = title
        self.items = items
        self._scrollPosition = scrollPosition
        self.extractContent = extractContent
      }
    
    var body: some View {
        
        VStack (alignment: .leading, spacing: 10) {
            Text(title)
                .multilineTextAlignment(.leading)
                .font(.system(size: 25, design: .serif))
                .foregroundStyle(AppColors.textPrimary)
                .fixedSize(horizontal: false, vertical: true)
                .padding(.bottom)
                .padding(.horizontal)
            
            CarouselView(
                items: items,
                scrollPosition: $scrollPosition,
                pagesCount: items.count) { index, item in
                CarouselBox(
                    orderIndex: index + 1,
                    content: extractContent(item)
                )
            }
            .padding(.horizontal, 15)
        }
        .padding(.top, 20)
        .padding(.bottom)
        .frame(maxHeight: .infinity, alignment: .top)
    }
    
}


