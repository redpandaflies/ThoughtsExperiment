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
    
    @State private var selectedTabGoals: Int = 0
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
            NSSortDescriptor(key: "createdAt", ascending: true)
        ],
        predicate: NSPredicate(format: "status == %@", GoalStatusItem.active.rawValue)
    ) var goals: FetchedResults<Goal>
    
    @FetchRequest(
        sortDescriptors: []
    ) var points: FetchedResults<Points>
    
    var currentPoints: Int {
        return Int(points.first?.total ?? 1)
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
                
                switch selectedTabGoals {
                case 0:
                    GoalsListView(
                        topicViewModel: topicViewModel,
                        goalScrollPosition: $goalScrollPosition,
                        selectedTopic: $selectedTopic,
                        currentTabBar: $currentTabBar,
                        selectedTabTopic: $selectedTabTopic,
                        animatedGoalIDs: $animatedGoalIDs,
                        goals: goals,
                        currentPoints: currentPoints,
                        frameWidth: frameWidth,
                        safeAreaPadding: safeAreaPadding
                    )
                
                    
                default:
                    GoalsEmptyState()
                }
          
                
            }//VStack
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            .ignoresSafeArea(.keyboard)
            .background {
                BackgroundPrimary(backgroundColor: getBackground(index: goalScrollPosition))
            
            }
            .overlay {
                addGoalButton(buttonAction: {
                    showNewGoalSheet = true
                    DispatchQueue.global(qos: .background).async {
                        Mixpanel.mainInstance().track(event: "Started a new topic")
                    }
                })
            }
            .onAppear {
               
                print("Number of goals: \(goals.count)")
                
                if animatedGoalIDs.isEmpty {
                    animatedGoalIDs = Set(goals.map(\.goalId))
                }
                
                if goals.count == 0 {
                    selectedTabGoals = 1
                }

            }
            .onChange(of: dataController.deletedAllData) {
                print("Number of goals: \(goals.count)")
                //                if dataController.deletedAllData {
                //                    selectedTopic = nil
                //                    goalScrollPosition = nil
                //                }
            }
            .onChange(of:  goals.map(\.goalId)) { oldValue, newValue in
                
                if oldValue.count < newValue.count {
                    updateGoalsList(newValue: newValue)
                }
                
            }
            .onChange(of: animatedGoalIDs) { oldValue, newValue in
                
//                print("Old value: \(oldValue), new value: \(newValue)")
                // update scroll view only if a goal has been abandoned or completed
                if oldValue.count > newValue.count {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        if let scrollPosition = goalScrollPosition {
                            withAnimation {
                                goalScrollPosition = scrollPosition == 0 ? nil : max(scrollPosition - 1, 0)
                            }
                        }
                    }
                }
                
                if animatedGoalIDs.isEmpty {
                    selectedTabGoals = 1
                }
            }
            .onChange(of: showNewGoalSheet) {
                if !showNewGoalSheet && !cancelledCreateNewCategory && goals.count > 1 {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                        withAnimation {
                            goalScrollPosition = goals.count - 1
                        }
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
                           // show sheet explaining points
                           showLaurelInfoSheet = true
                           
                           DispatchQueue.global(qos: .background).async {
                               Mixpanel.mainInstance().track(event: "Tapped laurel counter")
                           }

                       } label: {
                           LaurelItem(size: 15, points: "\(currentPoints)")
                       }
                   }
                
            }
            .sheet(isPresented: $showSettingsView, onDismiss: {
                showSettingsView = false
            }, content: {
                SettingsView(backgroundColor: getBackground(index: goalScrollPosition))
                    .presentationCornerRadius(20)
                    .presentationBackground {
                        Color.clear
                            .background(.regularMaterial)
                    }
            })
            .fullScreenCover(isPresented: $showNewGoalSheet, onDismiss: {
                showNewGoalSheet = false
            }) {
                NewGoalView(
                    newCategoryViewModel: viewModelFactoryMain.makeNewCategoryViewModel(),
                    showNewGoalSheet: $showNewGoalSheet,
                    cancelledCreateNewCategory: $cancelledCreateNewCategory,
                    backgroundColor: getBackground(index: goalScrollPosition)
                )
            }
            .sheet(isPresented: $showLaurelInfoSheet, onDismiss: {
                   showLaurelInfoSheet = false
               }) {

                   InfoPrimaryView(
                    backgroundColor: getBackground(index: goalScrollPosition),
                       useIcon: false,
                       titleText: "You earn laurels by answering questions and resolving topics.",
                       descriptionText: "You'll soon be able to use them to unlock new abilities.",
                       useRectangleButton: false,
                       buttonAction: {}
                   )
                   .presentationDetents([.fraction(0.65)])
                   .presentationCornerRadius(30)
               }
        }
       
    }
    
    private func getBackground(index: Int?) -> Color {
        if let index = index {
            let count = AppColors.allBackgrounds.count
            
            let usableIndex = ((index % count) + count) % count
            
            return AppColors.allBackgrounds[usableIndex]
            
        }
        
        return AppColors.allBackgrounds[0]
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
    
    private func updateGoalsList(newValue: [UUID]) {
        let newSet = Set(newValue)
        let added = newSet.subtracting(animatedGoalIDs)  // IDs to bring in

        // Animate removals
//        withAnimation {
//            animatedGoalIDs.subtract(removed)
//        }
      
        // Immediately add any new ones
        animatedGoalIDs.formUnion(added)
        if selectedTabGoals != 0 {
            selectedTabGoals = 0
        }
    }
}
