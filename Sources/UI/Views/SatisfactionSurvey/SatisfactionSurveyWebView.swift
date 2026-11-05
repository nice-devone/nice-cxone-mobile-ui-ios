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
import SwiftUI
import WebKit

struct SatisfactionSurveyWebView: UIViewRepresentable {

    // UIKit bridging is required because SwiftUI has no native WebView on iOS 16.

    // MARK: - Properties

    let url: URL
    let onFailure: (Error) -> Void

    // MARK: - Init

    init(url: URL, onFailure: @escaping (Error) -> Void) {
        self.url = url
        self.onFailure = onFailure
    }

    // MARK: - Methods

    func makeCoordinator() -> Coordinator {
        Coordinator(url: url, onFailure: onFailure)
    }

    func makeUIView(context: Context) -> WKWebView {
        let configuration = WKWebViewConfiguration()
        configuration.websiteDataStore = .default()

        let webView = WKWebView(frame: .zero, configuration: configuration)
        webView.navigationDelegate = context.coordinator
        webView.uiDelegate = context.coordinator
        context.coordinator.prepareAndLoad(webView)

        return webView
    }

    func updateUIView(_ webView: WKWebView, context: Context) { }
}

// MARK: - Coordinator

extension SatisfactionSurveyWebView {

    @MainActor
    final class Coordinator: NSObject {

        // MARK: - Properties

        private static let contentRuleListIdentifier = "com.nice.cxonechatui.satisfaction-survey.insecure-resources"

        private let url: URL
        private let navigationPolicy: SatisfactionSurveyNavigationPolicy?
        private let onFailure: (Error) -> Void

        private var didReportFailure = false

        // MARK: - Init

        init(url: URL, onFailure: @escaping (Error) -> Void) {
            self.url = url
            self.navigationPolicy = SatisfactionSurveyNavigationPolicy(surveyURL: url)
            self.onFailure = onFailure
        }

        // MARK: - Methods

        func prepareAndLoad(_ webView: WKWebView) {
            guard navigationPolicy != nil else {
                reportFailure(SatisfactionSurveyWebViewError.invalidSurveyURL)
                return
            }

            guard let store = WKContentRuleListStore.default() else {
                reportFailure(SatisfactionSurveyWebViewError.missingContentRuleListStore)
                return
            }
            store.lookUpContentRuleList(forIdentifier: Self.contentRuleListIdentifier) { [weak self, weak webView] ruleList, error in
                Task { @MainActor in
                    guard let self, let webView else {
                        return
                    }
                    if let ruleList {
                        self.install(ruleList, in: webView)
                    } else {
                        if error != nil {
                            LogManager.debug("Unable to reuse the satisfaction survey content rule list; compiling it again")
                        }
                        self.compileContentRuleList(in: store, for: webView)
                    }
                }
            }
        }
    }
}

// MARK: - WKNavigationDelegate

extension SatisfactionSurveyWebView.Coordinator: WKNavigationDelegate {

    func webView(
        _ webView: WKWebView,
        decidePolicyFor navigationAction: WKNavigationAction,
        decisionHandler: @escaping @MainActor @Sendable (WKNavigationActionPolicy) -> Void
    ) {
        let decision = navigationPolicy?.decision(
            for: navigationAction.request.url,
            isMainFrame: navigationAction.targetFrame?.isMainFrame ?? true,
            opensNewWindow: navigationAction.targetFrame == nil
        ) ?? .cancel(.invalidURL)

        handle(
            decision,
            isMainFrame: navigationAction.targetFrame?.isMainFrame ?? true,
            decisionHandler: decisionHandler
        )
    }

    func webView(
        _ webView: WKWebView,
        decidePolicyFor navigationResponse: WKNavigationResponse,
        decisionHandler: @escaping @MainActor @Sendable (WKNavigationResponsePolicy) -> Void
    ) {
        let decision = navigationPolicy?.decision(
            for: navigationResponse.response.url,
            isMainFrame: navigationResponse.isForMainFrame,
            opensNewWindow: false
        ) ?? .cancel(.invalidURL)

        switch decision {
        case .allow:
            decisionHandler(.allow)
        case .cancel(let reason):
            processBlockedNavigation(reason, isMainFrame: navigationResponse.isForMainFrame)
            decisionHandler(.cancel)
        }
    }

    func webView(_ webView: WKWebView, didFail navigation: WKNavigation?, withError error: Error) {
        reportNavigationFailure(error)
    }

    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation?, withError error: Error) {
        reportNavigationFailure(error)
    }
}

// MARK: - WKUIDelegate

