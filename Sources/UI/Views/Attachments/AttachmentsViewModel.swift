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

import SwiftUI

@MainActor
class AttachmentsViewModel: ObservableObject {

    // MARK: - Properties

    @Published var attachments = [SelectableAttachment]()
    @Published var inSelectionMode = false {
        didSet {
            selectNone()
        }
    }

    var selectedAttachments: [URL] {
        AttachmentItemMapper.map(attachments.filter(\.isSelected).map(\.messageType)).map(\.url)
    }
    
    // MARK: - Init

    init(messageTypes: [ChatMessageType]) {
        self.attachments = messageTypes.map(SelectableAttachmentMapper.map)
    }
}

// MARK: - Methods

extension AttachmentsViewModel {

    func selectAttachment(uuid: UUID) {
        guard let index = attachments.firstIndex(where: { $0.id == uuid }) else {
            LogManager.error(.failed("Unable to get index of selected attachment"))
            return
        }
        
        attachments[index].isSelected.toggle()
    }

    func selectAll() {
        attachments = attachments.map { attachment -> SelectableAttachment in
            var attachment = attachment
            attachment.isSelected = true
            
            return attachment
        }
    }

    func selectNone() {
        attachments = attachments.map { attachment -> SelectableAttachment in
            var attachment = attachment
            attachment.isSelected = false
            
            return attachment
        }
    }
}
