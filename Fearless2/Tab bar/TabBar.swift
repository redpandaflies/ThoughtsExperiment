//
//  TabBar.swift
//  Fearless2
//
//  Created by Yue Deng-Wu on 11/5/24.
//
import SwiftUI

struct TabBar: View {
    
    @Binding var selectedTab: TabBarItem
    
    let screenWidth = UIScreen.current.bounds.width
    var body: some View {
        VStack {
            Spacer()

            HStack (alignment: .lastTextBaseline, spacing: 40) {
                ForEach(TabBarItem.allCases, id: \.self) { tab in
                    TabBarButton(
                        tab: tab,
                        isSelected: selectedTab == tab,
                        action: {
                            selectedTab = tab
//                            DispatchQueue.global(qos: .background).async {
//                                Mixpanel.mainInstance().track(event: "Selected tab: \(tab)")
//                            }
                        }
                    )
                }
            }
            .frame(width: screenWidth)
            .padding(.bottom, 40)
            .background {
                Rectangle()
                    .fill(Color.black)
            }
            
        }.edgesIgnoringSafeArea(.all)
    }
}

struct TabBarButton: View {

    let tab: TabBarItem
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
                .frame(width: 60, height: 45)
        }.sensoryFeedback(.selection, trigger: isSelected) { oldValue, newValue in
            return oldValue != newValue && newValue == true
        }
    }
}

#Preview {
    TabBar(selectedTab: .constant(.topics))
}
