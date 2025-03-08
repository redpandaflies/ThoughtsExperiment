//
//  OnboardingFirstCategoryView.swift
//  Fearless2
//
//  Created by Yue Deng-Wu on 2/26/25.
//

//import SwiftUI
//
//struct OnboardingFirstCategoryView: View {
//        @State private var animationStage: Int = 0
//        @State private var showTutorialSheetView: Bool = false
//    
//        @Binding var selectedCategory: String
//        
//        var category: Realm {
//            return QuestionCategory.getCategoryData(for: selectedCategory) ?? Realm.realmsData[7]
//        }
//    
//        var body: some View {
//            
//            VStack (spacing: 10) {
//             
//                Text(category.emoji)
//                    .font(.system(size: animationStage > 0 ? 50 : 100))
//
//                
//                Text(category.name)
//                    .font(.system(size: animationStage > 0 ? 25 : 35, design: .serif))
//                    .foregroundStyle(AppColors.textPrimary)
//
//
//                Text(category.discoveredDescription)
//                    .multilineTextAlignment(.center)
//                    .font(.system(size: 16, weight: .light))
//                    .foregroundStyle(AppColors.textPrimary)
//                    .opacity(animationStage >= 2 ? 0.8 : 0)
//                   
//             
//                Text("Discovered on " + DateFormatter.displayString(from: Date()))
//                    .font(.system(size: 16, weight: .thin).smallCaps())
//                    .fontWidth(.condensed)
//                    .foregroundStyle(AppColors.textPrimary.opacity(0.6))
//                    .opacity(animationStage >= 2 ? 1 : 0)
//                
//            }
//            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: animationStage > 0 ? .top : .center)
//            .padding(.top, animationStage > 0 ? 110 : 0)
//            .background {
//                BackgroundPrimary(backgroundColor: category.background)
//            }
//            .onAppear {
//                startAnimation()
//            }
//            .sheet(isPresented: $showTutorialSheetView, onDismiss: {
//                showTutorialSheetView = false
//            }) {
//                InfoFirstCategory(backgroundColor: category.background)
//                    .presentationDetents([.fraction(0.65)])
//                    .presentationCornerRadius(30)
//                
//            }
//        }
//        
//        private func startAnimation() {
//            // Initial state
//            animationStage = 0
//            
//            // First stage: Move to smaller layout
//            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
//                withAnimation(.smooth(duration: 0.25)) {
//                    animationStage = 1
//                }
//            }
//            
//            // Second stage: Fade in description
//            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
//                withAnimation(.smooth(duration: 0.3)) {
//                    animationStage = 2
//                }
//               
//            }
//            
//            // Show tutoril sheet
//            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
//                showTutorialSheetView = true
//            }
//        }
//}

//#Preview {
//    OnboardingFirstCategoryView()
//}
