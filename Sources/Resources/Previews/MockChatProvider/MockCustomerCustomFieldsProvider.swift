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

// MARK: - MockCustomerCustomFieldsProvider

// `@unchecked Sendable` is intentional: this is preview/mock code (only used inside
// SwiftUI `#Preview` blocks on the main actor). `CustomerCustomFieldsProvider` is a public
// SDK protocol that is not `@MainActor`, so `@MainActor` on this class would just cascade
// `nonisolated` / `nonisolated(unsafe)` across every member — a lateral opt-out rather
// than a real concurrency guarantee.
final class MockCustomerCustomFieldsProvider: CustomerCustomFieldsProvider, @unchecked Sendable {

    // MARK: - Properties

    private var fields: [String: String] = [:]

    // MARK: - Methods

    func get() -> [String: String] {
        fields
    }

    func set(_ customFields: [String: String]) async throws {
        fields.merge(customFields) { _, new in new }
    }
}
