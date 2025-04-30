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

import Foundation

/// ChatConfiguration holds additional configuration parameters that are passed to the UI module wrapping the SDK.
public struct ChatConfiguration {
    
    // MARK: - Properties
    
    /// Additional custom fields for the customer.
    ///
    /// These fields are used to privde extra information about the customer.
    ///
    /// - Note: Can be used to provide additional custom field(s) to the chat.
    ///
    /// - Important: Additional custom field(s) must be defined in the channel configuration.
    ///     Otherwise, the custom field(s) can cause the chat initialization to fail.
    public var additionalCustomerCustomFields: [String: String]
    
    /// Additional custom fields for the contact.
    ///
    /// These fields are used to provide extra information about the conversation.
    ///
    /// /// - Note: Can be used to provide additional custom field(s) to the chat.
    ///
    /// - Important: Additional custom field(s) must be defined in the channel configuration.
    ///     Otherwise, the custom field(s) can cause the conversation initialization to fail.
    public var additionalContactCustomFields: [String: String]
    
    // MARK: - Init
    
    /// Initializes a new instance of ChatConfiguration.
    ///
    /// - Parameters:
    ///   - additionalCustomerCustomFields: A dictionary containing additional custom fields for the customer.
    ///   - additionalContactCustomFields: A dictionary containing additional custom fields for the contact.
    public init(
        additionalCustomerCustomFields: [String: String] = [:],
        additionalContactCustomFields: [String: String] = [:]
    ) {
        self.additionalCustomerCustomFields = additionalCustomerCustomFields
        self.additionalContactCustomFields = additionalContactCustomFields
    }
}
