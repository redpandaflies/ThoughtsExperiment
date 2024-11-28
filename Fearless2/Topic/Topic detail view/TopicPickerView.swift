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
                        .foregroundStyle(Color.white)
                        .textCase(.uppercase)
                        .opacity(0.7)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .padding(.horizontal, 10)
                .padding(.vertical, 5)
                .background {
                    Capsule(style: .circular)
                        .fill(item == selectedTabTopic ? Color.white.opacity(0.05) : Color.clear)
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
}
