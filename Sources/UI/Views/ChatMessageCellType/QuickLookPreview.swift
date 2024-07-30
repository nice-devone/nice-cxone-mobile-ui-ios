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

import QuickLook
import SwiftUI

struct QuickLookPreview: UIViewControllerRepresentable {
    
    // MARK: - Properties
    
    var url: URL
    
    @Binding var isPresented: Bool
    
    // MARK: - Methods
    
    func makeUIViewController(context: Context) -> some UIViewController {
        let previewController = QLPreviewController()
        previewController.dataSource = context.coordinator

        let navigationController = UINavigationController(rootViewController: previewController)

        previewController.navigationItem.rightBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .done,
            target: context.coordinator,
            action: #selector(context.coordinator.dismissPreviewController)
        )

        return navigationController
    }
    
    func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {
        // update if needed
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self, url: url, isPresented: $isPresented)
    }
    
    // MARK: - Coordinator
    
    class Coordinator: NSObject, QLPreviewControllerDataSource {
        var parent: QuickLookPreview
        var url: URL
        @Binding var isPresented: Bool
        
        // MARK: - Init
        
        init(parent: QuickLookPreview, url: URL, isPresented: Binding<Bool>) {
            self.parent = parent
            self.url = url
            self._isPresented = isPresented
        }
        
        // MARK: - Methods
        
        func numberOfPreviewItems(in controller: QLPreviewController) -> Int {
            1
        }
        
        func previewController(_ controller: QLPreviewController, previewItemAt index: Int) -> any QLPreviewItem {
            url as QLPreviewItem
        }
        
        @objc func dismissPreviewController() {
            self._isPresented.wrappedValue = false
        }
    }
}
