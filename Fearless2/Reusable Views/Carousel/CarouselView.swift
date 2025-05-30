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
    let showGrid: Bool

  init(
    items: [Item],
    scrollPosition: Binding<Int?>,
    pagesCount: Int,
    @ViewBuilder content: @escaping (Int, Item) -> Content,
    showGrid: Bool = false
  ) {
    self.items = items
    self._scrollPosition = scrollPosition
    self.pagesCount = pagesCount
    self.content = content
    self.showGrid = showGrid
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
    let showGrid: Bool
    
    let symbolList: [String] = [
        "book.pages.fill",
        "questionmark",
        "cube.transparent",
        "clock.arrow.circlepath"
    ]
    let columns = [
        GridItem(.fixed(67), spacing: 0),
        GridItem(.fixed(67), spacing: 0),
        GridItem(.fixed(67), spacing: 0),
        GridItem(.fixed(67), spacing: 0)
    ]
    
    init(orderIndex: Int, content: String, showGrid: Bool = false) {
        self.orderIndex = orderIndex
        self.content = content
        self.showGrid = showGrid
    }
    
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
            
            if showGrid {
                LazyVGrid(columns: columns, spacing: 20) {
                  ForEach(symbolList.indices, id: \.self) { idex in
                    getCircle(symbol: symbolList[idex])
                  }
                }
                .frame(width: 268, alignment: .leading)
                .padding(.top, 10)
            }
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
    
    private func getCircle(symbol: String) -> some View {
        ZStack {
            // the darker inset image
            Image(systemName: symbol)
                .font(.system(size: 20, weight: .heavy))
                .foregroundStyle(AppColors.buttonLightGrey2)
           
            // black inner shadow
            Rectangle()
                .inverseMask(Image(systemName: symbol).font(.system(size: 20, weight: .heavy)))
                .shadow(color: Color.black.opacity(0.15), radius: 1, x: 0, y: 1)
                .mask(Image(systemName: symbol).font(.system(size: 20, weight: .heavy)))
                .clipped()
            
            
        }
        .frame(width: 50, height: 50)
        .background(
            Circle()
                .stroke(Color.white.opacity(0.9), lineWidth: 0.5)
                .fill(
                    LinearGradient(
                    gradient: Gradient(colors: [.white, AppColors.boxPrimary]),
                    startPoint: .top,
                    endPoint: .bottom
                )
                )
                .shadow(color: Color.black.opacity(0.05), radius: 15, x: 0, y: 3)
               

        )
    }
}
