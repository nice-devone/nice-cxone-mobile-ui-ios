// swift-tools-version: 6.0
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

import PackageDescription

let package = Package(
    name: "CXoneChatUI",
    defaultLocalization: "en",
    platforms: [
        .iOS(.v16)
    ],
    products: [
        .library(
            name: "CXoneChatUI",
            targets: ["CXoneChatUI"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/onevcat/Kingfisher.git", from: "8.0.0"),
        .package(url: "https://github.com/airbnb/lottie-spm.git", from: "4.5.2"),
        // Pinned exactly: Mockable 0.6.3+ caps xctest-dynamic-overlay below 1.10.0 (its manifest checks `swift(>=6.0)`
        // instead of `compiler(>=6.0)`), which clashes with swift-issue-reporting pulled in by swift-custom-dump.
        // Revisit once Mockable fixes the check upstream.
        .package(url: "https://github.com/Kolos65/Mockable", exact: "0.6.2"),
        .package(url: "https://github.com/nice-devone/nice-cxone-mobile-sdk-ios.git", from: "4.1.0"),
        .package(url: "https://github.com/nice-devone/nice-cxone-mobile-guide-utility-ios.git", from: "4.1.0")
    ],
    targets: [
        .target(
            name: "CXoneChatUI",
            dependencies: [
                .byName(name: "Kingfisher"),
                .product(name: "Lottie", package: "lottie-spm"),
                .product(name: "CXoneChatSDK", package: "nice-cxone-mobile-sdk-ios"),
                .product(name: "CXoneGuideUtility", package: "nice-cxone-mobile-guide-utility-ios"),
                .product(name: "Mockable", package: "Mockable")
            ],
            path: "Sources",
            resources: [
                .copy("../PrivacyInfo.xcprivacy"),
                .process("Resources/Images.xcassets")
            ],
            swiftSettings: [
                .define("MOCKING", .when(configuration: .debug))
            ]
        )
    ]
)
