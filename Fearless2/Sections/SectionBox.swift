//
//  SectionBox.swift
//  Fearless2
//
//  Created by Yue Deng-Wu on 10/14/24.
//

import SwiftUI

struct SectionBox: View {
    
    @ObservedObject var section: Section
    let isNextSection: Bool
    
    var archivedTopic: Bool {
        return section.topic?.topicStatus == TopicStatusItem.archived.rawValue
    }
    
    private var imageName: String {
        if section.completed {
            return "checkmark"
        } else if archivedTopic {
            return "lock.fill"
        } else if isNextSection {
            return "arrow.forward.circle.fill"
        } else {
            return "lock.fill"
        }
    }
    
    var body: some View {
        VStack (spacing: 5) {
            
            Text(section.sectionTitle)
                .multilineTextAlignment(.center)
                .font(.system(size: 17, weight: section.completed ? .regular : (archivedTopic ? .light : (isNextSection ? .regular : .light))))
                .fontWidth(.condensed)
                .foregroundStyle(section.completed ? AppColors.whiteDefault : (archivedTopic ? AppColors.whiteDefault : (isNextSection ? Color.black : AppColors.whiteDefault)))
                .padding(.bottom, 5)
            
            
            Text("\(section.sectionQuestions.count) prompts")
                .font(.system(size: 11, weight: archivedTopic ? .light : (isNextSection ? .regular : .light)))
                .fontWidth(.condensed)
                .foregroundStyle(section.completed ? AppColors.whiteDefault : (archivedTopic ? AppColors.whiteDefault : (isNextSection ? Color.black : AppColors.whiteDefault)))
                .opacity(0.6)
                .textCase(.uppercase)
              
            Spacer()
            
            getImage(name: imageName)
            
                
        }
        .opacity(section.completed ? 0.6 : (archivedTopic ? 0.4 : (isNextSection ? 1 : 0.4)))
        .padding()
        .frame(width: 150, height: 180)
        .contentShape(Rectangle())
        .background {
            RoundedRectangle(cornerRadius: 20)
                .fill(section.completed ? AppColors.green2 : (archivedTopic ? AppColors.darkGrey4 : (isNextSection ? AppColors.yellow1 : AppColors.darkGrey4)))
                .shadow(color: section.completed ? AppColors.green3 : (archivedTopic ? Color.clear : (isNextSection ? AppColors.lightBrown2 : Color.clear)), radius: 0, x: 0, y: 3)
        }
    }
    
    private func getImage(name: String) -> some View {
        Image(systemName: name)
            .font(.system(size: 25))
            .foregroundStyle(section.completed ? AppColors.whiteDefault : (archivedTopic ? AppColors.whiteDefault : (isNextSection ? Color.black : AppColors.whiteDefault)))
            .padding(.bottom)
    }
}

//#Preview {
//    HomeSectionBox(title: "Identify all possible options")
//}
