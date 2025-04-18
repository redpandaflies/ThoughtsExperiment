//
//  NewCategoryIntroView.swift
//  Fearless2
//
//  Created by Yue Deng-Wu on 3/5/25.
//
import Mixpanel
import SwiftUI

struct NewCategoryIntroView: View {
    @EnvironmentObject var dataController: DataController
    
    @State private var animatedText = ""
    @State private var animator: TextAnimator?
    
    @Binding var selectedIntroPage: Int
    @Binding var showQuestionsView: Bool
    @Binding var animationStage: Int
    
    let categories: FetchedResults<Category>
    
    var content: NewCategoryContent {
        return NewCategoryContent.pages[selectedIntroPage]
    }
    
    @AppStorage("currentAppView") var currentAppView: Int = 0
    @AppStorage("unlockNewCategory") var newCategory: Bool = false
    @AppStorage("currentCategory") var currentCategory: Int = 0
    @AppStorage("showTopics") var showTopics: Bool = false
    @AppStorage("selectedTopicId") var selectedTopicId: String = ""
    
    var body: some View {
        VStack (spacing: 10) {
            
            if selectedIntroPage == 0 {
                showXmark()
                    .padding(.horizontal)
                    .padding(.top, 50)
            }
            
            Image(content.imageName)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 90)
                .padding(.top,  selectedIntroPage == 0 ? 60 : 140)
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
                RoundButton(
                    buttonImage: "arrow.right",
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
            animator = TextAnimator(text: content.description, animatedText: $animatedText, speed: 0.03)
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
            completeTopic()
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
                
                
                let newCategory =  categories[currentCategory].categoryLifeArea
                
                print("New category: \(newCategory)")
                    
                DispatchQueue.global(qos: .background).async {
                    Mixpanel.mainInstance().track(event: "Discovered new realm: \(newCategory)")
                }
                
            }
            
        }
    }
    
    private func completeTopic() {
        Task {
            if let topicId = UUID(uuidString: selectedTopicId) {
                await dataController.completeTopic2(id: topicId)
            }
        }
        
    }
    
    private func showXmark() -> some View {
        HStack {
            
            Spacer()
            
            Button {
                currentAppView = 1
            } label: {
                
                Image(systemName: "xmark.circle.fill")
                    .font(.system(size: 25))
                    .foregroundStyle(AppColors.progressBarPrimary.opacity(0.3))
            }
        }
        
    }
}
