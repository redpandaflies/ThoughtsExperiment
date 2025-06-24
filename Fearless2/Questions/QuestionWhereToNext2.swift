//
//  QuestionWhereToNext2.swift
//  Fearless2
//
//  Created by Yue Deng-Wu on 4/16/25.
//

import SwiftUI

struct QuestionWhereToNext2: View {
    let imageName: String
    let title: String
    let subtitle: String
    
    let leftAction: () -> Void
    let rightAction: () -> Void
    let leftTitle: String
    let leftSubtitle: String
    let rightTitle: String
    let rightSubtitle: String
    let leftSymbol: String
    let rightSymbol: String
    
    init(
        imageName: String,
        title: String,
        subtitle: String,
        leftAction: @escaping () -> Void,
        rightAction: @escaping () -> Void,
        leftTitle: String,
        leftSubtitle: String = "",
        rightTitle: String,
        rightSubtitle: String = "",
        leftSymbol: String = "arrow.right",
        rightSymbol: String = "checkmark"
    ) {
        self.imageName = imageName
        self.title = title
        self.subtitle = subtitle
        self.leftAction = leftAction
        self.rightAction = rightAction
        self.leftTitle = leftTitle
        self.leftSubtitle = leftSubtitle
        self.rightTitle = rightTitle
        self.rightSubtitle = rightSubtitle
        self.leftSymbol = leftSymbol
        self.rightSymbol = rightSymbol
    }
    
    let screenWidth = UIScreen.current.bounds.width
    
    var body: some View {
        VStack (spacing: 10) {
            Image(imageName)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 175, height: 175)
                .blendMode(.plusLighter)
                .padding(.bottom, 10)
            
            Text(title)
                .multilineTextAlignment(.center)
                .font(.system(size: 25, design: .serif))
                .foregroundStyle(AppColors.textPrimary)
            
            Text(subtitle)
                .multilineTextAlignment(.center)
                .font(.system(size: 17, weight: .light))
                .foregroundStyle(AppColors.textPrimary.opacity(0.7))
                .lineSpacing(1.4)
                .padding(.bottom, 40)
                
            
            HStack {
                ButtonSquare(
                    title: leftTitle,
                    subtitle: leftSubtitle,
                    buttonColor: .dark,
                    leftSymbol: leftSymbol,
                    rightSymbol: rightSymbol,
                    height: 240
                )
                .onTapGesture {
                    leftAction()
                }
                
                ButtonSquare(
                    title: rightTitle,
                    subtitle: rightSubtitle,
                    buttonColor: .yellow,
                    leftSymbol: leftSymbol,
                    rightSymbol: rightSymbol,
                    height: 240
                )
                .onTapGesture {
                    rightAction()
                }
                
            }
            
        }
        .padding(.top, 40)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
    }
    
    private func answerBox(buttonColor: BoxStyle, title: String, subtitle: String) -> some View {
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
                buttonImage: buttonColor == .light ? rightSymbol : leftSymbol,
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
    
    private func backgroundColor(_ buttonColor: BoxStyle) -> any ShapeStyle {
        switch buttonColor{
        case .light:
            return LinearGradient(
                gradient: Gradient(colors: [Color.white, AppColors.boxSecondary]),
                startPoint: .top,
                endPoint: .bottom
            )

        default:
            return AppColors.boxGrey1.opacity(0.3)
        }
    }
    
    private func shadowProperties(_ buttonColor: BoxStyle) -> (color: Color, radius: CGFloat, y: CGFloat) {
        switch buttonColor {
        case .light:
            return (Color.black.opacity(0.05), 5, 2)
        default:
            return (Color.black.opacity(0.30), 15, 3)
        }
    }
}

