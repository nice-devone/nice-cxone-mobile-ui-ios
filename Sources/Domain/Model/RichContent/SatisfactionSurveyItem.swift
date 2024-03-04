//
// Copyright (c) 2021-2023. NICE Ltd. All rights reserved.
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

/// Object for a satisfaction survey message cell
///
/// This struct is designed for creating items that prompt users to participate in satisfaction surveys or provide feedback.
/// It allows you to include a title, message, and a link to the survey form, enhancing user engagement and feedback collection.
///
/// ## Example
/// ```
/// let item = SatisfactionSurveyItem(title: Lorem.words(), message: Lorem.sentence(), buttonTitle: Lorem.word(), url: imageUrl)
/// ```
public struct SatisfactionSurveyItem: Hashable {
    
    // MARK: - Properties
    
    /// An optional title associated with the survey item.
    public let title: String?
    
    /// An optional message or description providing context for the survey.
    public let message: String?
    
    /// The label displayed on the button to start the survey.
    public let buttonTitle: String
    
    /// An optional URL that links to the survey or feedback form.
    public let url: URL?
    
    // MARK: - Init
    
    /// Initialization of the SatisfactionSurveyItem
    ///
    /// - Parameters:
    ///   - title: An optional title associated with the survey item.
    ///   - message: An optional message or description providing context for the survey.
    ///   - buttonTitle: The label displayed on the button to start the survey.
    ///   - url: An optional URL that links to the survey or feedback form.
    public init(title: String?, message: String?, buttonTitle: String, url: URL?) {
        self.title = title
        self.message = message
        self.buttonTitle = buttonTitle
        self.url = url
    }
}
