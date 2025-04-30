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

struct ShareSheet: UIViewControllerRepresentable {
    
    // MARK: - Properties
    
    @Environment(\.presentationMode) var presentationMode
    
    var activityItems: [Any]
    
    private var activityController: UIActivityViewController {
        let avc = UIActivityViewController(activityItems: activityItems, applicationActivities: nil)
        avc.completionWithItemsHandler = { _, _, _, _ in
            self.presentationMode.wrappedValue.dismiss()
        }
        
        return avc
    }
    
    // MARK: - Methods
    
    func makeUIViewController(context: UIViewControllerRepresentableContext<ShareSheet>)
    -> WrappedViewController<UIActivityViewController> {
        let controller = WrappedViewController(wrappedController: activityController)
        return controller
    }
    
    func updateUIViewController(
        _ uiViewController: WrappedViewController<UIActivityViewController>,
        context: UIViewControllerRepresentableContext<ShareSheet>
    ) {
        uiViewController.wrappedController = activityController
    }
}

// MARK: - WrappedViewController

class WrappedViewController<Controller: UIViewController>: UIViewController {
    
    // MARK: - Properties
    
    var wrappedController: Controller {
        didSet {
            guard wrappedController != oldValue else {
                return
            }
            
            oldValue.removeFromParent()
            oldValue.view.removeFromSuperview()
            
            addChild(wrappedController)
            view.addSubview(wrappedController.view)
            
            wrappedController.view.frame = view.bounds
        }
    }
    
    // MARK: - Init
    
    init(wrappedController: Controller) {
        self.wrappedController = wrappedController
        super.init(nibName: nil, bundle: nil)
        
        addChild(wrappedController)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Methods
    
    override func loadView() {
        super.loadView()
        
        view.addSubview(wrappedController.view)
        
        wrappedController.view.frame = view.bounds
    }
}
