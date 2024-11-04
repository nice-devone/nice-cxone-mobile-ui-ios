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

import CXoneChatSDK
import Foundation

extension Array {

    /// Returns the element at the specified index if it is within bounds, otherwise nil.
    subscript (safe index: Index) -> Element? {
        indices.contains(index) ? self[index] : nil
    }

    /// Implements += for a single element as opposed to an array of elements.
    static func += (lhs: inout Self, item: Element) {
        lhs.append(item)
    }
}

// MARK: - Array Grouping

extension Array {
    /// group the receiver into "similar" objects.
    ///
    /// The returned array will contain group lists, where each group consists of consecutive elements
    /// such that `compare(last, current) == true` for each element.  If `compare` returns
    /// false, a new group will be started.
    ///
    /// ## Example
    /// ```
    /// let input = [ "a1", "a2", "b", "a3" ]
    /// let result = input.group { $0[$0.startIndex] == $1[$1.startIndex] }
    ///
    /// assert(result == [["a1", "a2"], ["b"], ["a3"]])
    /// ```
    ///
    func group(using compare: (Element, Element) -> Bool) -> [[Element]] {
        let result = [[Element]]()

        return reduce(into: result) { result, element in
            switch result.last?.last {
            case .none:
                result.append([element])
            case .some(let prior) where compare(prior, element):
                result[result.count - 1].append(element)
            default:
                result.append([element])
            }
        }
    }
}

// MARK: - ChatThread

extension Array where Element == ChatThread {
    
    func thread(by id: UUID) -> ChatThread? {
        self.first { $0.id == id }
    }
    
    func index(of id: UUID) -> Int? {
        self.firstIndex { $0.id == id }
    }
}
