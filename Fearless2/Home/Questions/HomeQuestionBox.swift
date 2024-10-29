//
//  HomeQuestionBox.swift
//  Fearless2
//
//  Created by Yue Deng-Wu on 9/30/24.
//

//import SwiftUI
//
//struct HomeQuestionBox: View {
//    
//    let questionEmoji: String
//    let questionText: String
//    
//    let screenHeight = UIScreen.current.bounds.height
//    
//    var body: some View {
//        HStack (spacing: 12){
//            Text(questionEmoji)
//                .multilineTextAlignment(.center)
//                .font(.system(size: 19))
//                .fontWeight(.regular)
//                .foregroundStyle(.black)
//            VStack (alignment: .leading) {
//                
//               Text(questionText)
//                    .multilineTextAlignment(.leading)
//                    .font(.system(size: 13))
//                    .fontWeight(.medium)
//                    .foregroundStyle(AppColors.blackDefault)
//            }
//           
//            Spacer()
//
//        }
//        .padding()
//        .contentShape(Rectangle())
//        .background {
//            RoundedRectangle(cornerRadius: 20)
//                .stroke(Color(Color.white.opacity(0.4)), style: StrokeStyle(lineWidth: 1))
//                .fill(Color.white)
//                .shadow(color: .black.opacity(0.05), radius: 5.5, x: 0, y: 3)
//            
//        }
//    }
//}
//
//#Preview {
//    HomeQuestionBox(questionEmoji: "🔥", questionText: "How do you plan on staying present?")
//}
