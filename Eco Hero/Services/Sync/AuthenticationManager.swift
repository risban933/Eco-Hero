//
//  AuthenticationManager.swift
//  Eco Hero
//
//  Created by Rishabh Bansal on 11/15/25.
//

import Foundation
import SwiftUI

/// Manages local-only authentication state (no remote backend)
@Observable
class AuthenticationManager {
    var isAuthenticated: Bool
    var currentUserEmail: String?
    var currentUserID: String?
    var errorMessage: String?

    private let userDefaults: UserDefaults
    private let userIDKey = "EcoHeroLocalUserID"
    private let emailKey = "EcoHeroLocalUserEmail"
    private var hasSetupListener = false

    init(userDefaults: UserDefaults = .standard) {
        self.userDefaults = userDefaults

        if let storedID = userDefaults.string(forKey: userIDKey) {
            currentUserID = storedID
        } else {
            let newID = UUID().uuidString
            userDefaults.set(newID, forKey: userIDKey)
            currentUserID = newID
        }

        currentUserEmail = userDefaults.string(forKey: emailKey)
        isAuthenticated = true
    }

    func setupAuthListener() {
        guard !hasSetupListener else {
            print("⚠️ AuthManager: Listener already setup, skipping")
            return
        }
        hasSetupListener = true

        if currentUserEmail == nil {
            currentUserEmail = "hero@eco.local"
            userDefaults.set(currentUserEmail, forKey: emailKey)
        }

        isAuthenticated = true
        print("🔄 AuthManager: Using local auth state for user \(currentUserID ?? "unknown")")
    }

    func signIn(email: String, password: String) async throws {
        guard !email.isEmpty, !password.isEmpty else {
            errorMessage = AuthError.invalidCredentials.errorDescription
            throw AuthError.invalidCredentials
        }

        currentUserEmail = email
        userDefaults.set(email, forKey: emailKey)
        isAuthenticated = true
        errorMessage = nil
    }

    func signUp(email: String, password: String, displayName: String) async throws {
        guard !email.isEmpty else {
            errorMessage = AuthError.invalidEmail.errorDescription
            throw AuthError.invalidEmail
        }

        guard password.count >= 6 else {
            errorMessage = AuthError.weakPassword.errorDescription
            throw AuthError.weakPassword
        }

        guard !displayName.isEmpty else {
            errorMessage = AuthError.invalidCredentials.errorDescription
            throw AuthError.invalidCredentials
        }

        currentUserEmail = email
        userDefaults.set(email, forKey: emailKey)
        isAuthenticated = true
        errorMessage = nil
    }

    func signOut() throws {
        isAuthenticated = false
        currentUserEmail = nil
        errorMessage = nil
    }

    func resetPassword(email: String) async throws {
        guard !email.isEmpty else {
            throw AuthError.invalidEmail
        }

        // Local-only mode: simply acknowledge the request.
        print("ℹ️ AuthManager: Password reset requested for \(email), but no remote backend is configured.")
    }
}

enum AuthError: LocalizedError {
    case invalidCredentials
    case invalidEmail
    case emailAlreadyInUse
    case weakPassword
    case networkError
    case userNotFound
    case unknown

    var errorDescription: String? {
        switch self {
        case .invalidCredentials:
            return "Invalid email or password"
        case .invalidEmail:
            return "Please enter a valid email address"
        case .emailAlreadyInUse:
            return "This email is already registered"
        case .weakPassword:
            return "Password must be at least 6 characters"
        case .networkError:
            return "Network connection error. Please check your internet."
        case .userNotFound:
            return "No account found with this email"
        case .unknown:
            return "An error occurred. Please try again."
        }
    }
}
