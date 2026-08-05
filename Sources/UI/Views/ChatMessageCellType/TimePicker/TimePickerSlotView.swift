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

import SwiftUI

struct TimePickerSlotView: View, Themed {
    private typealias Accessibility = A11y.Conversation.MessageCell.TimePicker.Sheet

    // MARK: - Constants
    
    enum Constants {
        
        enum Sizing {
            static let minWidth: CGFloat = 100
            static let maxWidth: CGFloat = 200
            static let cornerRadius: CGFloat = 8
        }
        
        enum Padding {
            static let contentVertical: CGFloat = 12
        }
        
        enum Spacing {
            static let slotContentVertical: CGFloat = 4
        }
    }
    
    // MARK: - Properties
    
    @EnvironmentObject var style: ChatStyle
    
    @Environment(\.colorScheme) var scheme
    
    @Binding var selectedEntity: RichMessageTimeSlot?
    
    let entity: RichMessageTimeSlot
    
    private var isSelected: Bool {
        selectedEntity == entity
    }
    
    // MARK: - Builder
    
    var body: some View {
        Button {
            withAnimation {
                selectedEntity = isSelected ? nil : entity
            }
        } label: {
            VStack(alignment: .center, spacing: Constants.Spacing.slotContentVertical) {
                Text(entity.startTime.formatted(date: .omitted, time: .shortened))
                    .font(.headline.weight(.bold))
                    .foregroundStyle(isSelected ? colors.brand.onPrimary : colors.brand.primary)
                
                Text(L10n.Form.TimePicker.TimeSlot.duration(entity.durationInMinutes))
                    .font(.footnote)
                    .foregroundStyle(isSelected ? colors.brand.onPrimary : colors.content.tertiary)
            }
            .padding(.vertical, Constants.Padding.contentVertical)
        }
        .frame(minWidth: Constants.Sizing.minWidth, maxWidth: Constants.Sizing.maxWidth, alignment: .center)
        .background(
            RoundedRectangle(cornerRadius: Constants.Sizing.cornerRadius)
                .fill(isSelected ? colors.brand.primary : colors.background.surface.emphasis)
        )
        .accessibilityIdentifier(Accessibility.TimeSlots.Slot.identifier(id: entity.id))
        .accessibilityElement(children: .combine)
        .accessibilityLabel(
            isSelected
                ? Accessibility.Slot.Selected.label(entity.startTime.formatted(date: .long, time: .shortened), entity.durationInMinutes)
                : Accessibility.Slot.label(entity.startTime.formatted(date: .long, time: .shortened), entity.durationInMinutes)
        )
        .accessibilityHint(Accessibility.Slot.hint)
    }
}

// MARK: - Previews

@available(iOS 17, *)
#Preview {
    @Previewable @State var selectedEntity: RichMessageTimeSlot?
    
    LazyVGrid(columns: [GridItem(), GridItem(), GridItem()]) {
        ForEach(MockData.timeSlotOptions(), id: \.self) { entity in
            TimePickerSlotView(selectedEntity: $selectedEntity, entity: entity)
        }
    }
    .padding(.horizontal, 16)
    .environmentObject(ChatStyle())
}
