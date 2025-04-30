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

import SwiftUI

struct ApplicationDocumentThumbnailView: View, Themed {
    
    // MARK: - Properties
    
    @EnvironmentObject var style: ChatStyle
    
    @Environment(\.colorScheme) var scheme
    
    @ObservedObject private var viewModel: DocumentStateViewModel
    
    static private let labelCornerRadius: CGFloat = 6
    static private let fileExtensionContainerLineWidth: CGFloat = 1
    static private let minimumScaleFactor: CGFloat = 0.5
    static private let lineLimit = 1
    static private let fileExtensionVerticalPadding: CGFloat = 4
    static private let fileExtensionHorizontalPadding: CGFloat = 10
    static private let fileExtensionContainerVerticalPadding: CGFloat = 20
    static private let fileExtensionContainerHorizontalPadding: CGFloat = 12
    
    let fileExtension: String?
    let width: CGFloat
    let height: CGFloat
    let url: URL
    let localization: ChatLocalization
    
    // MARK: - Init
    
    init(fileExtension: String?, width: CGFloat, height: CGFloat, url: URL, alertType: Binding<ChatAlertType?>, localization: ChatLocalization) {
        self.viewModel = DocumentStateViewModel(alertType: alertType, localization: localization)
        self.fileExtension = fileExtension
        self.width = width
        self.height = height
        self.url = url
        self.localization = localization
    }
    
    // MARK: - Builder
    
    var body: some View {
        RoundedRectangle(cornerRadius: StyleGuide.Attachment.cornerRadius)
            .stroke(
                colors.background.muted,
                lineWidth: Self.fileExtensionContainerLineWidth
            )
            .background(
                RoundedRectangle(cornerRadius: StyleGuide.Attachment.cornerRadius)
                    .fill(colors.foreground.staticLight)
            )
            .frame(width: width, height: height)
            .overlay {
                if viewModel.isDownloading {
                    AttachmentLoadingView(title: localization.loadingDoc)
                } else {
                    if let fileExt = fileExtension {
                       Text(fileExt.uppercased())
                            .bold()
                            .foregroundStyle(colors.foreground.staticLight)
                            .font(.subheadline)
                            .minimumScaleFactor(Self.minimumScaleFactor)
                            .lineLimit(Self.lineLimit)
                            .padding(.vertical, Self.fileExtensionVerticalPadding)
                            .padding(.horizontal, Self.fileExtensionHorizontalPadding)
                            .background {
                                RoundedRectangle(cornerRadius: Self.labelCornerRadius)
                                    .fill(Color(.systemBlue))
                            }
                            .padding(.vertical, Self.fileExtensionContainerVerticalPadding)
                            .padding(.horizontal, Self.fileExtensionContainerHorizontalPadding)
                    }
               }
            }

            .onTapGesture {
                if viewModel.localURL != nil {
                    viewModel.isReadyToPresent = true
                } else {
                    Task {
                        await viewModel.downloadAndSaveFile(url: url)
                    }
                }
            }
            .sheet(isPresented: $viewModel.isReadyToPresent) {
                if let localURL = viewModel.localURL {
                    QuickLookPreview(url: localURL, isPresented: $viewModel.isReadyToPresent)
                }
            }
            .alert(isPresented: $viewModel.showError) {
                Alert(
                    title: Text(localization.commonError),
                    message: Text(localization.downloadingDocumentFailed),
                    dismissButton: .default(Text(localization.commonOk))
                )
            }
    }
}

// MARK: - Preview

#Preview {
    let localization = ChatLocalization()
    
    ScrollView {
        VStack(spacing: 100) {
            ZStack(alignment: Alignment(horizontal: .trailing, vertical: .top)) {
                ApplicationDocumentThumbnailView(
                    fileExtension: "doc",
                    width: StyleGuide.Attachment.regularDimension,
                    height: StyleGuide.Attachment.regularDimension,
                    url: MockData.docPreviewURL,
                    alertType: .constant(nil),
                    localization: localization
                )
                
                Button(action: {}, label: {
                    Asset.close
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 10, height: 10)
                        .tint(.white)
                        .padding(6)
                        .background(
                            Circle()
                                .fill(Color.red)
                        )
                        .background(
                            Circle()
                                .fill(Color.clear)
                                .frame(width: 44, height: 44)
                        )
                        .offset(x: 8, y: -8)
                })
            }

            ApplicationDocumentThumbnailView(
                fileExtension: "ppt",
                width: StyleGuide.Attachment.largeDimension,
                height: StyleGuide.Attachment.largeDimension,
                url: MockData.docPreviewURL,
                alertType: .constant(nil),
                localization: localization
            )
            
            ApplicationDocumentThumbnailView(
                fileExtension: "ppt",
                width: StyleGuide.Attachment.xtraLargeWidth,
                height: StyleGuide.Attachment.xtraLargeHeight,
                url: MockData.docPreviewURL,
                alertType: .constant(nil),
                localization: localization
            )
        }
    }
    .environmentObject(ChatStyle())
}