extension SatisfactionSurveyWebView.Coordinator: WKUIDelegate {

    func webView(
        _ webView: WKWebView,
        createWebViewWith configuration: WKWebViewConfiguration,
        for navigationAction: WKNavigationAction,
        windowFeatures: WKWindowFeatures
    ) -> WKWebView? {
        logBlockedNavigation(.newWindow)
        return nil
    }

    func webView(
        _ webView: WKWebView,
        requestMediaCapturePermissionFor origin: WKSecurityOrigin,
        initiatedByFrame frame: WKFrameInfo,
        type: WKMediaCaptureType,
        decisionHandler: @escaping @MainActor @Sendable (WKPermissionDecision) -> Void
    ) {
        decisionHandler(navigationPolicy?.allowsMediaCapture == true ? .grant : .deny)
    }
}

// MARK: - Helpers

private extension SatisfactionSurveyWebView.Coordinator {

    func handle(
        _ decision: SatisfactionSurveyNavigationPolicy.Decision,
        isMainFrame: Bool,
        decisionHandler: @MainActor @Sendable (WKNavigationActionPolicy) -> Void
    ) {
        switch decision {
        case .allow:
            decisionHandler(.allow)
        case .cancel(let reason):
            processBlockedNavigation(reason, isMainFrame: isMainFrame)
            decisionHandler(.cancel)
        }
    }

    func processBlockedNavigation(_ reason: SatisfactionSurveyNavigationPolicy.Reason, isMainFrame: Bool) {
        logBlockedNavigation(reason)

        guard SatisfactionSurveyWebViewFailurePolicy.shouldReportBlockedNavigation(
            reason: reason,
            isMainFrame: isMainFrame
        ) else {
            return
        }

        reportFailure(SatisfactionSurveyWebViewError.blockedMainFrameNavigation)
    }

    func logBlockedNavigation(_ reason: SatisfactionSurveyNavigationPolicy.Reason) {
        LogManager.warning("Blocked satisfaction survey navigation: \(reason)")
    }

    func compileContentRuleList(in store: WKContentRuleListStore, for webView: WKWebView) {
        store.compileContentRuleList(
            forIdentifier: Self.contentRuleListIdentifier,
            encodedContentRuleList: SatisfactionSurveyNavigationPolicy.insecureResourceRuleList
        ) { [weak self, weak webView] ruleList, error in
            Task { @MainActor in
                guard let self, let webView else {
                    return
                }
                if let error {
                    self.reportFailure(error)
                    return
                }
                guard let ruleList else {
                    self.reportFailure(SatisfactionSurveyWebViewError.missingContentRuleList)
                    return
                }

                self.install(ruleList, in: webView)
            }
        }
    }

    func install(_ ruleList: WKContentRuleList, in webView: WKWebView) {
        webView.configuration.userContentController.add(ruleList)
        webView.load(URLRequest(url: url))
    }

    func reportFailure(_ error: Error) {
        guard !didReportFailure else {
            return
        }

        didReportFailure = true

        Task { @MainActor [onFailure] in
            onFailure(error)
        }
    }

    func reportNavigationFailure(_ error: Error) {
        guard !SatisfactionSurveyWebViewFailurePolicy.shouldIgnore(error) else {
            return
        }

        reportFailure(error)
    }
}

// MARK: - SatisfactionSurveyWebViewFailurePolicy

enum SatisfactionSurveyWebViewFailurePolicy {

    // MARK: - Properties

    private static let navigationPolicyCancellationErrorCode = 102

    // MARK: - Methods

    static func shouldIgnore(_ error: Error) -> Bool {
        let error = error as NSError

        return (error.domain == WKError.errorDomain
            && error.code == Self.navigationPolicyCancellationErrorCode)
            || (error.domain == NSURLErrorDomain && error.code == NSURLErrorCancelled)
    }

    static func shouldReportBlockedNavigation(
        reason: SatisfactionSurveyNavigationPolicy.Reason,
        isMainFrame: Bool
    ) -> Bool {
        guard isMainFrame else {
            return false
        }

        switch reason {
        case .insecureScheme, .outsideSurveyOrigin:
            return true
        case .invalidURL, .newWindow, .unsupportedScheme:
            // `about:`/`data:` and similar reach here (e.g. WebKit's normal main-frame `about:blank` setup) —
            // reporting them risks a spurious error state for something that isn't actually broken.
            return false
        }
    }
}

// MARK: - SatisfactionSurveyWebViewError

private enum SatisfactionSurveyWebViewError: Error {
    case blockedMainFrameNavigation
    case invalidSurveyURL
    case missingContentRuleList
    case missingContentRuleListStore
}
