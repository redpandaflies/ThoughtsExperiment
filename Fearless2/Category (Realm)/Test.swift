//
//  Test.swift
//  Fearless2
//
//  Created by Yue Deng-Wu on 3/3/25.
//
import Pow
import SwiftUI

struct TestView: View {
//    @State private var playAnimation: Bool //Animation won't work if directly using UserDefaults. Best to trigger animation via a @State private var
//    @State private var isFirstAnimationComplete = false
//    
//    init() {
//        self.playAnimation = UserDefaults.standard.bool(forKey: "showFirstCategory")
//    }
    @AppStorage("currentAppView") var currentAppView: Int = 0
    @AppStorage("currentCategory") var currentCategory: Int = 0
    @AppStorage("unlockNewCategory") var newCategory: Bool = false
    @AppStorage("showTopics") var showTopics: Bool = false
    
    var body: some View {
           
        VStack {
//            if playAnimation {
            
            Button {
                newCategory = false
                currentCategory = 0
                showTopics = false
                currentAppView = 1
               
            } label: {
                Text("😇")
                    .font(.system(size: 100))
                    .transition(.movingParts.blur)

                Text("Halls of Ambition")
                    .multilineTextAlignment(.center)
                    .font(.system(size: 35, design: .serif))
                    .foregroundStyle(AppColors.black1)
                    .transition(.movingParts.blur)
            }
//            }
            
        }//VStack
//        .onAppear {
//            playAnimation = false
//            
//            withAnimation (.smooth(duration: 2)) {
//                playAnimation = true
//            }
//            
//        }
//        .onChange(of: self.playAnimation) {
//            UserDefaults.standard.set(playAnimation, forKey: "showFirstCategory")
//        }
       
    }
}
//
//struct TestView_Previews: PreviewProvider {
//    static var previews: some View {
//        TestView()
//
//    }
//}
