//
//  QuestMapCircle.swift
//  Fearless2
//
//  Created by Yue Deng-Wu on 4/23/25.
//
import Pow
import SwiftUI

struct QuestMapCircle: View {
    @ObservedObject var topic: Topic
    
    @State private var playAnimation: Bool = false
//    @State private var timer: Timer? = nil
    
    let backgroundColor: Color
    let nextQuest: Bool //quest that is next but yet active (user has not picked the quest yet)
    
    private var questType: QuestTypeItem {
       return QuestTypeItem(rawValue: topic.topicQuestType) ?? .guided
    }
    
    private var questStatus: TopicStatusItem {
        return TopicStatusItem.init(rawValue: topic.topicStatus) ?? .locked
    }
    
    private var questIcon: String {
       return questType.getIconName()
    }
    
    var body: some View {
        Group {
            
            switch questType {
            case .guided, .context:
                if questStatus == .active || questStatus == .completed {
                    getEmoji()
                } else {
                    getSFSymbol(size: 25)
                }
            default:
                getSFSymbol(size: getSFSymbolSize())
            }
          
        }
        .frame(width: 60, height: 60)
        .background(
            Circle()
                .stroke(getStrokeColor(), lineWidth: 0.5)
                .fill(getFillStyle())
                .shadow(color: Color.black.opacity(0.05), radius: 15, x: 0, y: 3)
                .blendMode(questStatus == .completed ? .colorDodge : .normal)
//                .padding(questStatus == .active || nextQuest ? 7 : 0)
//                .background {
//                    Circle()
//                        .stroke(questStatus == .active || nextQuest ? .white.opacity(0.4) : .clear, lineWidth: 0.5)
//                        .fill(Color.clear)
//                }
        )
        .conditionalEffect(
              .repeat(
                .glow(color: AppColors.boxYellow1, radius: 70),
                every: 4
              ),
              condition: playAnimation
          )
        .onAppear {
            if questStatus == .active || nextQuest {
                playAnimation = true
            }
        }
        .onChange(of: nextQuest) {
            if questStatus == .completed {
                playAnimation = false
            } else if questStatus == .active || nextQuest {
                playAnimation = true
            }
        }
        .onDisappear {
            playAnimation = false
        }
    }
    
    private func getSFSymbol(size: CGFloat) -> some View {
        
        ZStack {
                    
            // the darker inset image
            Image(systemName: questIcon)
                .font(.system(size: size, weight: .heavy))
                .foregroundStyle(
                    questStatus == .locked && !nextQuest ?  backgroundColor.opacity(0.2) : Color.white.opacity(0.9)
                )
                .shadow(color: questStatus == .locked && !nextQuest ? .clear : Color.black.opacity(0.15), radius: 1, x: 0, y: 1)
           
            // black inner shadow
            if questStatus == .locked && !nextQuest {
                Rectangle()
                    .inverseMask(Image(systemName: questIcon).font(.system(size: size, weight: .heavy)))
                    .shadow(color: Color.black.opacity(0.15), radius: 1, x: 0, y: 1)
                    .mask(Image(systemName: questIcon).font(.system(size: size, weight: .heavy)))
                    .clipped()
            }
            
        }
    }
    
    private func getEmoji() -> some View {
        Text(topic.topicEmoji)
            .font(.system(size: 20))
    }
    
    private func getFillStyle() -> AnyShapeStyle {
        switch questStatus {
        case .completed:
            return AnyShapeStyle(
                AppColors.boxGrey1.opacity(0.3)
            )
        case .active:
            return AnyShapeStyle(
                LinearGradient(
                    gradient: Gradient(colors: [AppColors.boxYellow1, AppColors.boxYellow2]),
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
        default:
            return nextQuest ? AnyShapeStyle(
                LinearGradient(
                    gradient: Gradient(colors: [AppColors.boxYellow1, AppColors.boxYellow2]),
                    startPoint: .top,
                    endPoint: .bottom
                )
            ) : AnyShapeStyle(
                LinearGradient(
                    gradient: Gradient(colors: [.white, AppColors.boxPrimary]),
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
        }
    }
    
    private func getStrokeColor() -> Color {
        switch questStatus {
        case .completed:
           return Color.white.opacity(0.1)
          
        case .active:
            return Color.white
        default:
            return nextQuest ? Color.white : Color.white.opacity(0.9)
            
        }
    }
    
    private func getSFSymbolSize() -> CGFloat {
        switch questType {
            case .newCategory, .context:
                return 20
            default:
            return 25
        }
    }
  
}
