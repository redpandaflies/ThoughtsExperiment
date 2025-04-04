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
    let buttonAction: () -> Void
    let isEndOfTopic: Bool
    let sectionIndex: Int
    
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
                .fixedSize(horizontal: false, vertical: true)
                .font(.system(size: 17, weight: section.completed ? .light : (archivedTopic ? .light : (isNextSection ? .regular : .light))))
                .fontWidth(.condensed)
                .foregroundStyle(section.completed ? AppColors.textPrimary : (archivedTopic ? AppColors.textPrimary : (isNextSection ? Color.black : AppColors.textPrimary)))
                .lineLimit(3)
                .padding(.bottom, 5)
            
            
            if !isEndOfTopic {
                Text("\(section.sectionQuestions.count) steps")
                    .font(.system(size: 11, weight: .light))
                    .fontWidth(.condensed)
                    .foregroundStyle(archivedTopic ? AppColors.textPrimary : (isNextSection ? Color.black : AppColors.textPrimary))
                    .opacity(archivedTopic ? 0.5 : (isNextSection ? 0.7 : 0.5))
                    .textCase(.uppercase)
            }
            
            if isEndOfTopic && sectionIndex == 0 {
                LaurelItem(size: 15, points: "+5", primaryColor: archivedTopic ? AppColors.textPrimary : (isNextSection ? Color.black : AppColors.textPrimary))
                    .opacity(archivedTopic ? 0.5 : (isNextSection ? 0.7 : 0.5))
            }
            
            
            Spacer()
            
            if isNextSection {
                RoundButton(buttonImage: "arrow.right", buttonAction: {
                    buttonAction()
                })
                
            } else {
                getImage(name: imageName)
            }
            
                
        }
        .opacity(section.completed ? 0.8 : (archivedTopic ? 0.4 : (isNextSection ? 1 : 0.4)))
        .padding()
        .padding(.bottom, 5)
        .frame(width: 150, height: 180)
        .contentShape(Rectangle())
        .background {
            RoundedRectangle(cornerRadius: 20)
                .stroke(AppColors.strokePrimary.opacity(section.completed ? 0.10 : (archivedTopic ? 0.30 : (isNextSection ? 0.50 : 0.30))), lineWidth: 0.5)
                .fill(AnyShapeStyle(backgroundColor()))
                .shadow(
                    color: shadowProperties().color,
                    radius: shadowProperties().radius,
                    x: 0,
                    y: shadowProperties().y
                )
        }
    }
    
    private func getImage(name: String) -> some View {
        Image(systemName: name)
            .font(.system(size: 25))
            .foregroundStyle(section.completed ? AppColors.whiteDefault : (archivedTopic ? AppColors.whiteDefault : (isNextSection ? Color.black : AppColors.whiteDefault)))
            .padding(.bottom)
    }
    
    private func backgroundColor() -> any ShapeStyle {
        switch (section.completed, archivedTopic, isNextSection) {
        case (true, _, _):
            return LinearGradient(
                gradient: Gradient(colors: [Color.white.opacity(0.03), Color.white.opacity(0.06)]),
                startPoint: .bottom,
                endPoint: .top
            )
        case (_, true, _):
            return Color.clear
        case (_, _, true):
            return LinearGradient(
                gradient: Gradient(colors: [AppColors.boxYellow1, AppColors.boxYellow2]),
                startPoint: .top,
                endPoint: .bottom
            )
        default:
            return Color.clear
        }
    }
    
    private func shadowProperties() -> (color: Color, radius: CGFloat, y: CGFloat) {
        switch (section.completed, archivedTopic, isNextSection) {
        case (true, _, _):
            return (Color.black.opacity(0.05), 5, 2)
        case (_, true, _):
            return (Color.clear, 0, 0)
        case (_, _, true):
            return (Color.black.opacity(0.30), 15, 3)
        default:
            return (Color.clear, 0, 0)
        }
    }
}

//#Preview {
//    HomeSectionBox(title: "Identify all possible options")
//}


