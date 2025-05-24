//
//  LoginView.swift
//  Fearless2
//
//  Created by Yue Deng-Wu on 5/21/25.
//
import AuthenticationServices
import SwiftUI

struct LoginView: View {
    @ObservedObject var authViewModel: AuthViewModel
    
    @State private var animatedText = ""
    @State private var animator: TextAnimator?
    @State private var animationCompletedText: Bool = false
    
    var content: OnboardingIntroContent = OnboardingIntroContent.pages[0]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10)  {
            
            SpinnerDefault()
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.top, 80)
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
               
            
            if animationCompletedText {
                SampleGoalsView(
                    onTapAction: { _ in
                   //TBD
                })
                .padding(.horizontal, 30)
            }
          
            Spacer()
    
            
            RectangleButtonPrimary(
                buttonText: "Sign in with Apple",
                action: {
                    authViewModel.signInWithApple()
                }, imageName: "apple.logo",
                buttonColor: .white
            )
            .padding(.horizontal)
            
//            SignInWithAppleButton { request in
//              request.requestedScopes = [.email, .fullName]
//            } onCompletion: { result in
//                authViewModel.signInWithApple(result: result)
//            }
//            .signInWithAppleButtonStyle(.white)
//            .cornerRadius(15)
//            .frame(height: 55)
//            .padding(.horizontal)
            
            
        }
        .padding(.bottom, 40)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .background {
            BackgroundPrimary(backgroundColor: AppColors.backgroundOnboardingIntro)
            
        }
        .onAppear {
            typewriterAnimation()
        }
        .alert("Log-in unsuccessful", isPresented: $authViewModel.showAlert) {
            Button("Continue", role: .cancel) {}
        } message: {
            Text("Something went wrong. Please try again.")
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
