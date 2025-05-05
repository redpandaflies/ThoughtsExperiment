////
////  OnboardingIntroView.swift
////  Fearless2
////
////  Created by Yue Deng-Wu on 2/25/25.
////
//import Mixpanel
//import SwiftUI
//
//struct OnboardingIntroView: View {
//    @State private var animatedText = ""
//    @State private var animator: TextAnimator?
//    
//    @Binding var selectedIntroPage: Int
//    @Binding var imagesScrollPosition: Int?
//    @Binding var showQuestionsView: Bool
//    @Binding var animationStage: Int
//    var content: OnboardingIntroContent {
//        return OnboardingIntroContent.pages[selectedIntroPage]
//    }
//    @AppStorage("currentAppView") var currentAppView: Int = 0
//    @AppStorage("currentCategory") var currentCategory: Int = 0
//    
//    var body: some View {
//        VStack (spacing: 10) {
//               
//            OnboardingScrollView(imagesScrollPosition: $imagesScrollPosition)
//                .padding(.top, 140)
//            
//            Text(animatedText)
//                .multilineTextAlignment(.center)
//                .font(.system(size: 25, design: .serif))
//                .foregroundStyle(AppColors.textPrimary)
//                .lineSpacing(1.4)
//                .padding(.top, 70)
//                .padding(.horizontal, 30)
//                .onAppear {
//                    typewriterAnimation()
//                }
//            
//            Spacer()
//            
//            RoundButton(buttonImage: "arrow.right",
//                        size: 30,
//                        frameSize: 100,
//                        buttonAction: {
//                            introViewButtonAction()
//                        },
//                        disableButton: (animatedText != content.title)
//            )
//            
//            getFooter()
//                .opacity((selectedIntroPage == 9) ? 1 : 0)
//            
//            
//        }
//        .padding(.bottom, 55)
//        .opacity((animationStage == 0) ? 1 : 0)
//        .onChange(of: imagesScrollPosition) {
//            if let scrollPosition = imagesScrollPosition, scrollPosition > 0 {
//                typewriterAnimation()
//            }
//        }
//
//    }
//    
//    private func introViewButtonAction() {
//        
//        switch selectedIntroPage {
//            case 9:
//                showQuestionsView = true
//            case 10:
//                completeOnboarding()
//            default:
//                break
//        }
//        
//        if selectedIntroPage < 9 {
//            withAnimation {
//                selectedIntroPage += 1
//                imagesScrollPosition = (imagesScrollPosition ?? 0) + 1
//            }
//        }
//
//    }
//    
//    private func completeOnboarding() {
//        
//        //hide text and button
//        withAnimation(.snappy(duration: 0.25)) {
//            animationStage += 1
//        }
//        
//        //start expanding circle animation
//        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
//            animationStage += 1
//            
//            //switch to main app view
//            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
//                currentCategory = 0
//                currentAppView = 1
//            }
//            
//        }
//        
//    }
//    
//    private func getFooter() -> some View {
//        Text("Everything is private. Our team can’t see your content.")
//            .multilineTextAlignment(.center)
//            .font(.system(size: 15, weight: .thin))
//            .fontWidth(.condensed)
//            .foregroundStyle(AppColors.textPrimary.opacity(0.5))
//            .padding(.top, 10)
//    }
//    
//    private func typewriterAnimation() {
//        if animator == nil {
//            animator = TextAnimator(text: content.title, animatedText: $animatedText, speed: 0.03)
//        } else {
//            animator?.updateText(content.title)
//        }
//        animator?.animate()
//    }
//}
//
//
//
//struct OnboardingScrollView: View {
//    
//    @Binding var imagesScrollPosition: Int?
//    
//    let imageNames = OnboardingIntroContent.pages.map { $0.imageName }
//    
//    var imagesToDisplay: Int {
//        return imageNames.count
//    }
//    
//    let frameSize: CGFloat = 90
//    var safeAreaPadding: CGFloat {
//        return (UIScreen.main.bounds.width - frameSize)/2
//    }
//    
//    var body: some View {
//        
//        ScrollView(.horizontal, showsIndicators: false) {
//            HStack (alignment: .center, spacing: 30) {
//                
//                ForEach(0..<imagesToDisplay, id: \.self) { index in
//                    
//                    let name = imageNames[index]
//                    Image(name)
//                        .resizable()
//                        .aspectRatio(contentMode: .fit)
//                        .blur(radius: getBlur(for: index))
//                        .opacity(getOpacity(for: index))
//                        .frame(width: getFrameSize(for: index))
////                        .scaleEffect(getScaleFactor(for: index))
//                        .id(index)
//                    
//                }
//            }
//            .scrollTargetLayout()
//        }
//        .scrollPosition(id: $imagesScrollPosition, anchor: .center)
//        .contentMargins(.horizontal, safeAreaPadding, for: .scrollContent)
//        .scrollClipDisabled(true)
//        .scrollTargetBehavior(.viewAligned)
//        .scrollDisabled(true)
//       
//       
//    }
//    
//    private func getOpacity(for index: Int) -> CGFloat {
//        guard let currentPosition = imagesScrollPosition else {
//            return 0.9 // Default scale when no position is selected
//        }
//        
//        // Calculate the distance from the selected item
//        let distance = abs(index - currentPosition)
//        
//        // The selected item (distance = 0) gets scale 1.0
//        // Each step away reduces scale progressively
//        let maxOpacity: CGFloat = 0.9
//        let minOpacity: CGFloat = 0.0
//        let opacityDrop: CGFloat = 0.3
//        
//        var calculatedOpacity: CGFloat = 1
//        
//        if index != currentPosition {
//            calculatedOpacity = maxOpacity - CGFloat(distance) * opacityDrop
//        }
//        
//        // Ensure the scale doesn't go below minimum
//        return max(calculatedOpacity, minOpacity)
//    }
//    
//    private func getFrameSize(for index: Int) -> CGFloat {
//        guard let currentPosition = imagesScrollPosition else {
//            return 90 // Default scale when no position is selected
//        }
//        
//        // Calculate the distance from the selected item
//        let distance = abs(index - currentPosition)
//        
//        // The selected item (distance = 0) gets scale 1.0
//        // Each step away reduces scale progressively
//        let maxFrame: CGFloat = 70
//        let minFrame: CGFloat = 15
//        let frameDrop: CGFloat = 20
//        
//        var calculatedFrame: CGFloat = 90
//        
//        if index != currentPosition {
//            calculatedFrame = maxFrame - CGFloat(distance) * frameDrop
//        }
//        
//        // Ensure the scale doesn't go below minimum
//        return max(calculatedFrame, minFrame)
//    }
//    
//    private func getBlur(for index: Int) -> CGFloat {
//        guard let currentPosition = imagesScrollPosition else {
//            return 0 // Default blur when no position is selected
//        }
//        
//        // Calculate the distance from the selected item
//        let distance = abs(index - currentPosition)
//        
//        // The selected item (distance = 0) gets minimum blur
//        // Each step away increases blur progressively
//        let minBlur: CGFloat = 0
//        let maxBlur: CGFloat = 10
//        let blurIncrease: CGFloat = 5
//        
//        var calculatedBlur: CGFloat = minBlur
//        
//        if index != currentPosition {
//            calculatedBlur = minBlur + CGFloat(distance) * blurIncrease
//        }
//        
//        // Ensure the blur doesn't exceed maximum
//        return min(calculatedBlur, maxBlur)
//    }
//}
