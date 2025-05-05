//
//  GoalsView.swift
//  Fearless2
//
//  Created by Yue Deng-Wu on 4/22/25.
//
import CoreData
import Mixpanel
import Pow
import SwiftUI

struct GoalsView: View {
    @EnvironmentObject var viewModelFactoryMain: ViewModelFactoryMain
    @EnvironmentObject var dataController: DataController
    @ObservedObject var topicViewModel: TopicViewModel
    
    @State private var showSettingsView: Bool = false
    @State private var goalScrollPosition: Int?
    @State private var showNewGoalSheet: Bool = false
    @State private var cancelledCreateNewCategory: Bool = false //prevents scroll if user exits create new category flow
    @State private var showLaurelInfoSheet: Bool = false
    @State private var animatedGoalIDs: Set<UUID> = []
    
    @Binding var selectedTopic: Topic?
    @Binding var currentTabBar: TabBarType
    @Binding var selectedTabTopic: TopicPickerItem
    
    @FetchRequest(
        sortDescriptors: [
            NSSortDescriptor(key: "orderIndex", ascending: true)
        ]
    ) var categories: FetchedResults<Category>
    
    @FetchRequest(
        sortDescriptors: [
            NSSortDescriptor(key: "createdAt", ascending: true)
        ],
        predicate: NSPredicate(format: "status == %@", GoalStatusItem.active.rawValue),
        animation: .default
    ) var goals: FetchedResults<Goal>
    
    @FetchRequest(
        sortDescriptors: []
    ) var points: FetchedResults<Points>
    
    var currentPoints: Int {
        return Int(points.first?.total ?? 0)
    }
    
    // avoid crashing app when goals is 0 or goalScrollPosition is out of bounds
    private var displayedGoal: Goal? {
        // if there are no goals, bail out
        guard !goals.isEmpty else { return nil }
        // if you have a valid scroll position, use it
        if let pos = goalScrollPosition, goals.indices.contains(pos) {
            return goals[pos]
        }
        // otherwise just show the first goal
        return goals.first
    }
    
    private var headerImageName: String {
        let index = goalScrollPosition ?? 0
        let imageIndex = (index % 3) + 1
        return "goal\(imageIndex)"
    }
    
    let screenWidth = UIScreen.current.bounds.width
    
    var frameWidth: CGFloat {
        return screenWidth * 0.85
    }
    
    var safeAreaPadding: CGFloat {
        return (screenWidth - frameWidth)/2
    }
    
