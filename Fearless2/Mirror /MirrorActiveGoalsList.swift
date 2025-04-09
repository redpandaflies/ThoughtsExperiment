//
//  MirrorActiveGoalsList.swift
//  Fearless2
//
//  Created by Yue Deng-Wu on 4/8/25.
//
import CoreData
import SwiftUI

struct MirrorActiveGoalsList: View {
    @State private var playHapticEffect: Int = 0
    @State private var goalsScrollPosition: Int?
    
    @Binding var categoriesScrollPosition: Int?
    
    var categories: FetchedResults<Category>
    
    var body: some View {
        
        VStack (alignment: .leading, spacing: 10) {
            Text("Active Explorations")
                .multilineTextAlignment(.leading)
                .font(.system(size: 13, weight: .light).smallCaps())
                .foregroundStyle(AppColors.textPrimary.opacity(0.7))
                .fixedSize(horizontal: false, vertical: true)
                .padding(.horizontal)
            
            ScrollView (.horizontal)  {
                HStack (alignment: .center, spacing: 15) {
                    ForEach(Array(categories.enumerated()), id: \.element.categoryId) { index, category in
                        ActiveGoalBox(category: category)
                            .id(index)
                            .onTapGesture {
                                goToCategory(index: index)
                            }
                            .sensoryFeedback(.selection, trigger: playHapticEffect)
                    }
                }
                .scrollTargetLayout()
            }
            .scrollPosition(id: $goalsScrollPosition, anchor: .leading)
            .contentMargins(.horizontal, 16, for: .scrollContent)
            .scrollClipDisabled(true)
            .scrollTargetBehavior(.viewAligned(limitBehavior: .alwaysByOne))
            .scrollIndicators(.hidden)
            
        }
        .onAppear {
            playHapticEffect = 0
            goalsScrollPosition = 0
            
        }
    }
    
    private func goToCategory(index: Int) {
        playHapticEffect += 1
        withAnimation (.snappy(duration: 0.2)) {
            categoriesScrollPosition = index + 1
        }
    }
}

struct ActiveGoalBox: View {
    
    let category: Category
    
    var categoryTopics: [Topic] {
       return category.categoryTopics
    }
    
    var totalCompletedTopics: Int {
        let completedTopics = categoryTopics.filter { $0.topicStatus == TopicStatusItem.completed.rawValue }
        return completedTopics.count
    }
    
    var body: some View {
        VStack (spacing: 10) {
            
            Image(category.categoryEmoji)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(height: 50)
                .blendMode(.luminosity)
            
            Text("Make a Decision")
                .multilineTextAlignment(.center)
                .font(.system(size: 13, weight: .light).smallCaps())
                .foregroundStyle(AppColors.textPrimary.opacity(0.7))
                .fixedSize(horizontal: false, vertical: true)
                
            
            GoalProgressBar(totalTopics: categoryTopics.count, totalCompletedTopics: totalCompletedTopics)
            
            Text("Startup versus 9-to-5")
                .multilineTextAlignment(.center)
                .font(.system(size: 16, weight: .semibold, design: .serif))
                .foregroundStyle(AppColors.textPrimary)
                .fixedSize(horizontal: false, vertical: true)
                .frame(width: 160) //same as progress bar
            
            Spacer()
            
            RoundButton(
                buttonImage: "arrow.right",
                buttonAction: {
                    
                }
            )
            .disabled(true)

        }
        .padding(.vertical, 20)
        .padding(.horizontal, 25)
        .frame(width: 200, height: 260)
        .background {
            RoundedRectangle(cornerRadius: 20)
                .stroke(.white.opacity(0.1), lineWidth: 0.5)
                .fill(
                    LinearGradient(
                    stops: [
                        Gradient.Stop(color: getGradient1(), location: 0.00),
                    Gradient.Stop(color: getGradient2(), location: 1.00),
                    ],
                    startPoint: UnitPoint(x: 0.03, y: 0.01),
                    endPoint: UnitPoint(x: 0.92, y: 1)
                    )
                    
                )
                .shadow(color: .black.opacity(0.15), radius: 5, x: 0, y: 3)
                .blendMode(.screen)
        }
    }
    
    private func getGradient1() -> Color {
       
        return Realm.getGradient1(forName: category.categoryName)

    }
    
    private func getGradient2() -> Color {
        return Realm.getGradient2(forName: category.categoryName)
    }
}

struct GoalProgressBar: View {
    
    let totalTopics: Int
    let totalCompletedTopics: Int
    
    let wholeBarWidth: CGFloat = 160
   
    var progressBarWidth: CGFloat {
        if totalTopics > 0 {
            var barWidth: CGFloat = wholeBarWidth * 0.1
            barWidth = (wholeBarWidth/CGFloat (totalTopics)) * CGFloat(totalCompletedTopics)
            return barWidth
        } else {
            return wholeBarWidth * 0.1
        }
    }
    
    var body: some View {
        
      
        ZStack (alignment: .leading) {
            RoundedRectangle(cornerRadius: 50)
                .fill(AppColors.progressBarPrimary.opacity(0.3))
                .frame(width: wholeBarWidth, height: 2)
            
            
            RoundedRectangle(cornerRadius: 50)
                .fill(AppColors.progressBarPrimary)
                .frame(width: progressBarWidth, height: 2)
                .contentTransition(.interpolate)
            
        }//ZStack
       

    }
}

//#Preview {
//    MirrorActiveGoalsList()
//}
