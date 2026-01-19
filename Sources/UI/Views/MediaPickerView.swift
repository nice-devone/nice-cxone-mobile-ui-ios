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
import PhotosUI
import SwiftUI

struct MediaPickerView: UIViewControllerRepresentable {
    
    // MARK: - Properties
    
    @Binding var attachmentsLoadingProgress: Progress?
    @Binding var attachments: [AttachmentItem]
    
    let attachmentRestrictions: AttachmentRestrictions
    let localization: ChatLocalization
    let onAlert: (ChatAlertType) -> Void
    
    // MARK: - Methods
    
    func makeUIViewController(context: Context) -> PHPickerViewController {
        let photoLibrary = PHPhotoLibrary.shared()
        var configuration = PHPickerConfiguration(photoLibrary: photoLibrary)
        // Setting `selectionLimit` to 0 enables the maximum number of selections supported by the system.
        configuration.selectionLimit = 0
        // Allowing both images and videos to be selected.
        configuration.filter = .any(of: [.images, .videos])
        // Setting the preselected assets if any.
        configuration.preselectedAssetIdentifiers = attachments.compactMap(\.assetIdentifier)
        configuration.preferredAssetRepresentationMode = .current
        
        let picker = PHPickerViewController(configuration: configuration)
        picker.delegate = context.coordinator
        
        return picker
    }
    
    func updateUIViewController(_ uiViewController: PHPickerViewController, context: Context) {
        // No update logic needed for this view controller
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(
            attachmentsLoadingProgress: $attachmentsLoadingProgress,
            attachments: $attachments,
            attachmentRestrictions: attachmentRestrictions,
            localization: localization,
            onAlert: onAlert
        )
    }
    
    // MARK: - Coordinator
    
    final class Coordinator: NSObject, PHPickerViewControllerDelegate {
        
        // MARK: - Properties
        
        @Binding var attachmentsLoadingProgress: Progress?
        @Binding var attachments: [AttachmentItem]
        
        let attachmentRestrictions: AttachmentRestrictions
        let localization: ChatLocalization
        let onAlert: (ChatAlertType) -> Void
        
        private var progressObservation: NSKeyValueObservation?
        private var hasErrorOccurred = false
        
        // MARK: - Init
        
        init(
            attachmentsLoadingProgress: Binding<Progress?>,
            attachments: Binding<[AttachmentItem]>,
            attachmentRestrictions: AttachmentRestrictions,
            localization: ChatLocalization,
            onAlert: @escaping (ChatAlertType) -> Void
        ) {
            self._attachmentsLoadingProgress = attachmentsLoadingProgress
            self._attachments = attachments
            self.attachmentRestrictions = attachmentRestrictions
            self.localization = localization
            self.onAlert = onAlert
        }
        
        deinit {
            progressObservation = nil
        }
        
        // MARK: - Methods
        
        func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
            LogManager.trace("User finished picking media with \(results.count) results")
            
            picker.dismiss(animated: true)
            
            Task { @MainActor [weak self] in
                guard let self else {
                    return
                }
                
                // Reset state
                self.hasErrorOccurred = false
                
                // Check if there are no results (cancel selection or a user deselects all attachments),
                // remove all attachments that have been previously selected
                guard results.isEmpty == false else {
                    LogManager.info("The user canceled selection or deselects previously selected attachments")
                    
                    self.attachments.removeAll { $0.assetIdentifier != nil }
                    return
                }
                
                // Remove previously selected attachments that have been deselected
                self.removeDeselectedAttachments(with: results)
                
                // Process each result that is newly selected
                for result in results where self.attachments.compactMap(\.assetIdentifier).contains(result.assetIdentifier) == false {
                    // If an error has occurred, stop the whole method processing
                    guard self.hasErrorOccurred == false else {
                        // `onAlert()` has already been called, so we can just return
                        return
                    }
                    
                    // Check if the item provider has any valid content type
                    let validContentTypes = UTType.resolve(for: self.attachmentRestrictions.allowedTypes)
                    
                    guard validContentTypes.first(where: { result.itemProvider.hasItemConformingToTypeIdentifier($0.identifier) }) != nil else {
                        LogManager.error("The customer selected not supported attachment type")
                        // No need to set the `hasErrorOccurred` flag here, the loop will stop the whole process
                        self.onAlert(.invalidAttachmentType(localization: self.localization))
                        return
                    }
                    
                    do {
                        // Check if the result is a video attachment
                        if [UTType.movie.identifier, UTType.video.identifier].contains(where: result.itemProvider.hasItemConformingToTypeIdentifier) {
                            try await self.didFinishPickingVideo(result: result)
                        } else {
                            try await self.didFinishPickingImage(result: result)
                        }
                    } catch CXoneChatError.invalidFileType {
                        CXoneChatError.invalidFileType.logError()
                        
                        self.hasErrorOccurred = true
                        self.onAlert(.invalidAttachmentSize(localization: self.localization))
                    } catch {
                        error.logError()
                        
                        self.hasErrorOccurred = true
                        self.onAlert(.genericError(localization: self.localization))
                    }
                }
            }
        }
    }
}

// MARK: - Private methods

private extension MediaPickerView.Coordinator {
    
    func removeDeselectedAttachments(with results: [PHPickerResult]) {
        LogManager.trace("Check if previously selected attachments are still selected")
        
        let selectedAssetIdentifiers = results.compactMap(\.assetIdentifier)
        
        attachments.removeAll { image in
            guard let assetIdentifier = image.assetIdentifier else {
                return false
            }
            
            return selectedAssetIdentifiers.contains(assetIdentifier) == false
        }
    }
    
