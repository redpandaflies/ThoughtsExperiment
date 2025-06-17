//
//  QuestionWhereToNext.swift
//  Fearless2
//
//  Created by Yue Deng-Wu on 4/16/25.
//

import SwiftUI

struct QuestionWhereToNext: View {
    let question: String
    let leftAction: () -> Void
    let rightAction: () -> Void
    let leftTitle: String
    let leftSubtitle: String
    let rightTitle: String
    let rightSubtitle: String
    
    init(
        question: String,
        leftAction: @escaping () -> Void,
        rightAction: @escaping () -> Void,
        leftTitle: String,
        leftSubtitle: String = "",
        rightTitle: String,
        rightSubtitle: String = ""
    ) {
        self.question = question
        self.leftAction = leftAction
        self.rightAction = rightAction
        self.leftTitle = leftTitle
        self.leftSubtitle = leftSubtitle
        self.rightTitle = rightTitle
        self.rightSubtitle = rightSubtitle
    }
    
    enum ButtonColor {
        case light
        case dark
    }
    
    let screenWidth = UIScreen.current.bounds.width
    
    var body: some View {
        VStack (alignment: .leading, spacing: 15) {
            Text(question)
                .multilineTextAlignment(.leading)
                .font(.system(size: 22, design: .serif))
                .foregroundStyle(AppColors.textPrimary)
                .fixedSize(horizontal: false, vertical: true)
                .padding(.bottom, 150)
                
            
            HStack {
                answerBox(
                    buttonColor: .dark,
                    title: leftTitle,
                    subtitle: leftSubtitle
                )
                .onTapGesture {
                    leftAction()
                }
                
                answerBox(
                    buttonColor: .light,
                    title: rightTitle,
                    subtitle: rightSubtitle
                  )
                .onTapGesture {
                    rightAction()
                }
            }
            .frame(maxWidth: .infinity)
            
        }
    }
    
    private func answerBox(buttonColor: ButtonColor, title: String, subtitle: String) -> some View {
        VStack (spacing: 10) {
            
            Text(title)
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)
                .font(.system(size: 20))
                .fontWidth(.condensed)
                .foregroundStyle(buttonColor == .light ? Color.black: AppColors.textPrimary)
            
            Text(subtitle)
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)
                .font(.system(size: 17, weight: .light))
                .fontWidth(.condensed)
                .foregroundStyle(buttonColor == .light ? Color.black: AppColors.textPrimary)
                .opacity(0.5)
            
            Spacer()
            
            RoundButton(
                buttonImage: buttonColor == .light ? "checkmark" : "arrow.right",
                buttonColor: buttonColor == .light ? .white : .dark
            )
            .disabled(true)
            
        }
        .padding(.horizontal)
        .padding(.vertical, 30)
        .frame(width: screenWidth * 0.43, height: 240)
        .contentShape(RoundedRectangle(cornerRadius: 20))
        .background {
            RoundedRectangle(cornerRadius: 20)
                .stroke(AppColors.strokePrimary.opacity(0.10), lineWidth: 0.5)
                .fill(AnyShapeStyle(backgroundColor(buttonColor)))
                .shadow(
                    color: shadowProperties(buttonColor).color,
                    radius: shadowProperties(buttonColor).radius,
                    x: 0,
                    y: shadowProperties(buttonColor).y
                )
                .blendMode(buttonColor == .light ? .normal : .colorDodge)
            
        }
    }
    
    private func backgroundColor(_ buttonColor: ButtonColor) -> any ShapeStyle {
        switch buttonColor{
        case .light:
            return LinearGradient(
                gradient: Gradient(colors: [Color.white, AppColors.boxSecondary]),
                startPoint: .top,
                endPoint: .bottom
            )

        case .dark:
            return AppColors.boxGrey1.opacity(0.3)
        }
    }
    
    private func shadowProperties(_ buttonColor: ButtonColor) -> (color: Color, radius: CGFloat, y: CGFloat) {
        switch buttonColor {
        case .light:
            return (Color.black.opacity(0.05), 5, 2)
        case .dark:
            return (Color.black.opacity(0.30), 15, 3)
        }
    }
}

