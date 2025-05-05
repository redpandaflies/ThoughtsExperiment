//
//  NewCategorySelectCategoryQuestion.swift
//  Fearless2
//
//  Created by Yue Deng-Wu on 4/9/25.
//

import SwiftUI

struct NewCategorySelectCategoryQuestion: View {
    @Binding var selectedCategory: String
    let question: String
    let items: [String]
    
    var body: some View {
        
        VStack (alignment: .leading, spacing: 15) {
            Text(question)
                .multilineTextAlignment(.leading)
                .font(.system(size: 22, design: .serif))
                .foregroundStyle(AppColors.textPrimary)
                .fixedSize(horizontal: false, vertical: true)
            
            
            Text("Choose the most important one")
                .multilineTextAlignment(.leading)
                .font(.system(size: 13, weight: .light).smallCaps())
                .foregroundStyle(AppColors.textPrimary.opacity(0.7))
                .fixedSize(horizontal: false, vertical: true)
                .padding(.bottom, 10)
               
            
            ScrollView (.horizontal) {
                HStack (alignment: .center, spacing: 15) {
                    ForEach(items, id: \.self) { item in
                        CategoryBoxView(
                            categoryName: item,
                            selected: item == selectedCategory
                        )
                        .onTapGesture {
                            selectBox(option: item)
                        }
                    }
                }
                .scrollTargetLayout()
            }
            .scrollClipDisabled(true)
            .scrollTargetBehavior(.viewAligned)
            .scrollIndicators(.hidden)
        }
    }
    
    private func selectBox(option: String) {
        if selectedCategory == option {
            selectedCategory = ""
        } else {
            selectedCategory = option
        }
    }
}

struct CategoryBoxView: View {
    
    let categoryName: String
    var selected: Bool
    
    var category: Realm {
        if let realm = Realm.getRealm(forName: categoryName) {
            return realm
        }
        
        return Realm.realmsData[0]
    }
    
    var body: some View {
        ZStack {
            Image(category.icon)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .opacity(selected ? 0.5 : 0.2)
                .blendMode(.luminosity)
                .frame(height: 230)
                .frame(alignment: .bottom)
                .offset(y: 100)
            
            VStack {
                Text(categoryName)
                    .multilineTextAlignment(.center)
                    .font(.system(size: 23, design: .serif))
                    .foregroundStyle(AppColors.textPrimary)
                    .opacity(selected ? 1 : 0.7)
                    .fixedSize(horizontal: false, vertical: true)
                    .frame(height: 65)
                    .frame(alignment: .center)
            }
            .frame(maxHeight: .infinity, alignment: .top)
            .padding(.top, 20)
             
               
        }
        .frame(width: 200, height: 300)
        .background {
            RoundedRectangle(cornerRadius: 20)
                .stroke(.white.opacity(selected ? 0.1 : 0.5), lineWidth: 0.5)
                .fill(
                    LinearGradient(
                    stops: [
                        Gradient.Stop(color: category.gradient1.opacity(selected ? 0.45 : 0.15), location: 0.00),
                    Gradient.Stop(color: category.gradient2.opacity(selected ? 0.45 : 0.15), location: 1.00),
                    ],
                    startPoint: UnitPoint(x: 0.03, y: 0.01),
                    endPoint: UnitPoint(x: 0.92, y: 1)
                    )
                    
                )
                .blendMode(.screen)
        }
        .clipShape(RoundedRectangle(cornerRadius: 20))
    }
}

//#Preview {
//    CategoryBoxView()
//}
