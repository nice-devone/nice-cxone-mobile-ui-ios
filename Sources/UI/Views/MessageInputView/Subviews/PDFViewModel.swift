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

@preconcurrency import PDFKit
import SwiftUI

@MainActor
class PDFViewModel: ObservableObject {

    // MARK: - Properties

    @Published var thumbnailLoadingState: AttachmentLoadingState<UIImage> = .initial
    @Published var documentLoadingState: AttachmentLoadingState<PDFDocument> = .initial

    @Binding var alertType: ChatAlertType?

    let url: URL
    let loader: AttachmentLoader

    private let requiresSecurityScope: Bool
    
    private nonisolated static let thumbnailDimension: CGFloat = 1024
    
    // MARK: - Init

    init(attachmentItem: AttachmentItem, alertType: Binding<ChatAlertType?>) {
        self.url = attachmentItem.url
        self.requiresSecurityScope = attachmentItem.requiresSecurityScope
        self.loader = AttachmentLoader(url: attachmentItem.url)
        self._alertType = alertType

        loadDocumentFromLoaderOrCache(url: url)
        
        loadThumbnail()
    }
    
    // MARK: - Methods

    func loadThumbnail() {
        guard thumbnailLoadingState.isInitial || thumbnailLoadingState.isFailed else {
            return
        }

        let stableIdentifier = extractStableIdentifier(from: url)
        let cacheKey = stableIdentifier + ":thumbnail"

        if let cachedData = AttachmentCache.shared.data(for: cacheKey), let cachedImage = UIImage(data: cachedData) {
            self.thumbnailLoadingState = .loaded(cachedImage)
            return
        }

        thumbnailLoadingState = .loading
        
        Task { [weak self] in
            guard let self else {
                return
            }

            let thumbnail = await self.createThumbnail(url: self.url)
            
            await MainActor.run {
                if let thumbnail {
                    if let data = thumbnail.pngData() {
                        AttachmentCache.shared.set(data, for: cacheKey)
                    }
                    
                    self.thumbnailLoadingState = .loaded(thumbnail)
                } else {
                    self.alertType = .genericError
                    self.thumbnailLoadingState = .failed
                }
            }
        }
    }

    func preparePDFForViewing() {
        guard documentLoadingState.isInitial || documentLoadingState.isFailed else {
            return
        }

        let stableIdentifier = extractStableIdentifier(from: url)
        let documentCacheKey = stableIdentifier + ":document"

        // Check document cache first
        if let cachedData = AttachmentCache.shared.data(for: documentCacheKey), let document = PDFDocument(data: cachedData) {
            documentLoadingState = .loaded(document)
            return
        }

        documentLoadingState = .loading
        
        Task { [weak self] in
            guard let self else {
                return
            }
            
            if case .loaded(let data) = self.loader.loadingState, let document = PDFDocument(data: data) {
                // Also cache the document data for future use
                if let dataRep = document.dataRepresentation() {
                    AttachmentCache.shared.set(dataRep, for: documentCacheKey)
                }
                
                await MainActor.run {
                    self.documentLoadingState = .loaded(document)
                }
            } else if let document = await self.loadPDF(from: self.url) {
                await MainActor.run {
                    self.documentLoadingState = .loaded(document)
                }
            } else {
                await MainActor.run {
                    self.alertType = .genericError
                    self.documentLoadingState = .failed
                }
            }
        }
    }
}

// MARK: - Private methods

private extension PDFViewModel {
    
    func loadDocumentFromLoaderOrCache(url: URL) {
        // Check if document is already loaded in the loader
        if case .loaded(let data) = self.loader.loadingState, let document = PDFDocument(data: data) {
            self.documentLoadingState = .loaded(document)

            // Cache it with the stable identifier
            let stableIdentifier = extractStableIdentifier(from: url)
            let documentCacheKey = stableIdentifier + ":document"
            
            if let dataRep = document.dataRepresentation() {
                AttachmentCache.shared.set(dataRep, for: documentCacheKey)
            }
        } else {
            // Try loading from cache
            let stableIdentifier = extractStableIdentifier(from: url)
            let documentCacheKey = stableIdentifier + ":document"
            
            if let cachedData = AttachmentCache.shared.data(for: documentCacheKey), let document = PDFDocument(data: cachedData) {
                self.documentLoadingState = .loaded(document)
            }
        }
    }

