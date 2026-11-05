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

/// Represents the loading state of an asynchronous operation
enum AttachmentLoadingState<Value> {

    /// The operation has not started
    case initial

    /// The operation is currently in progress
    case loading

    /// The operation has completed successfully
    case loaded(Value)
    
    /// The operation has failed
    case failed

    /// Check if the state matches a specific case, ignoring associated values
    var isInitial: Bool {
        if case .initial = self {
            return true
        } else {
            return false
        }
    }

    // periphery:ignore - used only by the test target, which Periphery does not index
    var isLoaded: Bool {
        if case .loaded = self {
            return true
        } else {
            return false
        }
    }

    var isFailed: Bool {
        if case .failed = self {
            return true
        } else {
            return false
        }
    }

    /// Whether a (new) load may be started: nothing has been attempted yet, or the previous attempt failed.
    var canStartLoading: Bool {
        isInitial || isFailed
    }
}
