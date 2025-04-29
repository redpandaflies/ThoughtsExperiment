//
//  CarouselView.swift
//  Fearless2
//
//  Created by Yue Deng-Wu on 4/16/25.
//

import SwiftUI

struct CarouselView<Item, Content: View>: View {
  let items: [Item]
  @Binding var scrollPosition: Int?
  let pagesCount: Int
    let content: (Int, Item) -> Content

  init(
    items: [Item],
    scrollPosition: Binding<Int?>,
    pagesCount: Int,
    @ViewBuilder content: @escaping (Int, Item) -> Content
  ) {
    self.items = items
    self._scrollPosition = scrollPosition
    self.pagesCount = pagesCount
    self.content = content
  }

  var body: some View {
    VStack(spacing: 25) {
      ScrollView(.horizontal) {
        HStack(spacing: 15) {
          ForEach(Array(items.enumerated()), id: \.offset) { index, item in
              content(index, item)
              .id(index)
              .scrollTransition { content, phase in
                  content
                  .opacity(phase.isIdentity ? 1 : 0.3)
              }
          }
        }
        .scrollTargetLayout()
      }
      .scrollPosition(id: $scrollPosition, anchor: .leading)
      .scrollTargetBehavior(.viewAligned(limitBehavior: .alwaysByOne))
      .scrollIndicators(.hidden)
      .scrollClipDisabled()

      PageIndicatorView(
        scrollPosition: $scrollPosition,
        pagesCount: pagesCount
      )
    }
  }
}

struct CarouselBox: View {
    
    let orderIndex: Int
    let content: String
    
    var body: some View {
        VStack (alignment: .leading, spacing: 20){
            Text("\(orderIndex)")
                .multilineTextAlignment(.leading)
                .font(.system(size: 30, weight: .light))
                .foregroundStyle(AppColors.textPrimary)
                .opacity(0.5)
                .fixedSize(horizontal: false, vertical: true)
                .padding(.top, 40)
             
            
            Text("\(content)")
                .multilineTextAlignment(.leading)
                .font(.system(size: 20, design: .serif))
                .foregroundStyle(AppColors.textPrimary)
                .lineSpacing(1.4)
                .fixedSize(horizontal: false, vertical: true)
                
               
        }
        .padding(.horizontal)
        .frame(width: 300, height: 420, alignment: .topLeading)
        .background {
            RoundedRectangle(cornerRadius: 25)
                .stroke(AppColors.textSecondary.opacity(0.1), lineWidth: 0.5)
                .fill(AppColors.boxGrey1.opacity(0.3))
                .shadow(color: .black.opacity(0.05), radius: 15, x: 0, y: 3)
                .blendMode(.colorDodge)
        }
        
    }
}
