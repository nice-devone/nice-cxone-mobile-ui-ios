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
import Foundation

// MARK: - MockCustomerProvider

// `@unchecked Sendable` is intentional: this is preview/mock code (only used inside
// SwiftUI `#Preview` blocks on the main actor). `CustomerProvider` is a public SDK
// protocol that is not `@MainActor`, so `@MainActor` on this class would just cascade
// `nonisolated` / `nonisolated(unsafe)` across every member — a lateral opt-out rather
// than a real concurrency guarantee.
final class MockCustomerProvider: CustomerProvider, @unchecked Sendable {

    // MARK: - Properties

    private var customer = CustomerIdentity(id: "mock-customer-id", firstName: "You", lastName: nil)

    // MARK: - Methods

    func get() -> CustomerIdentity? {
        customer
    }

    func set(customer: CustomerIdentity?) throws {
        if let customer {
            self.customer = customer
        }
    }

    func setDeviceToken(_ token: String) {
        LogManager.trace("[MOCK] Set device token (string)")
    }

    func setDeviceToken(_ tokenData: Data) {
        LogManager.trace("[MOCK] Set device token (data)")
    }

    func setConnectionToken(_ token: String, expiresAt: Date) {
        LogManager.trace("[MOCK] Set connection token")
    }

    func setTokenDelegateListener(_ listener: TokenDelegateListener?) {
        LogManager.trace("[MOCK] Set token delegate listener")
    }

    func setAuthorizationCode(_ code: String) {
        LogManager.trace("[MOCK] Set authorization code")
    }

    func setCodeVerifier(_ verifier: String) {
        LogManager.trace("[MOCK] Set code verifier")
    }

    func setName(firstName: String, lastName: String) {
        customer = CustomerIdentity(id: customer.id, firstName: firstName, lastName: lastName)
    }
}
