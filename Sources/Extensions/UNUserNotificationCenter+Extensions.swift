//
// Copyright (c) 2021-2025. NICE Ltd. All rights reserved.
//
// Licensed under the NICE License;
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//    https://github.com/nice-devone/nice-cxone-mobile-ui-ios/blob/main/LICENSE
//
// TO THE EXTENT PERMITTED BY APPLICABLE LAW, THE CXONE MOBILE SDK IS PROVIDED ON
// AN “AS IS” BASIS. NICE HEREBY DISCLAIMS ALL WARRANTIES AND CONDITIONS, EXPRESS
// OR IMPLIED, INCLUDING (WITHOUT LIMITATION) WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE, NON-INFRINGEMENT, AND TITLE.
//

import CXoneChatSDK
import UserNotifications

extension UNUserNotificationCenter {
    
    func scheduleThreadNotification(lastMessage: Message, chatLocalization: ChatLocalization) async throws {
        LogManager.trace("Scheduling thread notification for message \(lastMessage.id) in thread \(lastMessage.threadId)")
        
        // First check notification permission status
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
        
        let content = UNMutableNotificationContent()
    
        content.title = lastMessage.senderInfo?.fullName ?? chatLocalization.chatFallbackMessageNoName
        content.subtitle = lastMessage.getLocalizedContentOrFallbackText(basedOn: chatLocalization, useFallback: true) ?? ""
        content.userInfo = [
            "threadId": lastMessage.threadId.uuidString,
            "messageId": lastMessage.id.uuidString,
            "timestamp": lastMessage.createdAt.timeIntervalSince1970,
            "messageFromDifferentThread": true
        ]
        content.sound = .default
        
        let identifier = "\(NotificationCenter.threadDeeplinkNotificationName)_\(lastMessage.id.uuidString)"
        
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
}
