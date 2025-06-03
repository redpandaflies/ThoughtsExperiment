//
//  LoginAppView.swift
//  Fearless2
//
//  Created by Yue Deng-Wu on 5/22/25.
//

import SwiftUI

struct LoginAppView: View {
    @EnvironmentObject var viewModelFactoryMain: ViewModelFactoryMain
    @StateObject private var authViewModel = AuthViewModel()
    
    var body: some View {
        if authViewModel.isAuthenticated {
            AppViewsManager(topicViewModel: viewModelFactoryMain.makeTopicViewModel())
            
        } else {
            LoginView(authViewModel: authViewModel)
        }
    }
}

