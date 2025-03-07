//
//  NewCategoryIntroView.swift
//  Fearless2
//
//  Created by Yue Deng-Wu on 3/5/25.
//
import CloudStorage
import SwiftUI

struct NewCategoryIntroView: View {
    
    @State private var animatedText = ""
    @State private var animator: TextAnimator?
    
    @Binding var selectedIntroPage: Int
    @Binding var showQuestionsView: Bool
    @Binding var animationStage: Int
    
    let categories: FetchedResults<Category>
    
    var content: NewCategoryContent {
        return NewCategoryContent.pages[selectedIntroPage]
    }
    
    @CloudStorage("currentAppView") var currentAppView: Int = 0
    @AppStorage("currentCategory") var currentCategory: Int = 0
    @CloudStorage("unlockNewCategory") var newCategory: Bool = false
    @AppStorage("showTopics") var showTopics: Bool = false
    
    var body: some View {
        VStack (spacing: 10) {
            
            Image(content.imageName)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 90)
                .padding(.top, 140)
                .padding(.bottom, 50)
            
            if selectedIntroPage == 0 {
                Text(content.title)
                    .font(.system(size: 20, design: .serif).smallCaps())
                    .foregroundStyle(AppColors.textPrimary.opacity(0.7))
                    .padding(.bottom, 10)
            }
            
            Text(animatedText)
                .multilineTextAlignment(.center)
                .font(.system(size: 25, design: .serif))
                .foregroundStyle(AppColors.textPrimary)
                .lineSpacing(1.4)
                .padding(.horizontal, 30)
                .onAppear {
                    typewriterAnimation()
                }
            
            Spacer()
            
            switch selectedIntroPage {
            case 0:
                RoundButton(buttonImage: "arrow.right",
                            size: 30,
                            frameSize: 100,
                            buttonAction: {
                                introViewButtonAction()
                            },
                            disableButton: (animatedText != content.description)
                )
            default:
                RectangleButtonPrimary(
                    buttonText: "Discover your next realm",
                    action: {
                        introViewButtonAction()
                    },
                    disableMainButton: (animatedText != content.description),
                    buttonColor: .white
                )
                .padding(.horizontal)
                
            }
        }//VStack
        .padding(.bottom, 55)
        .frame(maxWidth: .infinity)
        .opacity((animationStage == 0) ? 1 : 0)
        .onChange(of: selectedIntroPage) {
            if selectedIntroPage > 0 {
                typewriterAnimation()
            }
        }
        
    }
    
    
    private func typewriterAnimation() {
        if animator == nil {
            animator = TextAnimator(text: content.description, animatedText: $animatedText)
        } else {
            animator?.updateText(content.description)
        }
        animator?.animate()
    }
    
    private func introViewButtonAction() {
        switch selectedIntroPage {
        case 0:
            showQuestionsView = true
            
        default:
            transitionToNewRealm()
        }
    }
    
    private func transitionToNewRealm() {
        //hide text and button
        withAnimation(.snappy(duration: 0.25)) {
            animationStage += 1
        }
        
        //start expanding circle animation
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            animationStage += 1
            
            //switch to main app view
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                newCategory = false
                currentCategory = categories.count - 1
                showTopics = false
                
                currentAppView = 1
            }
            
        }
    }
}
