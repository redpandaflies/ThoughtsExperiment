//
//  AuthService.swift
//  Fearless2
//
//  Created by Yue Deng-Wu on 5/21/25.
//
import AuthenticationServices
import Foundation
import OSLog
import Supabase
import UIKit


struct SignInWithAppleResult {
    let token: String
    let fullName: PersonNameComponents?
    let email: String?
}

class AuthService: NSObject, ASAuthorizationControllerDelegate {
    
    static let shared = AuthService()
    
    private override init() {}
    
    let loggerSupabase = Logger.supabaseEvents
    let loggerAuth = Logger.authEvents
    
    let client = SupabaseClient(supabaseURL: Constants.supabaseURL, supabaseKey: Constants.supabaseKey)
    private var completionHandler: ((Result<SignInWithAppleResult, Error>) -> Void)? = nil
    
    enum AppleSignInError: Error {
        case viewControllerUnavailable
        case appleCredentialsNotFound
        case signInWithAppleFailed
        
    }
    
    @MainActor
    func handleAppleAuthorization() async throws -> (userId: String, displayName: String?) {
        do {
            // Present the Apple sign-in flow and get back the one-time code + name/email
            let result = try await signInWithAppleFlow()
            
            // Exchange the code with Supabase to get a session
            let session = try await signInWithOauth(idToken: result.token)
            let userId = session.user.id.uuidString
            
            // If Apple gave a name, send it into Supabase
            var displayName: String? = nil
            if let comps = result.fullName {
                displayName = PersonNameComponentsFormatter().string(from: comps)
                try await updateDisplayNameIfNeeded(displayName)
            }
      
            return (userId: userId, displayName: displayName)
            
        } catch {
            loggerAuth.error("Apple-SignIn failed: \(error.localizedDescription)")
            throw AuthError.authenticationFailed(error)
        }
    }
    
    // sign-in with apple flow
    func signInWithAppleFlow() async throws -> SignInWithAppleResult {
        try await withCheckedThrowingContinuation { continuation in
            appleIDAuthorization { result in
                switch result {
                case .success(let signInAppleResult):
                    continuation.resume(returning: signInAppleResult)
                    return
                case .failure(let error):
                    continuation.resume(throwing: error)
                }
                
            }
        }
    }
    
    func appleIDAuthorization(completion: @escaping (Result<SignInWithAppleResult, Error>) -> Void) {
        
        let request = ASAuthorizationAppleIDProvider().createRequest()
        
        // Set Scopes
        request.requestedScopes = [.fullName, .email]
        
        // Setup a controller to display the authorization flow
        let controller = ASAuthorizationController(authorizationRequests: [request])
        
        // Set delegate to handle the flow response.
        controller.delegate = self
        controller.presentationContextProvider = self
        
        self.completionHandler = completion
        // Action
        controller.performRequests()
        
    }
    
    // handle authorization success
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
           if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential,
              let idTokenData = appleIDCredential.identityToken,
              let idTokenString = String(data: idTokenData, encoding: .utf8) {
               
               let result = SignInWithAppleResult(
                   token: idTokenString,
                   fullName: appleIDCredential.fullName,
                   email: appleIDCredential.email
               )
               
               if let comps = result.fullName {
                 let name = PersonNameComponentsFormatter().string(from: comps)
                   loggerAuth.info("Apple account full name: \(name)")
               }
               completionHandler?(.success(result))
           } else {
               completionHandler?(.failure(NSError(domain: "AppleIDAuth", code: 0, userInfo: [NSLocalizedDescriptionKey: "Failed to retrieve identity token."])))
           }
       }
    
    // Handle authorization failure
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        loggerAuth.error("Sign in with Apple errored: \(error.localizedDescription)")
        completionHandler?(.failure(AppleSignInError.signInWithAppleFailed))
    }

    /// Supabase sign-in
    private func signInWithOauth(idToken: String) async throws -> Session {
        loggerSupabase.info("Supabase.auth.signInWithIdToken…")
        let response = try await client.auth.signInWithIdToken(
          credentials: .init(provider: .apple, idToken: idToken)
        )
        return response
    }
    
    private func updateDisplayNameIfNeeded(_ fullName: String?) async throws {
        guard let name = fullName, !name.isEmpty else {
            loggerAuth.info("Skipped display name update: name is nil or empty")
            return
        }
       
        loggerAuth.info("Updating Supabase user metadata with display_name: \(name)")
        
        // Build the patch payload
        let attrs = UserAttributes(
          data: ["display_name": AnyJSON.string(name)]
        )
        
        // Call endpoint to update user data
        let updateResp = try await client.auth.update(user: attrs)
        loggerSupabase.info("Metadata update returned: \(updateResp.userMetadata)")
    }
    
}

extension AuthService: ASAuthorizationControllerPresentationContextProviding {
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        // 1. Find the foreground‐active window scene
        let windowScene = UIApplication.shared.connectedScenes
            .first { $0.activationState == .foregroundActive }
            as? UIWindowScene

        // 2. From that scene, grab its key window
        let keyWindow = windowScene?
            .windows
            .first { $0.isKeyWindow }

        // 3. Fallback if for some reason it’s missing
        return keyWindow ?? UIWindow()
    }
}
