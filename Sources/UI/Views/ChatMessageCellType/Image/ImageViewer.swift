//
// Copyright (c) 2021-2023. NICE Ltd. All rights reserved.
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

import Combine
import Kingfisher
import SwiftUI

struct ImageViewer: View {
    
    // MARK: - Properties
    
    @Binding var viewerShown: Bool
    
    let image: Image
    
    // MARK: - Init
    
    init(image: Image, viewerShown: Binding<Bool>) {
        self.image = image
        self._viewerShown = viewerShown
    }
    
    // MARK: - Builder
    
    var body: some View {
        ZStack {
            VStack {
                closeButton
                
                Spacer()
            }
            .padding()
            
            content
        }
    }
}

// MARK: - Subviews

private extension ImageViewer {

    var closeButton: some View {
        HStack {
            Spacer()
            
            Button {
                viewerShown = false
            } label: {
                Asset.close
            }
        }
    }
    
    var content: some View {
        image
            .resizable()
            .aspectRatio(contentMode: .fit)
            .pinchToZoom()
    }
}

// MARK: - PinchZoomViewDelgate

private protocol PinchZoomViewDelgate: AnyObject {
    
    func pinchZoomView(_ pinchZoomView: PinchZoomView, didChangePinching isPinching: Bool)
    func pinchZoomView(_ pinchZoomView: PinchZoomView, didChangeScale scale: CGFloat)
    func pinchZoomView(_ pinchZoomView: PinchZoomView, didChangeAnchor anchor: UnitPoint)
    func pinchZoomView(_ pinchZoomView: PinchZoomView, didChangeOffset offset: CGSize)
}

// MARK: - PinchZoomView

private class PinchZoomView: UIView {
    
    // MARK: - Properties
    
    private var startLocation: CGPoint = .zero
    private var location: CGPoint = .zero
    private var numberOfTouches: Int = 0
    
    private(set) var scale: CGFloat = 0 {
        didSet { delegate?.pinchZoomView(self, didChangeScale: scale) }
    }
    
    private(set) var anchor: UnitPoint = .center {
        didSet { delegate?.pinchZoomView(self, didChangeAnchor: anchor) }
    }
    
    private(set) var offset: CGSize = .zero {
        didSet { delegate?.pinchZoomView(self, didChangeOffset: offset) }
    }
    
    private(set) var isPinching: Bool = false {
        didSet { delegate?.pinchZoomView(self, didChangePinching: isPinching) }
    }
    
    weak var delegate: PinchZoomViewDelgate?
    
    // MARK: - Init
    
    init() {
        super.init(frame: .zero)
        
        let pinchGesture = UIPinchGestureRecognizer(target: self, action: #selector(pinch(gesture:)))
        pinchGesture.cancelsTouchesInView = false
        addGestureRecognizer(pinchGesture)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Methods
    
    @objc private func pinch(gesture: UIPinchGestureRecognizer) {
        switch gesture.state {
        case .began:
            isPinching = true
            startLocation = gesture.location(in: self)
            anchor = UnitPoint(x: startLocation.x / bounds.width, y: startLocation.y / bounds.height)
            numberOfTouches = gesture.numberOfTouches
            
        case .changed:
            if gesture.numberOfTouches != numberOfTouches {
                let newLocation = gesture.location(in: self)
                let jumpDifference = CGSize(width: newLocation.x - location.x, height: newLocation.y - location.y)
                startLocation = CGPoint(x: startLocation.x + jumpDifference.width, y: startLocation.y + jumpDifference.height)
                
                numberOfTouches = gesture.numberOfTouches
            }
            
            scale = gesture.scale
            location = gesture.location(in: self)
            offset = CGSize(width: location.x - startLocation.x, height: location.y - startLocation.y)
        case .ended, .cancelled, .failed:
            withAnimation(.interactiveSpring()) {
                isPinching = false
                scale = 1.0
                anchor = .center
                offset = .zero
            }
        default:
            break
        }
    }
}

// MARK: - View+PinchZoom

private extension View {
    
    func pinchToZoom() -> some View {
        self.modifier(PinchToZoom())
    }
}

// MARK: - ViewModifier+PinchToZoom

private struct PinchToZoom: ViewModifier {
    
    // MARK: - Properties
    
    @State var scale: CGFloat = 1.0
    @State var anchor: UnitPoint = .center
    @State var offset: CGSize = .zero
    @State var isPinching: Bool = false
    
    // MARK: - Methods
    
    func body(content: Content) -> some View {
        content
            .scaleEffect(scale, anchor: anchor)
            .offset(offset)
            .overlay(PinchZoom(scale: $scale, anchor: $anchor, offset: $offset, isPinching: $isPinching))
    }
}

// MARK: - UIViewRepresentable+PinchZoom

private struct PinchZoom: UIViewRepresentable {
    
    // MARK: - Properties
    
    @Binding var scale: CGFloat
    @Binding var anchor: UnitPoint
    @Binding var offset: CGSize
    @Binding var isPinching: Bool
    
    // MARK: - Methods
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    func makeUIView(context: Context) -> PinchZoomView {
        let pinchZoomView = PinchZoomView()
        pinchZoomView.delegate = context.coordinator
        return pinchZoomView
    }
    
    func updateUIView(_ pageControl: PinchZoomView, context: Context) { }
    
    // MARK: - Coordinator
    
    class Coordinator: NSObject, PinchZoomViewDelgate {
        
        // MARK: - Properties
        
        var pinchZoom: PinchZoom
        
        init(_ pinchZoom: PinchZoom) {
            self.pinchZoom = pinchZoom
        }
        
        // MARK: - Methods
        
        func pinchZoomView(_ pinchZoomView: PinchZoomView, didChangePinching isPinching: Bool) {
            pinchZoom.isPinching = isPinching
        }
        
        func pinchZoomView(_ pinchZoomView: PinchZoomView, didChangeScale scale: CGFloat) {
            pinchZoom.scale = scale
        }
        
        func pinchZoomView(_ pinchZoomView: PinchZoomView, didChangeAnchor anchor: UnitPoint) {
            pinchZoom.anchor = anchor
        }
        
        func pinchZoomView(_ pinchZoomView: PinchZoomView, didChangeOffset offset: CGSize) {
            pinchZoom.offset = offset
        }
    }
}
