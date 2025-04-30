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

import Foundation
import SwiftUI

class DocumentStateViewModel: ObservableObject {
    
    // MARK: - Properties
    
    @Published var localURL: URL?
    @Published var isDownloading = false
    @Published var showError = false
    @Published var isReadyToPresent = false
    
    @Binding var alertType: ChatAlertType?
    
    let localization: ChatLocalization
    
    // MARK: - Init
    
    init(alertType: Binding<ChatAlertType?>, localization: ChatLocalization) {
        self._alertType = alertType
        self.localization = localization
    }
    
    // MARK: Methods
    
    func downloadAndSaveFile(url: URL) async {
        guard localURL == nil else {
            return
        }
        
        isDownloading = true
        
        do {
            let (tempLocalUrl, response) = try await URLSession.shared.download(from: url)
            
            let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            
            let originalFileName = (response as? HTTPURLResponse)?.suggestedFilename ?? url.lastPathComponent
            let destinationURL = documentsPath.appendingPathComponent(originalFileName)
            
            if FileManager.default.fileExists(atPath: destinationURL.path) {
                try FileManager.default.removeItem(at: destinationURL)
            }
            
            try FileManager.default.moveItem(at: tempLocalUrl, to: destinationURL)
            
            await MainActor.run { [weak self] in
                self?.localURL = destinationURL
                self?.isReadyToPresent = true
                self?.isDownloading = false
            }
        } catch {
            error.logError()
            
            await MainActor.run { [weak self] in
                guard let self else {
                    return
                }
                
                self.isDownloading = false
                self.showError = true
                
                self.alertType = .genericError(localization: self.localization)
            }
        }
    }
}
