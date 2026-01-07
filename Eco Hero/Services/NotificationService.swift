//
//  NotificationService.swift
//  Eco Hero
//
//  Handles local push notifications for streak reminders, challenge deadlines,
//  and achievement unlocks.
//
//  Created by Rishabh Bansal on 11/15/25.
//

import Foundation
import UserNotifications
import Observation

@Observable
final class NotificationService {
    private(set) var isAuthorized: Bool = false
    private(set) var authorizationStatus: UNAuthorizationStatus = .notDetermined

    private let notificationCenter = UNUserNotificationCenter.current()

    // Notification identifiers
    private enum NotificationID {
        static let streakReminder = "eco.hero.streak.reminder"
        static let challengeDeadline = "eco.hero.challenge.deadline"
        static let challengeExpiring = "eco.hero.challenge.expiring"
        static let achievementUnlocked = "eco.hero.achievement.unlocked"
        static let dailyTip = "eco.hero.daily.tip"
    }

    init() {
        checkAuthorizationStatus()
    }

    // MARK: - Authorization

    func requestAuthorization() {
        notificationCenter.requestAuthorization(options: [.alert, .badge, .sound]) { [weak self] granted, error in
            DispatchQueue.main.async {
                self?.isAuthorized = granted
                self?.authorizationStatus = granted ? .authorized : .denied

                if granted {
                    print("✅ Notifications: Authorization granted")
                    self?.scheduleDefaultReminders()
                } else if let error = error {
                    print("❌ Notifications: Authorization error: \(error.localizedDescription)")
                } else {
                    print("⚠️ Notifications: Authorization denied")
                }
            }
        }
    }

    private func checkAuthorizationStatus() {
        notificationCenter.getNotificationSettings { [weak self] settings in
            DispatchQueue.main.async {
                self?.authorizationStatus = settings.authorizationStatus
                self?.isAuthorized = settings.authorizationStatus == .authorized
            }
        }
    }

    // MARK: - Streak Reminders

    /// Schedule a daily streak reminder at the specified hour
    func scheduleStreakReminder(at hour: Int, minute: Int = 0) {
        guard isAuthorized else { return }

        // Remove existing streak reminder
        notificationCenter.removePendingNotificationRequests(withIdentifiers: [NotificationID.streakReminder])

        let content = UNMutableNotificationContent()
        content.title = "Keep Your Streak Alive! 🔥"
        content.body = "Don't forget to log an eco-friendly action today to maintain your streak."
        content.sound = .default
        content.badge = 1

        var dateComponents = DateComponents()
        dateComponents.hour = hour
        dateComponents.minute = minute

        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        let request = UNNotificationRequest(identifier: NotificationID.streakReminder, content: content, trigger: trigger)

        notificationCenter.add(request) { error in
            if let error = error {
                print("❌ Notifications: Failed to schedule streak reminder: \(error.localizedDescription)")
            } else {
                print("✅ Notifications: Streak reminder scheduled for \(hour):\(String(format: "%02d", minute))")
            }
        }
    }

    /// Cancel streak reminder
    func cancelStreakReminder() {
        notificationCenter.removePendingNotificationRequests(withIdentifiers: [NotificationID.streakReminder])
        print("🔕 Notifications: Streak reminder cancelled")
    }

    // MARK: - Challenge Notifications

    /// Schedule a notification for when a challenge is about to expire
    func scheduleChallengeExpiringNotification(challengeID: String, title: String, deadline: Date, hoursBefore: Int = 24) {
        guard isAuthorized else { return }

        let notificationDate = deadline.addingTimeInterval(-Double(hoursBefore * 3600))

        // Don't schedule if notification time has already passed
        guard notificationDate > Date() else { return }

        let content = UNMutableNotificationContent()
        content.title = "Challenge Expiring Soon! ⏰"
        content.body = "\"\(title)\" ends in \(hoursBefore) hours. Complete it now!"
        content.sound = .default
        content.userInfo = ["challengeID": challengeID]

        let trigger = UNTimeIntervalNotificationTrigger(
            timeInterval: notificationDate.timeIntervalSinceNow,
            repeats: false
        )

        let identifier = "\(NotificationID.challengeExpiring).\(challengeID)"
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)

