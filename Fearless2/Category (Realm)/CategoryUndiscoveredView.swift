//
//  CategoryUndiscoveredView.swift
//  Fearless2
//
//  Created by Yue Deng-Wu on 2/7/25.
//
import Mixpanel
import SwiftUI

struct CategoryUndiscoveredView: View {
    
    @AppStorage("currentAppView") var currentAppView: Int = 0
    
    let topics: FetchedResults<Topic>
    let category: Realm
    let showUndiscovered: Bool
    let unlockedCategories: Int
    
    var topicsCompleted: Int {
        return topics.filter { $0.completed == true }.count
    }
    
    
    var body: some View {
        VStack {
            
            VStack (spacing: 13) {
                Text("Undiscovered Realm")
                    .multilineTextAlignment(.center)
                    .font(.system(size: 25, design: .serif))
                    .foregroundStyle(AppColors.textPrimary)
                
                Text(category.undiscoveredDescription)
                    .multilineTextAlignment(.center)
                    .font(.system(size: 16, weight: .light))
                    .foregroundStyle(AppColors.textPrimary.opacity(0.8))
                    .lineSpacing(1.5)
            }
            .padding(.vertical, 25)
            .padding(.horizontal, 30)
            .padding(.bottom, 45)
          
          
            
            CategoryMissionView(category: category, topicsCompleted: topicsCompleted, showUndiscovered: showUndiscovered, unlockedCategories: unlockedCategories)
                .padding(.bottom, 30)
          
            if showUndiscovered && category.orderIndex != 6 {
                
                DiscoverNewCategoryButton()
                    .onTapGesture {
                        startNewRealmFlow()
                    }
            }
            
        }
      

    }
    
    private func shortLine() -> some View {
        Rectangle()
            .fill(Color.white.opacity(0.05))
            .frame(maxWidth: .infinity)
            .frame(height: 1)
    }
    
    private func startNewRealmFlow() {
        
        currentAppView = 2
        
        DispatchQueue.global(qos: .background).async {
            Mixpanel.mainInstance().track(event: "Started unveiling a new realm")
        }
    }
}


struct DiscoverNewCategoryButton: View {

    var body: some View {
  
        VStack {
            
            Text("Discover your\nnext realm")
                .multilineTextAlignment(.center)
                .foregroundStyle(AppColors.textBlack)
                .font(.system(size: 21))
                .fontWidth(.condensed)
                .lineSpacing(1.3)
                .padding(.horizontal)
            
            
            Spacer()
            
            RoundButton(buttonImage: "arrow.right",
                        buttonAction: {
            })
            .disabled(true)
        }
        .padding(.vertical, 30)
        .frame(width: 215, height: 220)
        .contentShape(RoundedRectangle(cornerRadius: 25))
        .background {
            RoundedRectangle(cornerRadius: 15)
                .stroke(AppColors.strokePrimary.opacity(0.50), lineWidth: 0.5)
                .fill(
                    LinearGradient(
                        gradient: Gradient(colors: [AppColors.boxYellow1, AppColors.boxYellow2]),
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .shadow(color: Color.black.opacity(0.30), radius: 15, x: 0, y: 3)
        }
            
    }
}

struct CategoryMissionView: View {
    
    let checker = NewCategoryEligibilityChecker()
    let category: Realm
    let topicsCompleted: Int
    let showUndiscovered: Bool
    let unlockedCategories: Int
    var numberRequiredTopics: Int {
        return checker.requiredTopics(totalCompletedTopics: topicsCompleted, showUndiscovered: showUndiscovered)
    }
    
    var body: some View {
        VStack (spacing: 25) {
            
            Text(category.orderIndex == 6 ? "To discover this realm" : "To discover a new realm")
                .font(.system(size: 15, weight: .thin).smallCaps())
                .foregroundStyle(AppColors.textPrimary)
                .fontWidth(.condensed)
            
            
            switch category.orderIndex {
            case 6:
                checklistBox(
                    missionText: "Unlock all other realms",
                    numberRequired: 6,
                    numberCompleted: unlockedCategories,
                    completed: unlockedCategories == 6)
            default:
                checklistBox(
                    missionText: "Complete \(numberRequiredTopics) quests",
                    numberRequired: numberRequiredTopics,
                    numberCompleted: topicsCompleted,
                    completed: (numberRequiredTopics <= topicsCompleted) && showUndiscovered)
            }
         
                
            
        }
        .padding(.horizontal)
    }
    
    private func checklistBox(missionText: String, numberRequired: Int, numberCompleted: Int, completed: Bool) -> some View {
        HStack (spacing: 5) {
            
            Image(systemName: completed ? "checkmark.square.fill" : "square")
                .font(.system(size: 20, weight: .light))
                .foregroundStyle(AppColors.textPrimary)
            
            Text(missionText)
                .fixedSize(horizontal: false, vertical: true)
                .font(.system(size: 16, weight: .light))
                .foregroundStyle(AppColors.textPrimary)
                .strikethrough(completed, color: AppColors.textPrimary)
                
            
            Spacer()
            
            if !completed {
                Text("\(numberRequired - numberCompleted) left")
                    .font(.system(size: 16, weight: .light))
                    .fontWidth(.condensed)
                    .foregroundStyle(AppColors.textPrimary.opacity(0.5))
            }
            
        }
        .padding()
        .background {
            RoundedRectangle(cornerRadius: 15)
                .stroke(AppColors.textSecondary.opacity(0.1), lineWidth: 0.5)
                .fill(completed ? Color.clear : AppColors.textSecondary.opacity(0.05))
                
        }
    }
    
}

//#Preview {
//    CategoryDescriptionView()
//}
