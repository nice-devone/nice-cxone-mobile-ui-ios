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

import CXoneChatSDK
import SwiftUI

// MARK: - Proactive Actions

extension ChatContainerViewModel {

    func handleProactiveActionTypeReceived(_ type: ProactiveActionType) async {
        switch type {
        case .inactivityPopup(let entity):
            guard !isSatisfactionSurveyActive else {
                // The survey is one-shot and the popup is recurring, so the popup can simply wait
                // for the next inactivity window rather than evicting a survey that never comes back.
                LogManager.trace("Satisfaction survey is being shown, ignoring inactivity popup")
                return
            }
            guard let owner = cachedThreadViewModel, owner.isShowingInactivityPopup == false else {
                LogManager.trace("Inactivity popup is already being shown, ignoring new one")
                return
            }

            owner.isShowingInactivityPopup = true
            inactivityPopupOwner = owner

            await hideOverlay()
            await showInactivityPopup(popup: entity, owner: owner)
        case .satisfactionSurvey(let survey):
            LogManager.trace(
                "Satisfaction survey received for thread \(survey.threadId), open thread: \(cachedListViewModel?.currentThread?.id ?? "none")"
            )

            // In multithread a survey belongs with its own conversation: one for a thread the customer isn't viewing
            // (another thread, or the thread list) is held until they open that thread instead of covering this one.
            // It is also held while another thread's survey is open, which showing it would evict for good.
            //
            // Only the synchronous step runs here. The rest can wait on the customer - a notification permission prompt,
            // or a pre-chat/transcript form left open - and running it in this, the only event loop, would stall every
            // later event meanwhile while the SDK's bounded event buffer drops the oldest ones.
            if chatProvider.mode == .multithread,
               cachedListViewModel?.currentThread?.id != survey.threadId || isShowingOtherSatisfactionSurvey(than: survey) {
                reserveSatisfactionSurvey(survey)

                satisfactionSurveyTask = Task { @MainActor [weak self] in
                    await self?.notifyAboutHeldSatisfactionSurvey(survey)
                }
            } else if activateSatisfactionSurvey(survey) {
                satisfactionSurveyTask = Task { @MainActor [weak self] in
                    await self?.presentActivatedSatisfactionSurvey(survey)
                }
            }
        }
    }

    /// Clears the inactivity popup's ownership on every path that removes it from the overlay slot - including the popup's
    /// own owner, which after a thread switch is no longer `cachedThreadViewModel` - so a response still in flight can't
    /// later pass its ownership guard and hide an overlay installed since.
    func releaseInactivityPopupOwnership() {
        cachedThreadViewModel?.isShowingInactivityPopup = false
        inactivityPopupOwner?.isShowingInactivityPopup = false
        inactivityPopupOwner = nil
    }

    @MainActor
    func showInactivityPopup(popup: InactivityPopup, owner: ThreadViewModel, file: StaticString = #file, line: UInt = #line) async {
        LogManager.trace("Showing inactivity popup overlay with countdown: \(popup.numberOfSeconds) seconds", file: file, line: line)

        await showOverlay({ [weak self] in
            InactivityPopupView(
                title: popup.title,
                message: popup.message,
                startedAt: popup.startedAt,
                numberOfSeconds: popup.numberOfSeconds,
                refreshButtonText: popup.refreshButton.text,
                expireButtonText: popup.expireButton.text,
                onRefresh: { [owner] in
                    Task { @MainActor in
                        await self?.handleInactivityPopupResponse(refreshSession: true, popup: popup, owner: owner)
                    }
                },
                onExpire: { [owner] in
                    Task { @MainActor in
                        await self?.handleInactivityPopupResponse(refreshSession: false, popup: popup, owner: owner)
                    }
                },
                onTimeout: { [owner] in
                    Task { @MainActor in
                        // This popup instance timed out either way, but a satisfaction survey may
                        // have taken the overlay slot while the timer was running - don't tear that down.
                        owner.isShowingInactivityPopup = false

                        guard self?.isSatisfactionSurveyActive == false else {
                            return
                        }

                        await self?.hideOverlay()
                    }
                }
            )
        }, file: file, line: line)
    }
}

// MARK: - Private Methods

private extension ChatContainerViewModel {

    func handleInactivityPopupResponse(refreshSession: Bool, popup: InactivityPopup, owner: ThreadViewModel) async {
        LogManager.trace("Handling inactivity popup response: refreshSession = \(refreshSession)")

        do {
            if refreshSession {
                try await chatProvider.proactiveAction.trigger(.refreshSession(popup))
            } else {
                try await chatProvider.proactiveAction.trigger(.expireSession(popup))
            }

            // Only tear the overlay down if this popup instance still owns it - `showSatisfactionSurvey()` clears
            // this owner's flag when it takes the slot, and `didEnterBackground()` and `onDisappear()` clear the
            // current `cachedThreadViewModel`'s flag, so a continuation resuming after any of those (the request
            // was in flight through all of it) must not remove an overlay it no longer owns. Reading this before clearing it is what makes it work
            // as an ownership check rather than just a "we're done" flag. Checked against the popup's own
            // captured `owner`, not the live `cachedThreadViewModel` - that can be reassigned to a different
            // thread while this request was in flight, which would make the check race against the wrong instance.
            // `owner` is captured strongly (not weakly) by the popup's callbacks precisely so this check can
            // never see a deallocated owner - a thread switch or deeplink dropping the container's own weak
            // `cachedThreadViewModel` must not leave a tapped popup with nothing to hide it.
            guard owner.isShowingInactivityPopup else {
                return
            }

            owner.isShowingInactivityPopup = false

            // Backstop: a satisfaction survey may hold the overlay slot. `showSatisfactionSurvey()` clears this
            // popup's owner flag when it takes over, so the ownership guard above normally stops us first.
            // Same guard onTimeout has.
            guard !isSatisfactionSurveyActive else {
                return
            }

            await hideOverlay()
        } catch {
            error.logError()

            alertType = .genericError
        }
    }
}
