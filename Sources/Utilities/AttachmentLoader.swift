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

import Foundation

@MainActor
final class AttachmentLoader: ObservableObject {
    
    // MARK: - Properties

    @Published var loadingState: AttachmentLoadingState<Data> = .initial

    private let url: URL
    private let cacheKey: String

    private var loadTask: Task<Void, Never>?
    
    // MARK: - Initializers

    init(url: URL, cacheKey: String? = nil) {
        self.url = url
        self.cacheKey = cacheKey ?? url.absoluteString
        
        load()
    }

    deinit {
        loadTask?.cancel()
    }

    // MARK: - Methods

    func load() {
        loadTask?.cancel()

        loadTask = Task { [weak self] in
            guard let self else {
                return
            }
            if let cached = AttachmentCache.shared.data(for: cacheKey) {
                await MainActor.run {
                    self.loadingState = .loaded(cached)
                }
                return
            }

            await MainActor.run {
                self.loadingState = .loading
            }

            do {
                let data = try await fetchData()

                // Fire-and-forget cache write to avoid blocking main actor
                let cacheKey = self.cacheKey
                Task.detached(priority: .utility) {
                    AttachmentCache.shared.set(data, for: cacheKey)
                }

                await MainActor.run {
                    self.loadingState = .loaded(data)
                }
            } catch is CancellationError {
                // Task was cancelled, don't update state
                return
            } catch {
                error.logError()

                await MainActor.run {
                    self.loadingState = .failed
                }
            }
        }

    }
}

// MARK: - Private Methods

private extension AttachmentLoader {

    /// A file picked from Files is security-scoped, and `URLSession` never starts the scope, so reading it
    /// that way fails with "Operation not permitted". Local files are read directly instead, off the main actor.
    func fetchData() async throws -> Data {
        if url.isFileURL {
            let url = self.url

            return try await Task.detached(priority: .userInitiated) {
                try url.accessSecurelyScopedResource { url in
                    try Data(contentsOf: url)
                }
            }
            .value
        } else {
            let (data, response) = try await URLSession.shared.data(from: url)

            if response.isHTTPFailure {
                throw URLError(.badServerResponse)
            }

            return data
        }
    }
}
