//
//  FocusAreaBox.swift
//  Fearless2
//
//  Created by Yue Deng-Wu on 11/8/24.
//
import Pow
import SwiftUI


struct FocusAreaBox: View {
    @ObservedObject var topicViewModel: TopicViewModel
    @State private var selectedTab: Int = 0
    
    @Binding var showFocusAreaRecapView: Bool
    @Binding var selectedSection: Section?
    @Binding var selectedSectionSummary: SectionSummary?
    @Binding var selectedFocusArea: FocusArea?
    @Binding var selectedFocusAreaSummary: FocusAreaSummary?
    let focusArea: FocusArea
    let index: Int
    
    var body: some View {
       
        VStack (spacing: 10){
            Group {
                
                Text("\(index + 1)")
                    .multilineTextAlignment(.center)
                    .font(.system(size: 40, weight: .semibold))
                    .foregroundStyle(AppColors.whiteDefault)
                
                Text(focusArea.focusAreaTitle)
                    .multilineTextAlignment(.center)
                    .font(.system(size: 25))
                    .fontWeight(.regular)
                    .foregroundStyle(AppColors.whiteDefault)
                    .fixedSize(horizontal: false, vertical: true)
                
                
                Text(focusArea.focusAreaReasoning)
                    .multilineTextAlignment(.center)
                    .font(.system(size: 16))
                    .fontWeight(.regular)
                    .foregroundStyle(AppColors.whiteDefault)
                    .fixedSize(horizontal: false, vertical: true)
                    .opacity(0.7)
                    .padding(.bottom, 10)
            }
            .padding(.horizontal, 30)
            
            ScrollView(.horizontal, showsIndicators: false) {
                switch selectedTab {
                    case 0:
                        FocusAreaLoadingPlaceholder()
                    default:
                        SectionListView(showFocusAreaRecapView: $showFocusAreaRecapView, selectedSection: $selectedSection, selectedSectionSummary: $selectedSectionSummary, selectedFocusArea: $selectedFocusArea, selectedFocusAreaSummary: $selectedFocusAreaSummary, sections: focusArea.focusAreaSections, focusAreaCompleted: focusArea.completed)
                    
                }

            }
            .padding(.horizontal, 30)
            .scrollClipDisabled(true)
            
            Spacer()
            
        }//VStack
        .onAppear {
            if !focusArea.focusAreaSections.isEmpty {
                selectedTab = 1
            }
        }
        .onChange(of: topicViewModel.focusAreaUpdated) {
            if topicViewModel.focusAreaUpdated {
                selectedTab += 1
            }
        }
        
    }
}

struct FocusAreaLoadingPlaceholder: View {
    @State private var enableAnimation: Bool = false
    @State private var animationEffect: Int = 0
    let timer = Timer.publish(every: 3, on: .main, in: .common).autoconnect()
    
    
    var body: some View {
        HStack (spacing: 12) {
            ForEach(0..<4) { _ in
                
                loadingBox()
                
            }
        }
    }
    
    private func loadingBox() -> some View {
        VStack {
            
            Text("Generating")
                .font(.system(size: 11))
                .foregroundStyle(AppColors.whiteDefault)
                .opacity(0.6)
                .textCase(.uppercase)
            
        }
        .frame(width: 150, height: 180)
        .background {
            RoundedRectangle(cornerRadius: 20)
                .stroke(AppColors.whiteDefault.opacity(0.2), lineWidth: 1)
                .fill(Color.black)
        }
        .animation(.default, value: animationEffect)
        .changeEffect (
            .shine.delay(0.2),
            value: animationEffect,
            isEnabled: enableAnimation
        )
        .onAppear {
            
            withAnimation(.easeIn(duration: 0.5)) {
                enableAnimation = true
                animationEffect += 1
            }
            
        }
        .onDisappear {
            
            timer.upstream.connect().cancel()
                            
        }
        .onReceive(timer) { time in

            animationEffect += 1
        }
    }
}

//#Preview {
//    FocusAreaBox()
//}
