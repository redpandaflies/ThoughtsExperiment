//
//  MirrorActiveGoalsList.swift
//  Fearless2
//
//  Created by Yue Deng-Wu on 4/8/25.
//
import CoreData
import SwiftUI

struct MirrorActiveGoalsList: View {
    @EnvironmentObject var viewModelFactoryMain: ViewModelFactoryMain
    @State private var playHapticEffect: Int = 0
    @State private var goalsScrollPosition: Int?
    @State private var showNewGoalSheet: Bool = false
    @State private var cancelledCreateNewCategory: Bool = false //prevents scroll if user exits create new category flow
    
    @Binding var categoriesScrollPosition: Int?
    
    var categories: FetchedResults<Category>
    
    @AppStorage("currentCategory") var currentCategory: Int = 0
    
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
                    AddGoalButton(buttonAction: {
                        // none
                    })
                    .id(categories.count)
                    .onTapGesture {
                        showNewGoalSheet = true
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
            currentCategory = 0
        }
        .fullScreenCover(isPresented: $showNewGoalSheet, onDismiss: {
            showNewGoalSheet = false
        }) {
            NewCategoryView(
                newCategoryViewModel: viewModelFactoryMain.makeNewCategoryViewModel(),
                showNewGoalSheet: $showNewGoalSheet,
                cancelledCreateNewCategory: $cancelledCreateNewCategory,
                    categories: categories
            )
        }
        .onChange(of: showNewGoalSheet) {
            if !showNewGoalSheet && !cancelledCreateNewCategory {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    withAnimation(.snappy(duration: 0.25)) {
                        categoriesScrollPosition = categories.count
                    }
                }
            } else {
                cancelledCreateNewCategory = false
            }
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
    
    var categoryGoal: Goal? {
        return category.categoryGoals.first
    }
    
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
            
            Text(categoryGoal?.goalProblemType ?? "Feel more content")
                .multilineTextAlignment(.center)
                .font(.system(size: 13, weight: .light).smallCaps())
                .foregroundStyle(AppColors.textPrimary.opacity(0.7))
                .fixedSize(horizontal: false, vertical: true)
                
            
            GoalProgressBar(totalTopics: categoryTopics.count, totalCompletedTopics: totalCompletedTopics, wholeBarWidth: 160)
            
            Text(categoryGoal?.goalTitle ?? "")
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
                        Gradient.Stop(color: getGradient1().opacity(0.5), location: 0.00),
                        Gradient.Stop(color: getGradient2().opacity(0.5), location: 1.00),
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
    
    let wholeBarWidth: CGFloat
   
    var progressBarWidth: CGFloat {
        let defaultWidth: CGFloat =  wholeBarWidth * 0.05
        if totalTopics > 0 {
            var barWidth: CGFloat = defaultWidth
            barWidth = (wholeBarWidth/CGFloat (totalTopics)) * CGFloat(totalCompletedTopics)
            return max(barWidth, defaultWidth)
        } else {
            return defaultWidth
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

struct AddGoalButton: View {
    
 
    let buttonAction: () -> Void
    
    var body: some View {

            
        VStack {
            
            Text("Add new goal")
                .multilineTextAlignment(.center)
                .font(.system(size: 16, weight: .semibold, design: .serif))
                .foregroundStyle(AppColors.textBlack)
                .lineSpacing(1.3)
                .padding(.horizontal)
            
            
            Spacer()
            
            RoundButton(buttonImage: "plus", buttonAction: {
                buttonAction()
            })
            .disabled(true)
            
            
        }
        .padding(.top, 40)
        .padding(.bottom, 20)
        .frame(width: 200, height: 260)
        .contentShape(RoundedRectangle(cornerRadius: 25))
        .background {
            RoundedRectangle(cornerRadius: 15)
                .stroke(AppColors.strokePrimary.opacity(0.50), lineWidth: 0.5)
                .fill(
                    LinearGradient(
                    stops: [
                        Gradient.Stop(color: .white, location: 0.00),
                        Gradient.Stop(color: AppColors.boxSecondary, location: 1.00),
                    ],
                    startPoint: UnitPoint(x: 0.03, y: 0.01),
                    endPoint: UnitPoint(x: 0.92, y: 1)
                    )
                )
                .shadow(color: .black.opacity(0.15), radius: 5, x: 0, y: 3)
               
        }
            
           
   
    }
}

//#Preview {
//    MirrorActiveGoalsList()
//}
