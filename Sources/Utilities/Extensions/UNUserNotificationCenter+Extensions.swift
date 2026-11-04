//
// Copyright (c) 2021-2026. NICE Ltd. All rights reserved.
//
// Licensed under the NICE License;
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//    https://github.com/nice-devone/nice-cxone-mobile-ui-ios/blob/main/LICENSE
//
// TO THE EXTENT PERMITTED BY APPLICABLE LAW, THE CXONE MOBILE SDK IS PROVIDED ON
// AN "AS IS" BASIS. NICE HEREBY DISCLAIMS ALL WARRANTIES AND CONDITIONS, EXPRESS
// OR IMPLIED, INCLUDING (WITHOUT LIMITATION) WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE, NON-INFRINGEMENT, AND TITLE.
//

import CXoneChatSDK
import UserNotifications

extension UNUserNotificationCenter {
    
    @MainActor
    func scheduleThreadNotification(lastMessage: Message) async throws {
        LogManager.trace("Scheduling thread notification for message \(lastMessage.id) in thread \(lastMessage.threadId)")
        
        try await ensureNotificationAuthorization()
        
        let content = UNMutableNotificationContent()
    
        content.title = lastMessage.senderInfo?.fullName ?? L10n.Chat.FallbackMessage.noName
        content.subtitle = lastMessage.getLocalizedContentOrFallbackText(useFallback: true) ?? ""
        content.userInfo = [
            "threadId": lastMessage.threadId,
            "messageId": lastMessage.id,
            "timestamp": lastMessage.createdAt.timeIntervalSince1970,
            "messageFromDifferentThread": true
        ]
        content.sound = .default
        
        let identifier = "\(NotificationCenter.threadDeeplinkNotificationName)_\(lastMessage.id)"
        
        LogManager.trace("Creating notification with identifier: \(identifier)")
        
        let request = UNNotificationRequest(
            identifier: identifier,
            content: content,
            trigger: nil
        )
        
        do {
            try await add(request)
            
            LogManager.trace("Notification request added successfully for message \(lastMessage.id)")
        } catch {
            error.logError()
            
            throw error
        }
    }

    /// Schedules a notification telling the customer that a satisfaction survey is waiting in another thread.
    ///
    /// Its identifier carries the `threadDeeplinkNotificationName` prefix and its `userInfo` the `threadId`, so tapping it
    /// navigates to that thread the same way a new-message notification does - which is where the held survey is shown.
    @MainActor
    func scheduleSatisfactionSurveyNotification(for survey: SatisfactionSurvey) async throws {
        LogManager.trace("Scheduling satisfaction survey notification for thread \(survey.threadId)")

        try await ensureNotificationAuthorization()

        let content = UNMutableNotificationContent()
        content.title = L10n.Chat.SatisfactionSurvey.notificationTitle
        content.subtitle = survey.prompt
        content.userInfo = [
            "threadId": survey.threadId
        ]
        content.sound = .default

        let request = UNNotificationRequest(
            identifier: Self.satisfactionSurveyNotificationIdentifier(threadId: survey.threadId),
            content: content,
            trigger: nil
        )

        do {
            try await add(request)
        } catch {
            error.logError()

            throw error
        }
    }

    /// Removes the satisfaction survey notification for `threadId`, whether it is still pending or already delivered.
    func removeSatisfactionSurveyNotification(threadId: String) {
        let identifiers = [Self.satisfactionSurveyNotificationIdentifier(threadId: threadId)]

        removePendingNotificationRequests(withIdentifiers: identifiers)
        removeDeliveredNotifications(withIdentifiers: identifiers)
    }
}

// MARK: - Private Methods

private extension UNUserNotificationCenter {

    static func satisfactionSurveyNotificationIdentifier(threadId: String) -> String {
        "\(NotificationCenter.threadDeeplinkNotificationName)_satisfaction_survey_\(threadId)"
    }

    @MainActor
    func ensureNotificationAuthorization() async throws {
        let settings = await notificationSettings()
        
        switch settings.authorizationStatus {
        case .notDetermined:
            LogManager.warning("Notification permissions not determined, attempting to request")
            
            let success = try await requestAuthorization(options: [.alert, .badge, .sound])
            
            if !success {
                LogManager.error("Failed to get notification permission")
                
                throw NSError(domain: "UNUserNotificationCenter", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to get notification permission"])
            }
        case .denied:
            LogManager.error("Notification permissions denied by user")
            
            throw NSError(domain: "UNUserNotificationCenter", code: -1, userInfo: [NSLocalizedDescriptionKey: "Notification permissions denied"])
        case .authorized, .provisional, .ephemeral:
            LogManager.trace("Notification permissions granted: \(settings.authorizationStatus.rawValue)")
        @unknown default:
            LogManager.warning("Unknown notification authorization status: \(settings.authorizationStatus.rawValue)")
        }
    }
}
