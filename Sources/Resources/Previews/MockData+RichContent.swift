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

import CXoneChatSDK
import Foundation

// MARK: - Rich Content

extension MockData {

    static func randomEmoji(count: Int) -> [String] {
        var result = [String]()

        for _ in 0..<(count == .zero ? Int.random(in: 1...5) : count) {
            let range = [UInt32](0x1F601...0x1F64F)
            let ascii = range[Int.random(in: 0..<range.count)]

            if let emoji = UnicodeScalar(ascii)?.description {
                result.append(String(emoji))
            } else {
                result.append("❓")
            }
        }

        return result
    }

    static func quickReplyOptions(range: ClosedRange<Int> = 2...5) -> [RichMessageButton] {
        (0..<Int.random(in: range))
            .map { _ -> RichMessageButton in
                RichMessageButton(title: Lorem.words(nbWords: Int.random(in: 1..<3)), iconUrl: nil)
            }
    }

    static func richMessageOptions() -> [RichMessageButton] {
        (0..<Int.random(in: 2...5))
            .map { _ -> RichMessageButton in
                RichMessageButton(
                    title: Lorem.words(nbWords: Int.random(in: 1..<3)),
                    description: Bool.random() ? Lorem.sentence() : nil,
                    iconUrl: Bool.random() ? imageUrl() : nil
                )
            }
    }

    static func timeSlotOptions() -> [RichMessageTimeSlot] { // swiftlint:disable:this function_body_length
        let formatter = ISO8601DateFormatter()

        return [
            RichMessageTimeSlot(
                id: LowercaseUUID().uuidString,
                duration: 2700,
                startTime: mockDate("2030-01-01T15:00:00+01:00", using: formatter)
            ),

            RichMessageTimeSlot(
                id: LowercaseUUID().uuidString,
                duration: 1800,
                startTime: mockDate("2030-01-02T09:00:00+01:00", using: formatter)
            ),
            RichMessageTimeSlot(
                id: LowercaseUUID().uuidString,
                duration: 2700,
                startTime: mockDate("2030-01-02T09:00:00+01:00", using: formatter)
            ),
            RichMessageTimeSlot(
                id: LowercaseUUID().uuidString,
                duration: 5400,
                startTime: mockDate("2030-01-02T09:00:00+01:00", using: formatter)
            ),

            RichMessageTimeSlot(
                id: LowercaseUUID().uuidString,
                duration: 5400,
                startTime: mockDate("2030-01-03T15:00:00+01:00", using: formatter)
            ),
            RichMessageTimeSlot(
                id: LowercaseUUID().uuidString,
                duration: 2700,
                startTime: mockDate("2030-01-03T15:00:00+01:00", using: formatter)
            ),
            RichMessageTimeSlot(
                id: LowercaseUUID().uuidString,
                duration: 1800,
                startTime: mockDate("2030-01-03T16:00:00+01:00", using: formatter)
            ),
            RichMessageTimeSlot(
                id: LowercaseUUID().uuidString,
                duration: 2700,
                startTime: mockDate("2030-01-03T16:00:00+01:00", using: formatter)
            ),
            RichMessageTimeSlot(
                id: LowercaseUUID().uuidString,
                duration: 3600,
                startTime: mockDate("2030-01-03T16:00:00+01:00", using: formatter)
            ),
            RichMessageTimeSlot(
                id: LowercaseUUID().uuidString,
                duration: 5400,
                startTime: mockDate("2030-01-03T16:00:00+01:00", using: formatter)
            )
        ]
    }
}

// MARK: - Private Methods

private extension MockData {

    static func mockDate(_ string: String, using formatter: ISO8601DateFormatter) -> Date {
        guard let date = formatter.date(from: string) else {
            assertionFailure("Invalid mock ISO8601 date string: \(string)")
            return Date()
        }

        return date
    }
}