        notificationCenter.add(request) { error in
            if let error = error {
                print("❌ Notifications: Failed to schedule challenge expiring: \(error.localizedDescription)")
            } else {
                print("✅ Notifications: Challenge expiring notification scheduled for \(title)")
            }
        }
    }

    /// Notify when a challenge has expired/failed
    func notifyChallengeExpired(challengeID: String, title: String) {
        guard isAuthorized else { return }

        let content = UNMutableNotificationContent()
        content.title = "Challenge Expired 😔"
        content.body = "\"\(title)\" has ended. Start a new challenge to keep growing!"
        content.sound = .default
        content.userInfo = ["challengeID": challengeID]

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        let identifier = "\(NotificationID.challengeDeadline).\(challengeID)"
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)

        notificationCenter.add(request) { error in
            if let error = error {
                print("❌ Notifications: Failed to send challenge expired: \(error.localizedDescription)")
            }
        }
    }

    /// Cancel all notifications for a specific challenge
    func cancelChallengeNotifications(challengeID: String) {
        let identifiers = [
            "\(NotificationID.challengeExpiring).\(challengeID)",
            "\(NotificationID.challengeDeadline).\(challengeID)"
        ]
        notificationCenter.removePendingNotificationRequests(withIdentifiers: identifiers)
    }

    // MARK: - Achievement Notifications

    /// Send immediate notification for achievement unlock
    func notifyAchievementUnlocked(title: String, description: String) {
        guard isAuthorized else { return }

        let content = UNMutableNotificationContent()
        content.title = "Achievement Unlocked! 🏆"
        content.body = "\(title): \(description)"
        content.sound = UNNotificationSound(named: UNNotificationSoundName("achievement.caf"))

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 0.5, repeats: false)
        let identifier = "\(NotificationID.achievementUnlocked).\(UUID().uuidString)"
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)

        notificationCenter.add(request) { error in
            if let error = error {
                print("❌ Notifications: Failed to send achievement notification: \(error.localizedDescription)")
            }
        }
    }

    // MARK: - Daily Tip Notifications

    /// Schedule a daily eco-tip notification
    func scheduleDailyTip(at hour: Int, minute: Int = 0) {
        guard isAuthorized else { return }

        notificationCenter.removePendingNotificationRequests(withIdentifiers: [NotificationID.dailyTip])

        let tips = [
            "Using a reusable water bottle can save 160+ plastic bottles per year! 💧",
            "Biking just 5km instead of driving saves about 600g of CO₂ 🚴",
            "A 5-minute shorter shower saves up to 50 liters of water 🚿",
            "LED bulbs use 75% less energy than incandescent bulbs 💡",
            "Composting reduces methane emissions from landfills 🌱"
        ]

        let content = UNMutableNotificationContent()
        content.title = "Eco Tip of the Day 🌍"
        content.body = tips.randomElement() ?? tips[0]
        content.sound = .default

        var dateComponents = DateComponents()
        dateComponents.hour = hour
        dateComponents.minute = minute

        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        let request = UNNotificationRequest(identifier: NotificationID.dailyTip, content: content, trigger: trigger)

        notificationCenter.add(request) { error in
            if let error = error {
                print("❌ Notifications: Failed to schedule daily tip: \(error.localizedDescription)")
            } else {
                print("✅ Notifications: Daily tip scheduled for \(hour):\(String(format: "%02d", minute))")
            }
        }
    }

    // MARK: - Utility Methods

    /// Schedule default reminders after authorization
    private func scheduleDefaultReminders() {
        // Default streak reminder at 8 PM
        scheduleStreakReminder(at: 20, minute: 0)
    }

    /// Cancel all pending notifications
    func cancelAllNotifications() {
        notificationCenter.removeAllPendingNotificationRequests()
        print("🔕 Notifications: All notifications cancelled")
    }

    /// Get count of pending notifications
    func getPendingNotificationCount() async -> Int {
        let requests = await notificationCenter.pendingNotificationRequests()
        return requests.count
    }

    /// Clear the app badge
    func clearBadge() {
        UNUserNotificationCenter.current().setBadgeCount(0)
    }
}
