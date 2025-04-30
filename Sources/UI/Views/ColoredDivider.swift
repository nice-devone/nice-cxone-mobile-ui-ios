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

struct ColoredDivider: View {

    // MARK: - Properties
    
    let color: Color
    let width: CGFloat?
    let height: CGFloat
    
    // MARK: - Init
    
    init(_ color: Color, width: CGFloat? = nil, height: CGFloat = 1) {
        self.color = color
        self.width = width
        self.height = height
    }
    
    // MARK: - Body
    
    var body: some View {
        Rectangle()
            .fill(color)
            .frame(width: width, height: height)
    }
}

// MARK: - Preview

#Preview("Default") {
    // swiftlint:disable:next line_length force_try
    let information = try! AttributedString(markdown: "Notice the difference between SwiftUI's ***Divider*** color and the custom ***ColoredDivider*** even the both use same color ***(Color.black)*** and same dimension ***(width: .infinity, height: 1)***")
    
    VStack {
        Text("Modifiers")
            .font(.headline)
            .foregroundStyle(Color.gray)
        
        Text("color: ***.black***\n frame's height: ***1***")
            .font(.caption)
            .multilineTextAlignment(.center)
        
        Spacer()
        
        DescribedView(description: "***ColoredDivider***") {
            ColoredDivider(.black)
                .frame(height: 1)
        }
        
        Text("vs.")
            .padding()
        
        DescribedView(description: "***Divider***") {
            Divider()
                .background(Color.black)
                .frame(height: 1)
        }
        
        Spacer()
        
        HStack(alignment: .top) {
            Image(systemName: "exclamationmark.triangle.fill")
            
            Text(information)
                .font(.caption)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color(.systemGray5))
        )
        .padding(.top, 24)
    }
    .padding()
}

#Preview("Height & Opacity") {
    // swiftlint:disable:next line_length force_try
    let information = try! AttributedString(markdown: "The SwiftUI's ***Divider*** is not working properly with *background* view modifier and with the overlay that uses color with specific *opacity* the original \"line\" is visible.")
    
    VStack {
        Text("Shared Modifiers")
            .font(.headline)
            .foregroundStyle(Color.gray)
        
        Text("color: ***.red***\n opacity: ***0.5***\nframe's height: ***1***")
            .font(.caption)
            .multilineTextAlignment(.center)
        
        Spacer()
        
        DescribedView(description: "ColoredDivider - ***.frame***") {
            ColoredDivider(Color.red.opacity(0.5))
                .frame(width: .infinity, height: 10)
        }
        
        Text("vs.")
        
        DescribedView(description: "Divider - ***.frame***") {
            Divider()
                .background(Color.red.opacity(0.5))
                .frame(width: .infinity, height: 10)
        }
        
        Text("vs.")
        
        DescribedView(description: "Divider - ***.overlay***") {
            Divider()
                .frame(width: .infinity, height: 10)
                .overlay(Color.red.opacity(0.5))
        }
        
        Spacer()
        
        HStack(alignment: .top) {
            Image(systemName: "exclamationmark.triangle.fill")
            
            Text(information)
                .font(.caption)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color(.systemGray5))
        )
        .padding(.top, 24)
    }
    .padding()
}

private struct DescribedView<Content: View>: View {
    
    let description: String
    let content: () -> Content
    
    var body: some View {
        VStack {
            // swiftlint:disable:next force_try
            Text(try! AttributedString(markdown: description) )
                .font(.caption2)
                .foregroundStyle(Color(.systemGray))
            
            content()
        }
    }
}