    var body: some View {
        NavigationStack {
            
            VStack (spacing: 15){
                if !goals.isEmpty {
                    
                    Image(headerImageName)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(height: 160)
                        .blendMode(.screen)
                    
                    ScrollView (.horizontal) {
                        HStack (spacing: 15) {
                            ForEach(Array(goals.enumerated()), id: \.element.goalId) { index, goal in
                                // MARK: - Quests map
                                if animatedGoalIDs.contains(goal.goalId) {
                                
                                    QuestMapView(
                                        topicViewModel: topicViewModel,
                                        selectedTopic: $selectedTopic,
                                        currentTabBar: $currentTabBar,
                                        selectedTabTopic: $selectedTabTopic,
                                        animatedGoalIDs: $animatedGoalIDs,
                                        goal: goal,
                                        points: currentPoints,
                                        backgroundColor: getCategoryBackground(goal: goal),
                                        frameWidth: frameWidth
                                    )
                                    .id(index)
//                                        .scrollTransition { content, phase in
//                                            content
//                                                .opacity(phase.isIdentity ? 1 : 0.3)
//                                        }
                                    .transition( .movingParts.poof)
                                }
                                
                            }//ForEach
                        }//HStack
                        .scrollTargetLayout()
                        .onAppear {
                            if animatedGoalIDs.isEmpty {
                                animatedGoalIDs = Set(goals.map(\.goalId))
                            }
                        }
                    }//ScrollView
                    .scrollPosition(id: $goalScrollPosition, anchor: .center)
                    .scrollClipDisabled(true)
                    .scrollTargetBehavior(.viewAligned(limitBehavior: .alwaysByOne))
                    .scrollIndicators(.hidden)
                    .contentMargins(.horizontal, safeAreaPadding, for: .scrollContent)
                    
                    if goals.count > 1 {
                        PageIndicatorView(scrollPosition: $goalScrollPosition, pagesCount: goals.count)
                            .padding(.top)
                    }
                    
                }
                
            }//VStack
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            .ignoresSafeArea(.keyboard)
            .background {
                BackgroundPrimary(backgroundColor: getCategoryBackground(goal: displayedGoal))
            }
            .overlay {
                addGoalButton(buttonAction: {
                    showNewGoalSheet = true
                })
            }
            .onAppear {
                print("Number of goals: \(goals.count)")
            }
            .onChange(of: dataController.deletedAllData) {
                print("Number of goals: \(goals.count)")
                //                if dataController.deletedAllData {
                //                    selectedTopic = nil
                //                    goalScrollPosition = nil
                //                }
            }
//            .onChange(of:  goals.map(\.goalId)) { oldValue, newValue in
//                let newSet = Set(newValue)
//                let removed = animatedGoalIDs.subtracting(newSet)  // IDs to animate‐away
//                let added = newSet.subtracting(animatedGoalIDs)  // IDs to bring in
//
//                // Animate removals
//                withAnimation {
//                    animatedGoalIDs.subtract(removed)
//                }
//
//                // Immediately add any new ones
//                animatedGoalIDs.formUnion(added)
//                
//            }
            .onChange(of: showNewGoalSheet) {
                if !cancelledCreateNewCategory && goals.count > 1 {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        
                        goalScrollPosition = goals.count - 1
                   
                    }
                }
            }
            
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    SettingsToolbarItem(action: {
                        showSettingsView = true
                    })
                   
                }
                
                ToolbarItem(placement: .topBarTrailing) {
                       Button {
                           //tbd
                           showLaurelInfoSheet = true

                           DispatchQueue.global(qos: .background).async {
                               Mixpanel.mainInstance().track(event: "Tapped laurel counter")
                           }

                       } label: {
                           LaurelItem(size: 15, points: "\(Int(points.first?.total ?? 0))")
                       }
                   }
                
            }
            .sheet(isPresented: $showSettingsView, onDismiss: {
                showSettingsView = false
            }, content: {
                SettingsView(backgroundColor: AppColors.backgroundOnboardingIntro)
                    .presentationCornerRadius(20)
                    .presentationBackground {
                        Color.clear
                            .background(.regularMaterial)
                    }
            })
            .fullScreenCover(isPresented: $showNewGoalSheet, onDismiss: {
                showNewGoalSheet = false
            }) {
                NewCategoryView(
                    newCategoryViewModel: viewModelFactoryMain.makeNewCategoryViewModel(),
                    showNewGoalSheet: $showNewGoalSheet,
                    cancelledCreateNewCategory: $cancelledCreateNewCategory
                )
            }
            .sheet(isPresented: $showLaurelInfoSheet, onDismiss: {
                   showLaurelInfoSheet = false
               }) {

                   InfoPrimaryView(
                    backgroundColor: getCategoryBackground(goal: displayedGoal),
                       useIcon: false,
                       titleText: "You earn laurels by exploring paths and completing quests.",
                       descriptionText: "You’ll be able to use them to unlock new abilities.",
                       useRectangleButton: false,
                       buttonAction: {}
                   )
                   .presentationDetents([.fraction(0.65)])
                   .presentationCornerRadius(30)
               }
        }
        .tint(AppColors.textPrimary)
        
       
    }
    
    private func getCategoryBackground(goal: Goal?) -> Color {
        
        if let category = goal?.category {
            
            return Realm.getBackgroundColor(forName: category.categoryName)
            
        } else {
            return AppColors.backgroundOnboardingIntro
        }

    }
    
    private func addGoalButton(buttonAction: @escaping () -> Void) -> some View {
        VStack {
            SquareButton(
                buttonImage: "plus",
                buttonAction: {
                    buttonAction()
                }
            )
            .padding(.horizontal, safeAreaPadding)
            .padding(.bottom, 20)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomTrailing)
    }
}
