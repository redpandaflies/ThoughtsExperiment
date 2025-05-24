//
//  AuthViewModel.swift
//  Fearless2
//
//  Created by Yue Deng-Wu on 5/21/25.
//

import AuthenticationServices
import Foundation
import Mixpanel
import OSLog
import SwiftUI


@MainActor
final class AuthViewModel: ObservableObject {
    
    @Published var isAuthenticated = false
    @Published var showAlert: Bool = false

    private let authService = AuthService.shared
  
    let loggerAuth = Logger.authEvents
    
    init() {
            checkSession()
        }

    private func checkSession() {
        if let session = authService.client.auth.currentSession {
                isAuthenticated = true
            loggerAuth.log("User already signed in: \(session.user.id)")

            } else {
                isAuthenticated = false
            }
        }
    

    func signInWithApple() {
      Task {
        do {
            let (id, name) = try await AuthService.shared.handleAppleAuthorization()
          // if no error, mark success
            withAnimation {
                self.isAuthenticated = true
            }
        // set-up mixpanel profile
            DispatchQueue.global().async {
                MixpanelService.shared.setUserProfile(distinctId: id, name: name ?? "No name")
            }
            
        } catch {
          // show an alert
            await MainActor.run {
                self.showAlert = true
            }
        }
      }
    }
    
}
