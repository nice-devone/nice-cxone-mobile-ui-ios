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

/// Protocol defining the required color properties for status styles used in the chat UI.
///
/// Conforming types provide colors for success, warning, and error statuses, including their containers and on-colors.
public protocol StatusStyleColors {
    /// The success status color.
    var success: Color { get }
    /// The color used for content on top of the success color.
    var onSuccess: Color { get }
    /// The success container color.
    var successContainer: Color { get }
    /// The color used for content on top of the success container.
    var onSuccessContainer: Color { get }
    /// The warning status color.
    var warning: Color { get }
    /// The color used for content on top of the warning color.
    var onWarning: Color { get }
    /// The warning container color.
    var warningContainer: Color { get }
    /// The color used for content on top of the warning container.
    var onWarningContainer: Color { get }
    /// The error status color.
    var error: Color { get }
    /// The color used for content on top of the error color.
    var onError: Color { get }
    /// The error container color.
    var errorContainer: Color { get }
    /// The color used for content on top of the error container.
    var onErrorContainer: Color { get }
}

// MARK: - Default Colors

/// Default implementation of `StatusStyleColors` providing concrete color values.
///
/// Use this struct to specify the main status colors for light and dark themes.
public struct StatusStyleColorsImpl: StatusStyleColors {
    
    // MARK: - Properties
    
    /// The success status color.
    public let success: Color
    /// The color used for content on top of the success color.
    public let onSuccess: Color
    /// The success container color.
    public let successContainer: Color
    /// The color used for content on top of the success container.
    public let onSuccessContainer: Color
    /// The warning status color.
    public let warning: Color
    /// The color used for content on top of the warning color.
    public let onWarning: Color
    /// The warning container color.
    public let warningContainer: Color
    /// The color used for content on top of the warning container.
    public let onWarningContainer: Color
    /// The error status color.
    public let error: Color
    /// The color used for content on top of the error color.
    public let onError: Color
    /// The error container color.
    public let errorContainer: Color
    /// The color used for content on top of the error container.
    public let onErrorContainer: Color
    
    // MARK: - Init
    
    /// Initializes a new instance with SwiftUI `Color` values.
    ///
    /// - Parameters:
    ///   - success: The success status color.
    ///   - onSuccess: The color used for content on top of the success color.
    ///   - successContainer: The success container color.
    ///   - onSuccessContainer: The color used for content on top of the success container.
    ///   - warning: The warning status color.
    ///   - onWarning: The color used for content on top of the warning color.
    ///   - warningContainer: The warning container color.
    ///   - onWarningContainer: The color used for content on top of the warning container.
    ///   - error: The error status color.
    ///   - onError: The color used for content on top of the error color.
    ///   - errorContainer: The error container color.
    ///   - onErrorContainer: The color used for content on top of the error container.
    public init(
        success: Color,
        onSuccess: Color,
        successContainer: Color,
        onSuccessContainer: Color,
        warning: Color,
        onWarning: Color,
        warningContainer: Color,
        onWarningContainer: Color,
        error: Color,
        onError: Color,
        errorContainer: Color,
        onErrorContainer: Color
    ) {
        self.success = success
        self.onSuccess = onSuccess
        self.successContainer = successContainer
        self.onSuccessContainer = onSuccessContainer
        self.warning = warning
        self.onWarning = onWarning
        self.warningContainer = warningContainer
        self.onWarningContainer = onWarningContainer
        self.error = error
        self.onError = onError
        self.errorContainer = errorContainer
        self.onErrorContainer = onErrorContainer
    }
    /// Initializes a new instance with `ColorAsset` values.
    ///
    /// - Parameters:
    ///   - success: The success status color asset.
    ///   - onSuccess: The color used for content on top of the success color asset.
    ///   - successContainer: The success container color asset.
    ///   - onSuccessContainer: The color used for content on top of the success container asset.
    ///   - warning: The warning status color asset.
    ///   - onWarning: The color used for content on top of the warning color asset.
    ///   - warningContainer: The warning container color asset.
    ///   - onWarningContainer: The color used for content on top of the warning container asset.
    ///   - error: The error status color asset.
    ///   - onError: The color used for content on top of the error color asset.
    ///   - errorContainer: The error container color asset.
    ///   - onErrorContainer: The color used for content on top of the error container asset.
    init(
        success: ColorAsset,
        onSuccess: ColorAsset,
        successContainer: ColorAsset,
        onSuccessContainer: ColorAsset,
        warning: ColorAsset,
        onWarning: ColorAsset,
        warningContainer: ColorAsset,
        onWarningContainer: ColorAsset,
        error: ColorAsset,
        onError: ColorAsset,
        errorContainer: ColorAsset,
        onErrorContainer: ColorAsset
    ) {
        self.success = success.swiftUIColor
        self.onSuccess = onSuccess.swiftUIColor
        self.successContainer = successContainer.swiftUIColor
        self.onSuccessContainer = onSuccessContainer.swiftUIColor
        self.warning = warning.swiftUIColor
        self.onWarning = onWarning.swiftUIColor
        self.warningContainer = warningContainer.swiftUIColor
        self.onWarningContainer = onWarningContainer.swiftUIColor
        self.error = error.swiftUIColor
        self.onError = onError.swiftUIColor
        self.errorContainer = errorContainer.swiftUIColor
        self.onErrorContainer = onErrorContainer.swiftUIColor
    }
    
    // MARK: - Static Properties
    
    /// Default light theme status colors.
    public static let defaultLight = StatusStyleColorsImpl(
        success: Asset.Colors.Positive.base,
        onSuccess: Asset.Colors.Positive._950,
        successContainer: Asset.Colors.Positive._100,
        onSuccessContainer: Asset.Colors.Positive._800,
        warning: Asset.Colors.Warning.base,
        onWarning: Asset.Colors.Warning._900,
        warningContainer: Asset.Colors.Warning._100,
        onWarningContainer: Asset.Colors.Warning._800,
        error: Asset.Colors.Negative._600,
        onError: Asset.Colors.Base.white,
        errorContainer: Asset.Colors.Negative._100,
        onErrorContainer: Asset.Colors.Negative._900
    )
    /// Default dark theme status colors.
    public static let defaultDark = StatusStyleColorsImpl(
        success: Asset.Colors.Positive._300,
        onSuccess: Asset.Colors.Positive._950,
        successContainer: Asset.Colors.Positive._800,
        onSuccessContainer: Asset.Colors.Positive._100,
        warning: Asset.Colors.Warning._300,
        onWarning: Asset.Colors.Warning._900,
        warningContainer: Asset.Colors.Warning._900,
        onWarningContainer: Asset.Colors.Warning._100,
        error: Asset.Colors.Negative._300,
        onError: Asset.Colors.Negative._900,
        errorContainer: Asset.Colors.Negative._900,
        onErrorContainer: Asset.Colors.Negative._100
    )
}
