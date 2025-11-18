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

/// A `Shape` that draws a rectangle with individually configurable corner radii.
///
/// Use `UnevenRoundedRectangle` when you need rounded corners that differ on each
/// corner, while still supporting `InsettableShape` behaviors such as
/// `strokeBorder(_:lineWidth:)` and `inset(by:)`.
///
/// Corner radii are clamped to fit within half of the current inset rect's
/// width and height to ensure a valid path. When the shape is inset using
/// `inset(by:)`, the effective corner radii shrink by the inset amount.
///
/// - Parameters:
///   - topLeft: The radius for the top-left corner in points.
///   - topRight: The radius for the top-right corner in points.
///   - bottomLeft: The radius for the bottom-left corner in points.
///   - bottomRight: The radius for the bottom-right corner in points.
///   - insetAmount: The current inset applied to the shape. This value is
///     increased when calling `inset(by:)`.
struct UnevenRoundedRectangle: InsettableShape {
    
    // MARK: - Properties
    
    let topLeft: CGFloat
    let topRight: CGFloat
    let bottomLeft: CGFloat
    let bottomRight: CGFloat
    
    var insetAmount: CGFloat = 0

    // MARK: - Methods
    
    func path(in rect: CGRect) -> Path {
        var path = Path()

        let insetRect = rect.insetBy(dx: insetAmount, dy: insetAmount)

        let topLeft = max(0, min(min(topLeft - insetAmount, insetRect.width / 2), insetRect.height / 2))
        let topRight = max(0, min(min(topRight - insetAmount, insetRect.width / 2), insetRect.height / 2))
        let bottomLeft = max(0, min(min(bottomLeft - insetAmount, insetRect.width / 2), insetRect.height / 2))
        let bottomRight = max(0, min(min(bottomRight - insetAmount, insetRect.width / 2), insetRect.height / 2))

        // Initial position
        path.move(to: CGPoint(x: insetRect.minX + topLeft, y: insetRect.minY))
        // Top edge
        path.addLine(to: CGPoint(x: insetRect.maxX - topRight, y: insetRect.minY))
        // Top-right corner
        path.addArc(
            center: CGPoint(x: insetRect.maxX - topRight, y: insetRect.minY + topRight),
            radius: topRight,
            startAngle: .degrees(-90),
            endAngle: .degrees(0),
            clockwise: false
        )
        // Right edge
        path.addLine(to: CGPoint(x: insetRect.maxX, y: insetRect.maxY - bottomRight))
        // Bottom-right corner
        path.addArc(
            center: CGPoint(x: insetRect.maxX - bottomRight, y: insetRect.maxY - bottomRight),
            radius: bottomRight,
            startAngle: .degrees(0),
            endAngle: .degrees(90),
            clockwise: false
        )
        // Bottom edge
        path.addLine(to: CGPoint(x: insetRect.minX + bottomLeft, y: insetRect.maxY))
        // Bottom-left corner
        path.addArc(
            center: CGPoint(x: insetRect.minX + bottomLeft, y: insetRect.maxY - bottomLeft),
            radius: bottomLeft,
            startAngle: .degrees(90),
            endAngle: .degrees(180),
            clockwise: false
        )
        // Left edge
        path.addLine(to: CGPoint(x: insetRect.minX, y: insetRect.minY + topLeft))
        // Top-left corner
        path.addArc(
            center: CGPoint(x: insetRect.minX + topLeft, y: insetRect.minY + topLeft),
            radius: topLeft,
            startAngle: .degrees(180),
            endAngle: .degrees(270),
            clockwise: false
        )

        return path
    }

    func inset(by amount: CGFloat) -> some InsettableShape {
        var shape = self
        shape.insetAmount += amount
        
        return shape
    }
}

// MARK: - Preview

#Preview {
    VStack(spacing: 2) {
        UnevenRoundedRectangle(
            topLeft: 0,
            topRight: 50,
            bottomLeft: 4,
            bottomRight: 20,
            insetAmount: 1
        )
        .strokeBorder(.blue, lineWidth: 1)
        .background(.red)
        .frame(width: 200, height: 50)
        
        UnevenRoundedRectangle(
            topLeft: 4,
            topRight: 20,
            bottomLeft: 0,
            bottomRight: 50,
            insetAmount: 1
        )
        .strokeBorder(.blue, lineWidth: 1)
        .background(.red)
        .frame(width: 200, height: 50)
    }
}
