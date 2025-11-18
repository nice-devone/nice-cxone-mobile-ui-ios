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

import SwiftUI

protocol Themed {
    var scheme: ColorScheme { get }
    var style: ChatStyle { get }
}

// MARK: - Helpers

extension Themed where Self: View {

    var colors: StyleColors {
        style.colors(for: scheme)
    }
}

extension Themed where Self: ButtonStyle {

    var colors: StyleColors {
        style.colors(for: scheme)
    }
}

extension Themed where Self: ViewModifier {

    var colors: StyleColors {
        style.colors(for: scheme)
    }
}

@available(iOS 16.0, *)
extension Themed where Self: DisclosureGroupStyle {

    var colors: StyleColors {
        style.colors(for: scheme)
    }
}
