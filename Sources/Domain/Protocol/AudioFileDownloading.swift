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
import Mockable

@Mockable
protocol AudioFileDownloading: Sendable {

    // MARK: - Methods

    func downloadAudioFile(from remoteURL: URL, fileName: String) async throws -> URL
}

final class DefaultAudioFileDownloader: AudioFileDownloading, Sendable {

    // MARK: - Methods

    func downloadAudioFile(from remoteURL: URL, fileName: String) async throws -> URL {
        guard let cachesDirectoryUrl = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first else {
            throw CommonError.failed("Unable to get Caches directory URL")
        }

        let sanitizedFilename = sanitizeFilename(fileName)
        let fileUrl = cachesDirectoryUrl.appendingPathComponent(sanitizedFilename)

        if FileManager().fileExists(atPath: fileUrl.path) {
            return fileUrl
        } else {
            return try await withCheckedThrowingContinuation { continuation in
                URLSession.shared.downloadTask(with: remoteURL) { (location, response, error) in
                    if let error {
                        continuation.resume(throwing: error)
                        return
                    }

                    guard let response = response as? HTTPURLResponse, response.isSuccess, let location else {
                        continuation.resume(throwing: CommonError.failed("Server error"))
                        return
                    }

                    do {
                        if FileManager.default.fileExists(atPath: fileUrl.path) {
                            try FileManager.default.removeItem(at: fileUrl)
                        }

                        try FileManager.default.moveItem(at: location, to: fileUrl)
                        continuation.resume(returning: fileUrl)
                    } catch {
                        LogManager.error("Failed to save audio file: \(error.localizedDescription)")
                        continuation.resume(throwing: error)
                    }
                }
                .resume()
            }
        }
    }
}

// MARK: - Private Methods

private extension DefaultAudioFileDownloader {

    func sanitizeFilename(_ filename: String) -> String {
        let illegalCharacters = CharacterSet(charactersIn: ":/\\?%*|\"<>")
        let components = filename.components(separatedBy: illegalCharacters)
        let safeName = components.joined(separator: "_")

        let lastPathComponent = (safeName as NSString).lastPathComponent

        if lastPathComponent.count > 100 {
            let fileExtension = (lastPathComponent as NSString).pathExtension
            let nameWithoutExtension = (lastPathComponent as NSString).deletingPathExtension
            let truncatedName = String(nameWithoutExtension.prefix(90))
            return truncatedName + (fileExtension.isEmpty ? "" : "." + fileExtension)
        } else {
            return lastPathComponent
        }
    }
}
