// swift-tools-version: 5.7
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

import PackageDescription

let package = Package(
    name: "CXoneChatUI",
    defaultLocalization: "en",
    platforms: [.iOS(.v15)],
    products: [
        .library(
            name: "CXoneChatUI",
            targets: ["CXoneChatUI"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/onevcat/Kingfisher.git", from: "8.0.0"),
        .package(url: "https://github.com/nice-devone/nice-cxone-mobile-sdk-ios.git", from: "3.1.1"),
        .package(url: "https://github.com/nice-devone/nice-cxone-mobile-guide-utility-ios.git", from: "3.1.0"),
        .package(url: "https://github.com/airbnb/lottie-spm.git", from: "4.5.2"),
    ],
    targets: [
        .target(
            name: "CXoneChatUI",
            dependencies: [
                .byName(name: "Kingfisher"),
                .product(name: "CXoneChatSDK", package: "nice-cxone-mobile-sdk-ios"),
                .product(name: "CXoneGuideUtility", package: "nice-cxone-mobile-guide-utility-ios"),
                .product(name: "Lottie", package: "lottie-spm"),
            ],
            path: "Sources",
            resources: [
                .copy("../PrivacyInfo.xcprivacy"),
                .copy("Resources/images.xcassets"),
            ],
            plugins: []
        )
    ]
)
