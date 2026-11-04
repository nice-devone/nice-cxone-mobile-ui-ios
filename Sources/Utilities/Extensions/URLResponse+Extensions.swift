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

import Foundation

extension URLResponse {

    /// Whether this is an HTTP response with a non-2xx status code.
    ///
    /// `URLSession` does not throw for 4xx/5xx responses, so callers check this explicitly.
    /// A non-HTTP response (e.g. `file://`) is not considered a failure.
    var isHTTPFailure: Bool {
        if let httpResponse = self as? HTTPURLResponse {
            return !httpResponse.isSuccess
        } else {
            return false
        }
    }
}

extension HTTPURLResponse {

    /// Whether the status code is in the 2xx success range.
    var isSuccess: Bool {
        (200...299).contains(statusCode)
    }
}
