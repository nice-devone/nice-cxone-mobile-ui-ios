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

protocol StyleColors {

    var customizable: CustomizableStyleColors { get }
    var foreground: ForegroundStyleColors { get }
    var background: BackgroundStyleColors { get }
    var accent: AccentStyleColors { get }
    var border: BorderStyleColors { get }
}

// MARK: - Default Colors

struct StyleColorsImpl: StyleColors {
    
    // MARK: - Properties
    
    let customizable: CustomizableStyleColors
    let foreground: ForegroundStyleColors
    let background: BackgroundStyleColors
    let accent: AccentStyleColors
    let border: BorderStyleColors
}
