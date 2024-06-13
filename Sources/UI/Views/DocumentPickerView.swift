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
import SwiftUI
import UniformTypeIdentifiers

struct DocumentPickerView: UIViewControllerRepresentable {
    
    // MARK: - Properties
    
    @SwiftUI.Environment(\.presentationMode) var presentationMode
    
    var onSelected: ([AttachmentItem]) -> Void

    // MARK: - Methods
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    func makeUIViewController(context: Context) -> UIDocumentPickerViewController {
        let validContentTypes = UTType.resolve(for: CXoneChat.shared.connection.channelConfiguration.fileRestrictions.allowedFileTypes)
        
        let documentPicker = UIDocumentPickerViewController(forOpeningContentTypes: validContentTypes)
        documentPicker.delegate = context.coordinator
        documentPicker.allowsMultipleSelection = true
        
        return documentPicker
    }

    func updateUIViewController(_ uiViewController: UIDocumentPickerViewController, context: Context) {
        // No update needed
    }

    // MARK: - Coordinator
    
    class Coordinator: NSObject, UIDocumentPickerDelegate {
    
        // MARK: - Properties
        
        let parent: DocumentPickerView

        // MARK: - Init
        
        init(_ parent: DocumentPickerView) {
            self.parent = parent
        }

        // MARK: - Methods
        
        func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
            parent.onSelected(urls.map { url in
                AttachmentItem(url: url, friendlyName: url.lastPathComponent, mimeType: url.mimeType, fileName: url.lastPathComponent)
            })
            
            parent.presentationMode.wrappedValue.dismiss()
        }

        func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
            parent.presentationMode.wrappedValue.dismiss()
        }
    }
}
