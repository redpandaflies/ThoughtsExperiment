//
//  TopicPickerView.swift
//  Fearless2
//
//  Created by Yue Deng-Wu on 11/13/24.
//

import SwiftUI


struct TopicPickerView: View {
    
    @Binding var selectedTab: TopicPickerItem
    let selectedCategory: TopicCategoryItem
    
    
    let screenWidth = UIScreen.current.bounds.width
    
    var body: some View {
        HStack {
            ForEach(TopicPickerItem.allCases, id: \.self) { item in
                Group {
                    Text("\(item.rawValue)")
                        .font(.system(size: 17))
                        .foregroundStyle(selectedCategory.getCategoryColor())
                        .textCase(.uppercase)
                        .opacity(item == selectedTab ? 1: 0.5)
                }
                .frame(width: 90, height: 20)
                .contentShape(Rectangle())
                .onTapGesture {
                    selectedTab = item
                }
                .sensoryFeedback(.selection, trigger: item == selectedTab) { oldValue, newValue in
                    return oldValue != newValue && newValue == true
                }
                
                if item != TopicPickerItem.allCases.last {
                    Spacer()
                }
            }
        }
        .padding(.vertical)
    }
}
