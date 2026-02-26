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

import CXoneChatSDK
import SwiftUI
import UIKit
import UniformTypeIdentifiers

struct MediaCaptureView: UIViewControllerRepresentable {
    
    // MARK: - Properties
    
    @SwiftUI.Environment(\.presentationMode) var presentationMode
    
    let attachmentRestrictions: AttachmentRestrictions
    let localization: ChatLocalization
    let onSelected: (AttachmentItem) -> Void
    let onAlert: (ChatAlertType) -> Void
    
    // MARK: - Methods
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self, localization: localization, onAlert: onAlert)
    }
    
    func makeUIViewController(context: UIViewControllerRepresentableContext<MediaCaptureView>) -> UIImagePickerController {
        let validContentTypes = UTType.resolve(for: attachmentRestrictions.allowedTypes)
        
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        picker.sourceType = .camera
        picker.mediaTypes = validContentTypes.map(\.identifier)
        picker.allowsEditing = true
        
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: UIViewControllerRepresentableContext<MediaCaptureView>) { }
    
    // MARK: - Coordinator
    
    final class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
        
        // MARK: - Properties
        
        let parent: MediaCaptureView
        let localization: ChatLocalization
        let onAlert: (ChatAlertType) -> Void
        
        // MARK: - Init
        
        init(_ parent: MediaCaptureView, localization: ChatLocalization, onAlert: @escaping (ChatAlertType) -> Void) {
            self.parent = parent
            self.localization = localization
            self.onAlert = onAlert
        }
        
        // MARK: - Methods
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
            LogManager.trace("Media captured successfully")
            
            let mediaUrl: URL
            
            do {
                if let url = info[UIImagePickerController.InfoKey.imageURL] as? URL {
                    mediaUrl = url
                } else if let url = info[UIImagePickerController.InfoKey.mediaURL] as? URL {
                    mediaUrl = try getTemporaryUrlForMedia(url)
                } else if let originalImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
                    mediaUrl = try getImageUrl(originalImage)
                } else if let editedImage = info[UIImagePickerController.InfoKey.editedImage] as? UIImage {
                    mediaUrl = try getImageUrl(editedImage)
                } else {
                    throw CommonError.unableToParse("mediaUrl", from: info)
                }
                
                parent.onSelected(AttachmentItem(from: mediaUrl))
            } catch {
                error.logError()
                
                onAlert(.genericError(localization: localization))
            }
            
            parent.presentationMode.wrappedValue.dismiss()
        }
    }
}

// MARK: - Helpers

private extension MediaCaptureView.Coordinator {
    
    func getImageUrl(_ image: UIImage) throws -> URL {
        LogManager.trace("Saving captured image to a temporary location to create an AttachmentItem")
        
        guard let cachesUrl = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first else {
            throw CommonError.failed("Unable to get Caches directory URL")
        }
        
        // For iOS 15 compatibility, ensure we're normalizing the image orientation
        let normalizedImage = image.fixOrientation()
        
        // Use higher compression quality for better image clarity
        guard let data = normalizedImage.jpegData(compressionQuality: 0.85) else {
            throw CommonError.unableToParse("jpegData")
        }
        
        let localPath = cachesUrl.appendingPathComponent("\(LowercaseUUID().uuidString).jpeg")
        try data.write(to: localPath)
        
        return localPath
    }
    
    func getTemporaryUrlForMedia(_ url: URL) throws -> URL {
        LogManager.trace("Copying captured media to a temporary location to create an AttachmentItem")
        
        guard let cachesUrl = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first else {
            throw CommonError.failed("Unable to get Caches directory URL")
        }
        
        let fileUrl = cachesUrl.appendingPathComponent(url.lastPathComponent)
        
        if FileManager.default.fileExists(atPath: fileUrl.path) {
            return fileUrl
        } else {
            try FileManager.default.copyItem(at: url, to: fileUrl)
            
            return fileUrl
        }
        
    }
}

private extension AttachmentItem {
    
    init(from url: URL) {
        self.init(
            url: url,
            friendlyName: url.lastPathComponent,
            mimeType: url.mimeType,
            fileName: url.lastPathComponent
        )
    }
}
