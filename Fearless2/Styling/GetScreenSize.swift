//
//  GetScreenSize.swift
//  Fearless2
//
//  Created by Yue Deng-Wu on 9/30/24.
//

import Foundation
import SwiftUI

extension UIWindow {
    static var current: UIWindow? {
        for scene in UIApplication.shared.connectedScenes {
            guard let windowScene = scene as? UIWindowScene else { continue }
            for window in windowScene.windows {
                if window.isKeyWindow { return window }
            }
        }
        return nil
    }
}


extension UIScreen {
    static var current: UIScreen {
        guard let currentScreen = UIWindow.current?.screen else { return UIScreen.main }
        
        return currentScreen
    }
}

