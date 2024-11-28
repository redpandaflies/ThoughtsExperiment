//
//  TabBar.swift
//  Fearless2
//
//  Created by Yue Deng-Wu on 11/5/24.
//
import SwiftUI

enum TabBarType {
    case home
    case topic
}

struct TabBar: View {
    @ObservedObject var transcriptionViewModel: TranscriptionViewModel
    @Binding var currentTabBar: TabBarType
    @Binding var selectedTabHome: TabBarItemHome
    @Binding var selectedTabTopic: TopicPickerItem
    @Binding var navigateToTopicDetailView: Bool
    
    let topicId: UUID?
    let screenWidth = UIScreen.current.bounds.width
    var body: some View {
        VStack {
            Spacer()
            
            ZStack {
                Rectangle()
                    .fill(Color.black)
                
                Group {
                    switch currentTabBar {
                    case .home:
                        HomeTabBar(selectedTabHome: $selectedTabHome)
                            .transition(.opacity.combined(with: .scale(0.8)))
                    case .topic:
                        TopicDetailViewFooter(transcriptionViewModel: transcriptionViewModel, selectedTabTopic: $selectedTabTopic, currentTabBar: $currentTabBar, navigateToTopicDetailView: $navigateToTopicDetailView, topicId: topicId)
                            .transition(.opacity.combined(with: .scale(0.8)))
                    }
                    
                }
                .padding(.bottom, 30)
            }
            
            .frame(width: screenWidth, height: 90)
            
        }.edgesIgnoringSafeArea(.all)
    }
}


struct HomeTabBar: View {
    @Binding var selectedTabHome: TabBarItemHome
    let screenWidth = UIScreen.current.bounds.width
    
    var body: some View {
        HStack (alignment: .lastTextBaseline, spacing: 40) {
            ForEach(TabBarItemHome.allCases, id: \.self) { tab in
                TabBarButton(
                    tab: tab,
                    isSelected: selectedTabHome == tab,
                    action: {
                        selectedTabHome = tab
//                            DispatchQueue.global(qos: .background).async {
//                                Mixpanel.mainInstance().track(event: "Selected tab: \(tab)")
//                            }
                    }
                )
            }
        }
        
    }
}

struct TabBarButton: View {

    let tab: TabBarItemHome
    let isSelected: Bool
    
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            
                VStack (alignment: .center, spacing: 3){
                    Spacer()
                    
                    
                    Image(systemName: tab.selectedIconName())
                        .font(.system(size: 15))
                        .foregroundStyle(Color.white)
                        .fontWeight(.regular)
                        .padding(.bottom, 2)
                        
                    Text(tab.iconLabel())
                        .multilineTextAlignment(.center)
                        .font(.system(size: 10))
                        .foregroundStyle(Color.white)
                        .fontWeight(.regular)
                       
                }
                .opacity(isSelected ? 0.8 : 0.5)
                .frame(width: 60, height: 40)
            
        }.sensoryFeedback(.selection, trigger: isSelected) { oldValue, newValue in
            return oldValue != newValue && newValue == true
        }
    }
}


