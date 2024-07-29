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
import UIKit
import UniformTypeIdentifiers

struct MediaPickerView: UIViewControllerRepresentable {
    
    // MARK: - Properties
    
    @SwiftUI.Environment(\.presentationMode) var presentationMode
    
    let attachmentRestrictions: AttachmentRestrictions
    
    var sourceType: UIImagePickerController.SourceType = .photoLibrary
    var onSelected: (AttachmentItem) -> Void
    
    // MARK: - Methods
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    func makeUIViewController(context: UIViewControllerRepresentableContext<MediaPickerView>) -> UIImagePickerController {
        let validContentTypes = UTType.resolve(for: attachmentRestrictions.allowedTypes)
        
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        picker.sourceType = sourceType
        picker.mediaTypes = validContentTypes.map(\.identifier)
        picker.allowsEditing = true
        
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: UIViewControllerRepresentableContext<MediaPickerView>) { }
    
    // MARK: - Coordinator
    
    class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
        
        // MARK: - Properties
        
        let parent: MediaPickerView
        
        // MARK: - Init
        
        init(_ parent: MediaPickerView) {
            self.parent = parent
        }
        
        // MARK: - Methods
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
            let mediaUrl: URL
            if let url = info[UIImagePickerController.InfoKey.imageURL] as? URL {
                mediaUrl = url
            } else if let url = info[UIImagePickerController.InfoKey.mediaURL] as? URL {
                do {
                    mediaUrl = try getTemporaryUrlForMedia(url)
                } catch {
                    error.logError()
                    
                    parent.presentationMode.wrappedValue.dismiss()
                    return
                }
            } else if let originalImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
                do {
                    mediaUrl = try getImageUrl(originalImage)
                } catch {
                    error.logError()
                    
                    parent.presentationMode.wrappedValue.dismiss()
                    return
                }
            } else {
                LogManager.error(.unableToParse("imageUrl", from: info))
                
                parent.presentationMode.wrappedValue.dismiss()
                return
            }
            
            let name = mediaUrl.lastPathComponent
            parent.onSelected(AttachmentItem(url: mediaUrl, friendlyName: name, mimeType: mediaUrl.mimeType, fileName: name))
            parent.presentationMode.wrappedValue.dismiss()
        }
        
        private func getImageUrl(_ image: UIImage) throws -> URL {
            guard let documentsUrl = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
                throw CommonError.failed("Unable to get Documents directory URL")
            }
            guard let data = image.jpegData(compressionQuality: 0.7) else {
                throw CommonError.unableToParse("pngData")
            }
            
            let localPath = documentsUrl.appendingPathComponent("\(UUID().uuidString).jpeg")
            try data.write(to: localPath)
            
            return localPath
        }
        
        private func getTemporaryUrlForMedia(_ url: URL) throws -> URL {
            guard let documentsUrl = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
                throw CommonError.failed("Unable to get Documents directory URL")
            }
            
            let fileUrl = documentsUrl.appendingPathComponent(url.lastPathComponent)
            
            if FileManager.default.fileExists(atPath: fileUrl.path) {
                return fileUrl
            } else {
                try FileManager.default.copyItem(at: url, to: fileUrl)
                
                return fileUrl
            }
        }
    }
}
