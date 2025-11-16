//
//  CloudSyncService.swift
//  Eco Hero
//
//  Created by Rishabh Bansal on 11/15/25.
//

import Foundation
import SwiftData

/// Placeholder cloud-sync service.
/// All methods complete immediately so the rest of the app can
/// continue to call them without checking platform availability.
@MainActor
@Observable
class CloudSyncService {
    var isSyncing: Bool = false
    var lastSyncError: Error?

    private func logSkip(_ action: String) {
        print("☁️ CloudSyncService: \(action) skipped (remote sync disabled)")
    }

    // MARK: - Activity Sync

    func syncActivity(_ activity: EcoActivity, userId: String) async throws {
        isSyncing = true
        defer { isSyncing = false }

        activity.isSynced = true
        lastSyncError = nil
        logSkip("syncActivity for user \(userId)")
    }

    func syncActivities(_ activities: [EcoActivity], userId: String) async throws {
        isSyncing = true
        defer { isSyncing = false }

        activities.forEach { $0.isSynced = true }
        lastSyncError = nil
        logSkip("syncActivities for user \(userId)")
    }

    func fetchActivities(userId: String) async throws -> [[String: Any]] {
        isSyncing = true
        defer { isSyncing = false }

        lastSyncError = nil
        logSkip("fetchActivities for user \(userId)")
        return []
    }

    // MARK: - User Profile Sync

    func syncProfile(_ profile: UserProfile) async throws {
        isSyncing = true
        defer { isSyncing = false }

        lastSyncError = nil
        logSkip("syncProfile for \(profile.userIdentifier)")
    }

    func fetchProfile(userId: String) async throws -> [String: Any]? {
        isSyncing = true
        defer { isSyncing = false }

        lastSyncError = nil
        logSkip("fetchProfile for user \(userId)")
        return nil
    }

    // MARK: - Challenge Sync

    func syncChallenge(_ challenge: Challenge, userId: String) async throws {
        isSyncing = true
        defer { isSyncing = false }

        lastSyncError = nil
        logSkip("syncChallenge \(challenge.id) for user \(userId)")
    }

    // MARK: - Achievement Sync

    func syncAchievement(_ achievement: Achievement, userId: String) async throws {
        isSyncing = true
        defer { isSyncing = false }

        lastSyncError = nil
        logSkip("syncAchievement \(achievement.badgeID) for user \(userId)")
    }

    // MARK: - Delete Operations

    func deleteActivity(remoteID: String, userId: String) async throws {
        isSyncing = true
        defer { isSyncing = false }

        lastSyncError = nil
        logSkip("deleteActivity \(remoteID) for user \(userId)")
    }

    // MARK: - Offline Persistence

    static func enableOfflinePersistence() {
        print("☁️ CloudSyncService: Offline persistence not required without a remote backend.")
    }
}

// MARK: - Cloud Sync Errors

enum CloudSyncError: LocalizedError {
    case syncFailed(String)
    case fetchFailed(String)
    case deleteFailed(String)
    case invalidData
    case userNotAuthenticated

    var errorDescription: String? {
        switch self {
        case .syncFailed(let message):
            return "Failed to sync data: \(message)"
        case .fetchFailed(let message):
            return "Failed to fetch data: \(message)"
        case .deleteFailed(let message):
            return "Failed to delete data: \(message)"
        case .invalidData:
            return "Invalid data format"
        case .userNotAuthenticated:
            return "User must be authenticated to sync data"
        }
    }
}
