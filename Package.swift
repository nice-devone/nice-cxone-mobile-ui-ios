// swift-tools-version: 5.7
//
// Copyright (c) 2021-2024. NICE Ltd. All rights reserved.
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
        .package(url: "https://github.com/onevcat/Kingfisher.git", from: "7.0.0"),
        .package(url: "https://github.com/siteline/swiftui-introspect", from: "0.8.0"),
        .package(url: "https://github.com/wxxsw/GSPlayer.git", from: "0.2.25"),
        .package(url: "https://github.com/nice-devone/nice-cxone-mobile-sdk-ios.git", from: "2.3.0")
    ],
    targets: [
        .target(
            name: "CXoneChatUI",
            dependencies: [
                .byName(name: "Kingfisher"),
                .product(name: "SwiftUIIntrospect", package: "swiftui-introspect"),
                .byName(name: "GSPlayer"),
                .product(name: "CXoneChatSDK", package: "nice-cxone-mobile-sdk-ios")
            ],
            path: "Sources",
            resources: [
                .copy("../PrivacyInfo.xcprivacy")
            ],
            plugins: []
        )
    ]
)
