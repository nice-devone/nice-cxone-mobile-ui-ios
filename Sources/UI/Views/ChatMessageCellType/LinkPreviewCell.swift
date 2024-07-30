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

import Kingfisher
import SwiftUI

struct LinkPreviewCell: View {
    
    // MARK: - Properties
    
    @EnvironmentObject private var style: ChatStyle
    @EnvironmentObject private var localization: ChatLocalization

    @Binding private var isProcessDialogVisible: Bool
    @Binding private var alertType: ChatAlertType?
    
    @State private var documentURL: URL?
    @State private var isShareSheetVisible = false
    @State private var showPreview = false
    
    let message: ChatMessage
    let item: AttachmentItem
    
    // MARK: - Init
    
    init(message: ChatMessage, item: AttachmentItem, isProcessDialogVisible: Binding<Bool>, alertType: Binding<ChatAlertType?>) {
        self.message = message
        self.item = item
        self._isProcessDialogVisible = isProcessDialogVisible
        self._alertType = alertType
    }
    
    // MARK: - Builder
    
    var body: some View {
        ZStack(alignment: message.user.isAgent ? .bottomLeading : .bottomTrailing) {
            HStack {
                if !message.user.isAgent {
                    Spacer(minLength: UIScreen.main.bounds.size.width / 10)
                }
                
                attachment
                
                if message.user.isAgent {
                    Spacer(minLength: UIScreen.main.bounds.size.width / 10)
                }
            }
        }
        .onTapGesture {
            Task { @MainActor in
                await downloadDocument(url: item.url, fileName: item.fileName)
            }
            
        }
        .sheet(isPresented: $isShareSheetVisible) {
            ShareSheet(activityItems: [item.url])
        }
        .fullScreenCover(isPresented: $showPreview) {
            if let documentURL = self.documentURL {
                QuickLookPreview(url: documentURL, isPresented: $showPreview)
            }
        }
    }
}

// MARK: - Subviews

private extension LinkPreviewCell {

    var attachment: some View {
        HStack(alignment: .center) {
            if !message.user.isAgent {
                Spacer()
                
                openLinkImage
                    .rotationEffect(.degrees(180))
            } else {
                fileImage
            }
            
            VStack(alignment: message.user.isAgent ? .leading : .trailing, spacing: 0) {
                Text(item.friendlyName)
                    .font(.body)
                    .fontWeight(.medium)
                    .foregroundColor(style.formTextColor)
                
                if let host = item.url.host {
                    Text(host)
                        .font(.caption)
                        .foregroundColor(style.formTextColor)
                        .opacity(0.5)
                }
            }
            
            if message.user.isAgent {
                openLinkImage
                
                Spacer()
            } else {
                fileImage
            }
        }
        .padding(.horizontal, 14)
        .contextMenu {
            Button {
                isShareSheetVisible = true
            } label: {
                Text(localization.commonShare)

                Asset.share
            }
            
            Button {
                UIPasteboard.general.url = item.url
                UIPasteboard.general.string = item.url.absoluteString
            } label: {
                Text(localization.commonCopy)
                
                Asset.copy
            }
        }
    }
    
    var openLinkImage: some View {
        Asset.Attachment.openLink
            .font(.footnote)
            .foregroundColor(style.formTextColor)
            .opacity(0.25)
    }
    
    var fileImage: some View {
        Asset.Attachment.linkPlaceholder
            .font(.title2)
            .foregroundColor(style.formTextColor)
            .opacity(0.5)
    }

    @MainActor
    func downloadDocument(url: URL, fileName: String) async {
        isProcessDialogVisible = true
        
        do {
            let (localURL, _) = try await URLSession.shared.download(from: url)
            
            guard let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
                Log.error(.failed("Could not find documents directory to save document attachment."))
                return
            }
            
            let savedURL = documentsDirectory.appendingPathComponent(fileName)
            
            if FileManager.default.fileExists(atPath: savedURL.path) {
                try FileManager.default.removeItem(at: savedURL)
            }
            
            try FileManager.default.moveItem(at: localURL, to: savedURL)
            
            showPreview = true
            
            self.documentURL = savedURL
        } catch {
            error.logError()
            
            alertType = .downloadFailed(localization: localization)
        }
        
        isProcessDialogVisible = false
    }
}

// MARK: - Preview

struct LinkPreviewCell_Previews: PreviewProvider {

    static var previews: some View {
        Group {
            VStack {
                LinkPreviewCell(
                    message: MockData.linkPreviewMessage(user: MockData.agent), 
                    item: MockData.linkPreviewItem,
                    isProcessDialogVisible: .constant(false),
                    alertType: .constant(nil)
                )

                LinkPreviewCell(
                    message: MockData.linkPreviewMessage(user: MockData.customer), 
                    item: MockData.linkPreviewItem,
                    isProcessDialogVisible: .constant(false),
                    alertType: .constant(nil)
                )
            }
            .previewDisplayName("Light Mode")
            
            VStack {
                LinkPreviewCell(
                    message: MockData.linkPreviewMessage(user: MockData.agent), 
                    item: MockData.linkPreviewItem,
                    isProcessDialogVisible: .constant(false),
                    alertType: .constant(nil)
                )
                
                LinkPreviewCell(
                    message: MockData.linkPreviewMessage(user: MockData.customer), 
                    item: MockData.linkPreviewItem,
                    isProcessDialogVisible: .constant(false),
                    alertType: .constant(nil)
                )
            }
            .previewDisplayName("Dark Mode")
            .preferredColorScheme(.dark)
        }
        .environmentObject(ChatStyle())
        .environmentObject(ChatLocalization())
    }
}
