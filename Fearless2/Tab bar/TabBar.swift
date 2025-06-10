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
    @Binding var selectedTabHome: TabBarItemHome

    let screenWidth = UIScreen.current.bounds.width
    
    var body: some View {
        
        VStack {
             
                
            ZStack {
                    
                Rectangle()
                    .stroke(.white.opacity(0.1), lineWidth: 0.5)
                    .fill(AppColors.backgroundPrimary.opacity(0.5))
                    .shadow(color: .black.opacity(0.2), radius: 2.5, x: 0, y: -2)
                    .blendMode(.colorDodge)
          
                

                HomeTabBar(selectedTabHome: $selectedTabHome)
                    .padding(.bottom, 30)
                    
                
            }
            .frame(maxWidth: .infinity, maxHeight: 90)
           
           
        }
        .frame(maxHeight: .infinity, alignment: .bottom)
        .edgesIgnoringSafeArea(.bottom)
        
    }
}

struct HomeGradient: View {
    
    private let screenWidth = UIScreen.current.bounds.width
    
    var body: some View {
      
        Group {
            Rectangle()
                .fill(Color.clear)
            
        }//App was crashing when Group was removed
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
                        .font(.system(size: 20, weight: .medium, design: .rounded))
                        .foregroundStyle(AppColors.whiteDefault)
                        .fontWeight(.regular)
                        .padding(.bottom, 2)
                        
                    Text(tab.iconLabel())
                        .multilineTextAlignment(.center)
                        .font(.system(size: 10))
                        .foregroundStyle(AppColors.whiteDefault)
                        .fontWeight(.regular)
                       
                }
                .opacity(isSelected ? 0.8 : 0.5)
                .frame(width: 80, height: 40)
            
        }.sensoryFeedback(.selection, trigger: isSelected) { oldValue, newValue in
            return oldValue != newValue && newValue == true
        }
    }
}


