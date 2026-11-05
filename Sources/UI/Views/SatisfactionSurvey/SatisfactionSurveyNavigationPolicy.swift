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

struct SatisfactionSurveyNavigationPolicy {

    // MARK: - Types

    enum Decision: Equatable {
        case allow
        case cancel(Reason)
    }

    enum Reason: Equatable {
        case insecureScheme
        case invalidURL
        case newWindow
        case outsideSurveyOrigin
        case unsupportedScheme
    }

    // MARK: - Properties

    static let insecureResourceRuleList = """
    [
      {
        "trigger": {
          "url-filter": "^http://"
        },
        "action": {
          "type": "block"
        }
      },
      {
        "trigger": {
          "url-filter": "^ws://"
        },
        "action": {
          "type": "block"
        }
      }
    ]
    """

    private let surveyOrigin: Origin

    var allowsMediaCapture: Bool { false }

    // MARK: - Init

    init?(surveyURL: URL) {
        guard let surveyOrigin = Origin(url: surveyURL), surveyOrigin.scheme == "https" else {
            return nil
        }

        self.surveyOrigin = surveyOrigin
    }

    // MARK: - Methods

    func decision(for url: URL?, isMainFrame: Bool, opensNewWindow: Bool) -> Decision {
        guard !opensNewWindow else {
            return .cancel(.newWindow)
        }
        guard let url, let scheme = url.scheme?.lowercased() else {
            return .cancel(.invalidURL)
        }
        guard scheme != "http", scheme != "ws" else {
            return .cancel(.insecureScheme)
        }
        guard scheme == "https" else {
            return .cancel(.unsupportedScheme)
        }
        guard let destinationOrigin = Origin(url: url) else {
            return .cancel(.invalidURL)
        }
        guard !isMainFrame || destinationOrigin == surveyOrigin else {
            return .cancel(.outsideSurveyOrigin)
        }

        return .allow
    }
}

// MARK: - Helpers

private extension SatisfactionSurveyNavigationPolicy {

    struct Origin: Equatable {
        let scheme: String
        let host: String
        let port: Int

        init?(url: URL) {
            guard let scheme = url.scheme?.lowercased(),
                  let host = url.host?.lowercased() else {
                return nil
            }

            self.scheme = scheme
            self.host = host
            self.port = url.port ?? Self.defaultPort(for: scheme)
        }

        private static func defaultPort(for scheme: String) -> Int {
            switch scheme {
            case "https":
                return 443
            case "http":
                return 80
            default:
                return -1
            }
        }
    }
}
