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
import Mockable
import UserNotifications

/// Tells the customer about a satisfaction survey held back for a thread they are not viewing.
@Mockable
@MainActor
protocol SatisfactionSurveyNotificationScheduling {

    // MARK: - Methods

    func scheduleNotification(for survey: SatisfactionSurvey) async

    func removeNotification(forThreadId threadId: String)
}

/// Delivers the notification as a local notification that deep-links to the survey's thread.
struct DefaultSurveyNotificationScheduler: SatisfactionSurveyNotificationScheduling {

    // MARK: - Methods

    func scheduleNotification(for survey: SatisfactionSurvey) async {
        do {
            try await UNUserNotificationCenter.current().scheduleSatisfactionSurveyNotification(for: survey)
        } catch {
            // The survey stays held for its thread either way; the notification is only a hint to go there
            error.logError()
        }
    }

    func removeNotification(forThreadId threadId: String) {
        UNUserNotificationCenter.current().removeSatisfactionSurveyNotification(threadId: threadId)
    }
}
