//
//  TopicBox.swift
//  Fearless2
//
//  Created by Yue Deng-Wu on 11/7/24.
//

import SwiftUI

struct TopicBox: View {

    @ObservedObject var topic: Topic
    var nextSection: Section? {
        return topic.topicSections.min { $0.sectionNumber < $1.sectionNumber }
    }
    var topicCategory: TopicCategoryItem {
        return TopicCategoryItem.fromShortName(topic.topicCategory) ?? .relationships
    }
    
    var body: some View {
        VStack (alignment: .leading) {
            
            HStack {
                Image(systemName: topicCategory.getCategoryEmoji())
                    .symbolRenderingMode(.monochrome)
                    .foregroundStyle(topicCategory.getCategoryColor())
                
               Spacer()
            }
            
            
            Text(topic.topicTitle)
                .font(.system(size: 19))
                .foregroundStyle(topicCategory.getCategoryColor())
                .padding(.top, 1)
                .padding(.bottom, 30)
            
            Spacer()
            
            
            Text("Next")
                .font(.system(size: 11, weight: .regular))
                .foregroundStyle(Color.white)
                .opacity(0.6)
                .textCase(.uppercase)
            
            if let section = nextSection {
                Text(section.sectionTitle)
                    .font(.system(size: 11, weight: .regular))
                    .foregroundStyle(Color.white)
                    .opacity(0.9)
            }
        }
        .padding()
        .frame(height: 230)
        .contentShape(Rectangle())
        .background {
            RoundedRectangle(cornerRadius: 20)
                .stroke(topicCategory.getCategoryColor(), lineWidth: 1)
        }
//        .background(Color.black)
    }
}

//#Preview {
//    TopicBox()
//}
