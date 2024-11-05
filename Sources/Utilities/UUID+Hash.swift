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

import Foundation

extension UUID {
    func hash(with rhs: UUID) -> UUID {
        let hashed = (
            uuid.0 ^ rhs.uuid.0,
            uuid.1 ^ rhs.uuid.1,
            uuid.2 ^ rhs.uuid.2,
            uuid.3 ^ rhs.uuid.3,
            uuid.4 ^ rhs.uuid.4,
            uuid.5 ^ rhs.uuid.5,
            uuid.6 ^ rhs.uuid.6,
            uuid.7 ^ rhs.uuid.7,
            uuid.8 ^ rhs.uuid.8,
            uuid.9 ^ rhs.uuid.9,
            uuid.10 ^ rhs.uuid.10,
            uuid.11 ^ rhs.uuid.11,
            uuid.12 ^ rhs.uuid.12,
            uuid.13 ^ rhs.uuid.13,
            uuid.14 ^ rhs.uuid.14,
            uuid.15 ^ rhs.uuid.15
        )

        return UUID(uuid: hashed)
    }
}

extension [UUID] {
    func hash() -> UUID? {
        guard let first = first else {
            return nil
        }

        return dropFirst().reduce(first) { $0.hash(with: $1) }
    }
}