    /// Extracts a stable identifier from a URL by removing the changing token components
    nonisolated func extractStableIdentifier(from url: URL) -> String {
        let urlString = url.absoluteString
        
        // Extract attachment ID pattern - looking for IDs like 7d2a3ec4-37c4-4e97-b842-97ca6d141b64
        if let attachmentIDRange = urlString.range(of: "[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}", options: .regularExpression) {
            return String(urlString[attachmentIDRange])
        }
        
        // Fallback to just stripping the token query parameter
        if let queryStart = urlString.range(of: "?downloadAttachmentToken=")?.lowerBound {
            return String(urlString[..<queryStart])
        }
        
        // If all else fails, use the full URL
        return urlString
    }

    func createThumbnail(url: URL) async -> UIImage? {
        let stableIdentifier = extractStableIdentifier(from: url)
        let cacheKey = stableIdentifier + ":thumbnail"
        // 1. Check cache first (on main thread, since NSCache is thread-safe)
        if let cachedData = AttachmentCache.shared.data(for: cacheKey), let cachedImage = UIImage(data: cachedData) {
            return cachedImage
        }
        
        // 2. Check if we already have the data in loader
        if case .loaded(let data) = self.loader.loadingState, let document = PDFDocument(data: data), let page = document.page(at: .zero) {
            let thumbnail = page.thumbnail(
                of: CGSize(width: Self.thumbnailDimension, height: Self.thumbnailDimension),
                for: .artBox
            )
            
            // Cache the thumbnail
            if let data = thumbnail.pngData() {
                AttachmentCache.shared.set(data, for: cacheKey)
            }
            
            return thumbnail
        }

        // 3. Generate thumbnail in background
        let requiresSecurityScope = self.requiresSecurityScope
        return await Task.detached(priority: .userInitiated) {
            PDFViewModel.withSecurityScopedURLIfNeeded(url, requiresSecurityScope: requiresSecurityScope) { url in
                guard let document = PDFDocument(url: url), let page = document.page(at: .zero) else {
                    return nil
                }

                let thumbnail = page.thumbnail(
                    of: CGSize(width: PDFViewModel.thumbnailDimension, height: PDFViewModel.thumbnailDimension),
                    for: .artBox
                )
                
                // 4. Cache the thumbnail as PNG data
                if let data = thumbnail.pngData() {
                    AttachmentCache.shared.set(data, for: cacheKey)
                }
                // 5. Also cache the full document if we just downloaded it
                if let data = document.dataRepresentation() {
                    AttachmentCache.shared.set(data, for: stableIdentifier + ":document")
                }

                return thumbnail
            }
        }.value
    }

    func loadPDF(from url: URL) async -> PDFDocument? {
        let stableIdentifier = extractStableIdentifier(from: url)
        let documentCacheKey = stableIdentifier + ":document"
        
        // Try to load from data in loader first
        if case .loaded(let data) = self.loader.loadingState, let document = PDFDocument(data: data) {
            // Also cache it for future use
            if let dataRep = document.dataRepresentation() {
                AttachmentCache.shared.set(dataRep, for: documentCacheKey)
            }
            return document
        }
        
        // Try to load from cache
        if let cachedData = AttachmentCache.shared.data(for: documentCacheKey), let document = PDFDocument(data: cachedData) {
            return document
        }
        
        // Otherwise load from URL and cache
        let requiresSecurityScope = self.requiresSecurityScope
        return await Task
            .detached(priority: .userInitiated) {
                PDFViewModel.withSecurityScopedURLIfNeeded(url, requiresSecurityScope: requiresSecurityScope) { url in
                    guard let document = PDFDocument(url: url) else {
                        return nil
                    }

                    // Cache the PDF data
                    if let data = document.dataRepresentation() {
                        AttachmentCache.shared.set(data, for: documentCacheKey)
                    }

                    return document
                }
            }
            .value
    }
    
    nonisolated static func withSecurityScopedURLIfNeeded<T>(_ url: URL, requiresSecurityScope: Bool, operation: (URL) -> T?) -> T? {
        if requiresSecurityScope {
            guard url.startAccessingSecurityScopedResource() else {
                LogManager.error("Failed accessing security scoped resource")
                return nil
            }

            defer {
                url.stopAccessingSecurityScopedResource()
            }

            return operation(url)
        } else {
            return operation(url)
        }
    }
}
