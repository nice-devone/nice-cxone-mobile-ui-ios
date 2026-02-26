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

/// A delegate protocol for receiving chat lifecycle callbacks.
///
/// Conform to this protocol to react to important events originating from the chat UI or its underlying
/// connection. For example, you can listen for authentication state changes and trigger your app's
/// OAuth flow when needed.
public protocol ChatDelegate: AnyObject {
    /// Called when the current connection (transaction) token expires and fresh credentials are required.
    ///
    /// Implement this method to re-trigger your app's OAuth flow and obtain a new authorization code and
    /// code verifier. Once retrieved, use your existing integration point to provide
    /// the refreshed credentials back to the chat SDK so it can continue the session.
    func onConnectionTokenExpired() async
}
