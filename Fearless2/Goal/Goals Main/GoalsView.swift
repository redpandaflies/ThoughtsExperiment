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
    
    @State private var selectedSegment: GoalsPicker = .active
    @State private var showSettingsView: Bool = false
    @State private var goalScrollPositionActive: Int?
    @State private var goalScrollPositionCompleted: Int?
    @State private var showNewGoalSheet: Bool = false
    @State private var showLaurelInfoSheet: Bool = false
    
    @Binding var selectedTopic: Topic?
    @Binding var currentTabBar: TabBarType
    @Binding var selectedTabTopic: TopicPickerItem
    
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
            
            VStack {
                
                selectedSegment.pickerView(
                    topicViewModel: topicViewModel,
                    goalScrollPositionActive: $goalScrollPositionActive,
                    goalScrollPositionCompleted: $goalScrollPositionCompleted,
                    selectedSegment: $selectedSegment,
                    selectedTopic: $selectedTopic,
                    currentTabBar: $currentTabBar,
                    selectedTabTopic: $selectedTabTopic,
                    showNewGoalSheet: $showNewGoalSheet
                )
          
                
            }//VStack
            .overlay {
                addGoalButton(buttonAction: {
                    showNewGoalSheet = true
                    DispatchQueue.global(qos: .background).async {
                        Mixpanel.mainInstance().track(event: "Started a new topic")
                    }
                })
            }
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    SettingsToolbarItem(action: {
                        showSettingsView = true
                    })
                   
                }
                
                ToolbarItem(placement: .principal) {
                    GoalsPickerView(selectedSegment: $selectedSegment)
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
                SettingsView(backgroundColor: getBackground(index: selectedSegment == .active ? goalScrollPositionActive : goalScrollPositionCompleted))
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
                    newGoalViewModel: viewModelFactoryMain.makeNewGoalViewModel(),
                    showNewGoalSheet: $showNewGoalSheet,
                    backgroundColor: getBackground(index: selectedSegment == .active ? goalScrollPositionActive : goalScrollPositionCompleted),
                    isOnboarding: false
                )
            }
            .sheet(isPresented: $showLaurelInfoSheet, onDismiss: {
                   showLaurelInfoSheet = false
               }) {
               InfoPrimaryView (
                backgroundColor: getBackground(index: selectedSegment == .active ? goalScrollPositionActive : goalScrollPositionCompleted),
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
    
}
