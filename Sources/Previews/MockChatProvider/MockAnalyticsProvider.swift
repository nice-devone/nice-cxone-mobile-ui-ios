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
import CXoneGuideUtility

// MARK: - MockAnalyticsProvider

final class MockAnalyticsProvider: AnalyticsProvider, @unchecked Sendable {

    // MARK: - Properties

    var visitorId: String? { nil }

    // MARK: - Methods

    func viewPage(title: String, url: String) async throws {
        LogManager.trace("[MOCK] View page: \(title)")
    }

    func viewPageEnded(title: String, url: String) async throws {
        LogManager.trace("[MOCK] View page ended: \(title)")
    }

    func chatWindowOpen() async throws {
        LogManager.trace("[MOCK] Chat window open")
    }

    func conversion(type: String, value: Double) async throws {
        LogManager.trace("[MOCK] Conversion: \(type) = \(value)")
    }
}
