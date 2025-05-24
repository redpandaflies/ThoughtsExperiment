//
//  LoginAppView.swift
//  Fearless2
//
//  Created by Yue Deng-Wu on 5/22/25.
//

import SwiftUI

struct LoginAppView: View {
    @StateObject private var authViewModel = AuthViewModel()
    
    var body: some View {
        if authViewModel.isAuthenticated {
            AppViewsManager()
            
        } else {
            LoginView(authViewModel: authViewModel)
        }
    }
}

