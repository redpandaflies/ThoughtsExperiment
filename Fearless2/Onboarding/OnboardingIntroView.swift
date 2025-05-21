//
//  OnboardingIntroView.swift
//  Fearless2
//
//  Created by Yue Deng-Wu on 2/25/25.
//
import Mixpanel
import Pow
import SwiftUI

struct OnboardingIntroView: View {
    @State private var animatedText = ""
    @State private var animator: TextAnimator?
    @State private var animationCompletedText: Bool = false

    @Binding var selectedIntroPage: Int
    @Binding var showNewGoalSheet: Bool
    @Binding var animationStage: Int
    
    var content: OnboardingIntroContent {
        return OnboardingIntroContent.pages[selectedIntroPage]
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10)  {
            
            SpinnerDefault()
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.top, 100)
                .padding(.horizontal, 30)
            
            Text(animatedText)
                .multilineTextAlignment(.leading)
                .font(.system(size: 25, design: .serif))
                .foregroundStyle(AppColors.textPrimary)
                .lineSpacing(1.4)
                .padding(.horizontal, 30)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.top, 40)
                .padding(.bottom, 20)
               
            
            if selectedIntroPage == 1 && animationCompletedText {
                SampleGoalsView(
                    onTapAction: { _ in
                    showNewGoalSheet = true
                })
                .padding(.horizontal, 30)
            }
          
            Spacer()
    
            RectangleButtonPrimary(
                buttonText: getButtonText(),
                action: {
                    introViewButtonAction()
                },
                showPlus: selectedIntroPage == 1 ? true : false,
                disableMainButton: disabledButton(),
                buttonColor: .white
            )
            .frame(maxWidth: .infinity, alignment: .center)
            
            
        }
        .padding(.bottom, 40)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .opacity((animationStage == 0) ? 1 : 0)
        .onAppear {
            typewriterAnimation()
        }
        .onChange(of: selectedIntroPage) {
            typewriterAnimation()
        }

    }
    
    private func getButtonText() -> String {
        switch selectedIntroPage {
        case 0:
            return "Continue"
        default:
            return "Add topic"
        }
    }
    
    private func introViewButtonAction() {
        
        switch selectedIntroPage {
            case 0:
            selectedIntroPage += 1
            default:
             showNewGoalSheet = true
            DispatchQueue.global(qos: .background).async {
                Mixpanel.mainInstance().track(event: "Started a new topic")
            }
        }
        
    }
    
    private func disabledButton() -> Bool {
        switch selectedIntroPage {
        case 0:
            return !animationCompletedText
        default:
            return false
        }
    }
    
    private func typewriterAnimation() {
        if animator == nil {
            animator = TextAnimator(
                text: content.title,
                animatedText: $animatedText,
                completedAnimation: $animationCompletedText,
                speed: 0.03
            )
        } else {
            animator?.updateText(content.title)
        }
        animator?.animate()
    }
    
}



struct SampleGoalBox: View {
    
    let heading: String
    let title: String
    let symbol: String
    let boxFrameWidth: CGFloat
    let showSymbol: Bool
  
    
    init(heading: String, title: String, symbol: String, boxFrameWidth: CGFloat, showSymbol: Bool = false) {
        self.heading = heading
        self.title = title
        self.symbol = symbol
        self.boxFrameWidth = boxFrameWidth
        self.showSymbol = showSymbol
        
    }
    
    var body: some View {
        VStack (alignment: .leading, spacing: 10) {
            if showSymbol {
                Image(systemName: symbol)
                    .multilineTextAlignment(.leading)
                    .font(.system(size: 12).smallCaps())
                    .fontWidth(.condensed)
                    .foregroundStyle(AppColors.textPrimary.opacity(0.5))
            } else {
                Text(heading)
                    .multilineTextAlignment(.leading)
                    .font(.system(size: 12, weight: .light).smallCaps())
                    .fontWidth(.condensed)
                    .foregroundStyle(AppColors.textPrimary.opacity(0.5))
                    .fixedSize(horizontal: false, vertical: true)
            }
            
            Text(title)
                .multilineTextAlignment(.leading)
                .font(.system(size: 13, weight: .light))
                .foregroundStyle(AppColors.textPrimary.opacity(0.7))
                .lineSpacing(1.15)
                .fixedSize(horizontal: false, vertical: true)
            
        }
        .padding(.horizontal, 15)
        .padding(.vertical, 14)
        .frame(width: boxFrameWidth, height: 120, alignment: .topLeading)
        .background {
            RoundedRectangle(cornerRadius: 15)
                .stroke(AppColors.textPrimary.opacity(0.3), lineWidth: 0.5)
                .fill(.clear)
        }
    }
}
