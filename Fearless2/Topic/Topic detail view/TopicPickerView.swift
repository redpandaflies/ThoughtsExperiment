//
//  TopicPickerView.swift
//  Fearless2
//
//  Created by Yue Deng-Wu on 11/13/24.
//

import SwiftUI


struct TopicPickerView: View {
    
    @Binding var selectedTabTopic: TopicPickerItem
    
    let screenWidth = UIScreen.current.bounds.width
    
    var body: some View {
        HStack {
            ForEach(TopicPickerItem.allCases, id: \.self) { item in
                Group {
                    Text("\(item.rawValue)")
                        .font(.system(size: 12))
                        .foregroundStyle(AppColors.textPrimary)
                        .textCase(.uppercase)
                        .opacity(item == selectedTabTopic ? 1: 0.7)
                        .fixedSize(horizontal: true, vertical: false)
                }
                .padding(.horizontal, 15)
                .padding(.vertical, 5)
                .background {
                    Capsule(style: .circular)
                        .stroke(item == selectedTabTopic ? Color.white.opacity(0.1) : Color.clear, lineWidth: 0.5)
                        .fill(
                            getFill(item: item)
                                .shadow(.inner(color:  Color.black.opacity(0.25), radius: 1, x: 0, y: 2))
                        )
                }
                .frame(width: 80)
                .contentShape(Rectangle())
                .onTapGesture {
                    selectedTabTopic = item
                    if item == selectedTabTopic {
                        let generator = UIImpactFeedbackGenerator(style: .medium)
                        generator.impactOccurred()
                    }
                }
                
            }
        }
    }
    
    private func getFill(item: TopicPickerItem) -> Color {
        return item == selectedTabTopic ? Color.black.opacity(0.3) : Color.clear
    }
}
