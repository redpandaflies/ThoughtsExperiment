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
   
    //manage sample topics animation
    @State private var currentChunk = 0
    @State private var showIndexInChunk = -1
    @State private var isAnimatingSampleTopics = false
    
    @Binding var selectedIntroPage: Int
    @Binding var showNewGoalSheet: Bool
    @Binding var animationStage: Int
    var content: OnboardingIntroContent {
        return OnboardingIntroContent.pages[selectedIntroPage]
    }
    
    let sampleTopics: [OnboardingSampleTopicsItem] = OnboardingSampleTopicsItem.sample
    
    let screenWidth = UIScreen.current.bounds.width
    
    let hStackSpacing: CGFloat = 12
    
    var boxFrameWidth: CGFloat {
        return (screenWidth - (2 * hStackSpacing) - 60) / 3
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
               
            
            if selectedIntroPage == 1 && animatedText == content.title {
                HStack (spacing: hStackSpacing) {
                    ForEach(Array(sampleTopics.enumerated()), id: \.element.id) { index, topic in
                        let chunk = index / 3
                        let positionInChunk = index % 3
                        if chunk == currentChunk && positionInChunk <= showIndexInChunk {
                            SampleTopicBox(
                                heading: topic.heading,
                                title: topic.title,
                                boxFrameWidth: boxFrameWidth
                            )
                            .transition(.movingParts.blur)
                            .onTapGesture {
                                showNewGoalSheet = true
                            }
                        }
                        
                    }
                }
                .padding(.horizontal, 30)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.top)
                .onAppear {
                    isAnimatingSampleTopics = true
                    animateChunk(0)
                }
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
        .onDisappear {
            isAnimatingSampleTopics = false
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
    
    private func animateChunk(_ chunk: Int) {
        guard isAnimatingSampleTopics else { return }

        currentChunk = chunk
        showIndexInChunk = -1

        // 1) reveal each of the 3 with a stagger
        for i in 0..<3 {
            let revealDelay = Double(i) * 0.1
            DispatchQueue.main.asyncAfter(deadline: .now() + revealDelay) {
                guard isAnimatingSampleTopics else { return }
                withAnimation(.snappy(duration: 0.2)) {
                    self.showIndexInChunk = i
                }
            }
        }

        // 2) after all three are revealed, hide them then schedule next chunk
          let totalRevealTime = Double(2) * 0.3 + 0.2    // last reveal starts at 0.6, takes 0.2
        let postRevealHold: Double = 5.0
          let hideAnimationDelay: Double = 0.75

          DispatchQueue.main.asyncAfter(deadline: .now() + totalRevealTime + postRevealHold) {
              guard isAnimatingSampleTopics else { return }
              withAnimation(.easeInOut) {
                  showIndexInChunk = -1
              }

              // 3) pick next chunk with wrap-around
              let next = (chunk + 1) % 3

              // 4) give the hide animation a moment, then recurse
              DispatchQueue.main.asyncAfter(deadline: .now() + hideAnimationDelay) {
                  animateChunk(next)
              }
          }
    }
}



struct SampleTopicBox: View {
    
    let heading: String
    let title: String
    let boxFrameWidth: CGFloat
    
    var body: some View {
        VStack (alignment: .leading, spacing: 10) {
            Text(heading)
                .multilineTextAlignment(.leading)
                .font(.system(size: 12, weight: .light).smallCaps())
                .fontWidth(.condensed)
                .foregroundStyle(AppColors.textPrimary.opacity(0.5))
                .fixedSize(horizontal: false, vertical: true)
            
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
