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

extension Task where Success == Never, Failure == Never {
    
    private static var secondInNanoseconds: TimeInterval {
        1_000_000_000
    }
    
    static func sleep(seconds: Double) async {
        let duration = UInt64(seconds * secondInNanoseconds)
        
        do {
            try await Task.sleep(nanoseconds: duration)
        } catch {
            switch error {
            case is CancellationError:
                break
            default:
                error.logError()
            }
        }
    }
}
