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

// MARK: - MockContactCustomFieldsProvider

final class MockContactCustomFieldsProvider: ContactCustomFieldsProvider, @unchecked Sendable {

    // MARK: - Properties

    private var fieldsByThread: [String: [String: String]] = [:]

    // MARK: - Methods

    func get(for threadId: String) -> [String: String] {
        fieldsByThread[threadId] ?? [:]
    }

    func set(_ customFields: [String: String], for threadId: String) async throws {
        var existing = fieldsByThread[threadId] ?? [:]
        existing.merge(customFields) { _, new in new }
        fieldsByThread[threadId] = existing
    }
}