    @MainActor
    func didFinishPickingVideo(result: PHPickerResult) async throws {
        LogManager.trace("Processing selected video")
        
        let typeIdentifier = result.itemProvider.registeredTypeIdentifiers.first { typeIdentifier in
            guard let type = UTType(typeIdentifier) else {
                return false
            }
            
            return type.conforms(to: .movie) || type.conforms(to: .video)
        }
        
        guard let typeIdentifier else {
            throw CommonError.failed("Unable to determine video type identifier")
        }
        
        let videoUrl = try await result.itemProvider.loadVideoURL(videoTypeIdentifier: typeIdentifier, assetIdentifier: result.assetIdentifier)
        let attachment = try getVideoAttachment(from: videoUrl, assetIdentifier: result.assetIdentifier)
        
        guard attachment.isSizeValid(allowedFileSize: attachmentRestrictions.allowedFileSize) else {
            throw CXoneChatError.invalidFileSize
        }
        // Check if the attachment is already in the attachments array
        guard self.attachments.contains(attachment) == false else {
            LogManager.info("Selected attachment is already in the attachments array, skipping")
            return
        }
        
        self.attachments.append(attachment)
    }
    
    func getVideoAttachment(from videoUrl: URL, assetIdentifier: String?) throws -> AttachmentItem {
        LogManager.trace("Copying selected video to cache directory")
        
        let destinationUrl = FileManager.default.temporaryDirectory.appendingPathComponent(videoUrl.lastPathComponent)
        
        if FileManager.default.fileExists(atPath: destinationUrl.path) == false {
            try FileManager.default.copyItem(atPath: videoUrl.path, toPath: destinationUrl.path)
        }
        
        return AttachmentItem(
            url: destinationUrl,
            friendlyName: destinationUrl.lastPathComponent,
            mimeType: destinationUrl.mimeType,
            fileName: destinationUrl.lastPathComponent,
            assetIdentifier: assetIdentifier
        )
    }
    
    @MainActor
    func didFinishPickingImage(result: PHPickerResult) async throws {
        LogManager.trace("Processing selected image")
        
        // Handle image files using loadObject
        guard result.itemProvider.canLoadObject(ofClass: UIImage.self) else {
            LogManager.error("Item provider cannot load object of type UIImage")
            
            onAlert(.genericError(localization: localization))
            hasErrorOccurred = true
            return
        }
        
        let rawImage = try await result.itemProvider.loadImageObject()
        let attachment = try getImageAttachment(from: rawImage, assetIdentifier: result.assetIdentifier)
        
        guard attachment.isSizeValid(allowedFileSize: attachmentRestrictions.allowedFileSize) else {
            throw CXoneChatError.invalidFileSize
        }
        guard attachments.contains(attachment) == false else {
            LogManager.info("The user select already selected image")
            return
        }
        
        attachments.append(attachment)
    }
    
    func getImageAttachment(from image: UIImage, assetIdentifier: String?) throws -> AttachmentItem {
        LogManager.trace("Saving selected image to cache directory")
        
        guard let cachesUrl = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first else {
            throw CommonError.failed("Unable to get Caches directory URL")
        }
        
        // For iOS 15 compatibility, ensure we're normalizing the image orientation
        let normalizedImage = image.fixOrientation()
        
        // Use higher compression quality for better image clarity
        guard let data = normalizedImage.jpegData(compressionQuality: 0.85) else {
            throw CommonError.unableToParse("jpegData")
        }
        
        // Check if the file already locally exists, we don't want to handle the same file multiple times
        if let first = try attachments.first(where: { try Data(contentsOf: $0.url) == data }) {
            LogManager.info("Attachment already exists -> reusing")
            return first
        }
        
        let fileName = "\(assetIdentifier?.split(separator: "/").first?.description ?? UUID().uuidString.lowercased()).jpeg"
        let localPath = cachesUrl.appendingPathComponent(fileName)
        try data.write(to: localPath)
        
        return AttachmentItem(
            url: localPath,
            friendlyName: localPath.lastPathComponent,
            mimeType: localPath.mimeType,
            fileName: localPath.lastPathComponent,
            assetIdentifier: assetIdentifier
        )
    }
}

// MARK: - Helpers

private extension NSItemProvider {
    
    func loadImageObject() async throws -> UIImage {
        guard canLoadObject(ofClass: UIImage.self) else {
            throw CommonError.failed("Unable to load UIImage data")
        }
        
        return try await withCheckedThrowingContinuation { continuation in
            self.loadObject(ofClass: UIImage.self) { data, error in
                if let image = data as? UIImage {
                    continuation.resume(returning: image)
                } else {
                    continuation.resume(throwing: error ?? CommonError.failed("Failed to load UIImage from ItemProvider"))
                }
            }
        }
    }
    
    func loadVideoURL(videoTypeIdentifier: String, assetIdentifier: String?) async throws -> URL {
        try await withCheckedThrowingContinuation { continuation in
            loadFileRepresentation(forTypeIdentifier: videoTypeIdentifier) { url, error in
                if let url {
                    do {
                        guard let cachesUrl = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first else {
                            throw CommonError.failed("Unable to get Caches directory URL")
                        }
                        
                        let destinationUrl = cachesUrl.appendingPathComponent(url.lastPathComponent)
                        
                        if FileManager.default.fileExists(atPath: destinationUrl.path) == false {
                            try FileManager.default.copyItem(atPath: url.path, toPath: destinationUrl.path)
                        }
                        
                        continuation.resume(returning: destinationUrl)
                    } catch {
                        continuation.resume(throwing: error)
                    }
                } else {
                    continuation.resume(throwing: error ?? CommonError.failed("Failed to load video URL from ItemProvider"))
                }
            }
        }
    }
}
