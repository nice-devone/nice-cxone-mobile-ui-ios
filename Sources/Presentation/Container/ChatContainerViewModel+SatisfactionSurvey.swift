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

// MARK: - Satisfaction Survey

extension ChatContainerViewModel {

    /// - Returns: `false` if a teardown ended the presentation before the survey reached the screen, or (multithread)
    ///   the survey's thread was left while it waited and the survey is held again; `true` once it is installed
    ///   (or was already being shown).
    @MainActor
    @discardableResult
    func showSatisfactionSurvey(_ survey: SatisfactionSurvey, file: StaticString = #file, line: UInt = #line) async -> Bool {
        guard activateSatisfactionSurvey(survey, file: file, line: line) else {
            return true
        }

        return await presentActivatedSatisfactionSurvey(survey, file: file, line: line)
    }

    /// The synchronous first step of `showSatisfactionSurvey(_:)`: marks `survey` as the active one, so everything
    /// gated on `isSatisfactionSurveyActive` sees it at once - before any of the presentation's waits.
    ///
    /// - Returns: `false` if `survey` is already being shown, and there is nothing left to present.
    @MainActor
    func activateSatisfactionSurvey(_ survey: SatisfactionSurvey, file: StaticString = #file, line: UInt = #line) -> Bool {
        // The SDK never re-emits a delivered survey, so this only guards against something re-driving
        // the same proactive event on the UI side (e.g. a duplicate broadcast) while it's already showing.
        guard !isSatisfactionSurveyActive || activeSatisfactionSurvey != survey else {
            LogManager.trace("Satisfaction survey is already being shown, ignoring duplicate", file: file, line: line)
            return false
        }

        LogManager.trace("Showing satisfaction survey overlay", file: file, line: line)

        isSatisfactionSurveyActive = true
        activeSatisfactionSurvey = survey
        lastActivatedSatisfactionSurvey = survey
        // Release a survey already in the slot so the hide below can replace it
        isSatisfactionSurveyOverlayInstalled = false
        // The survey takes over the overlay slot from any active inactivity popup; without
        // clearing this, its guard would reject every inactivity event for the rest of the session.
        releaseInactivityPopupOwnership()

        return true
    }

    /// The waiting second step of `showSatisfactionSurvey(_:)`, for a survey `activateSatisfactionSurvey(_:)` accepted.
    ///
    /// - Returns: The same as `showSatisfactionSurvey(_:)`.
    @MainActor
    @discardableResult
    func presentActivatedSatisfactionSurvey(_ survey: SatisfactionSurvey, file: StaticString = #file, line: UInt = #line) async -> Bool {
        // Each presentation runs in its own task, so another one can take over while this one waits - a newer survey
        // activated meanwhile, or a teardown followed by a fresh activation. Only the presentation that still owns the
        // survey may continue; a stale one must neither install its survey nor hold the newer one.
        let teardownGeneration = satisfactionSurveyTeardownGeneration
        let isStillPresenting = { [self] in
            isSatisfactionSurveyActive
                && activeSatisfactionSurvey == survey
                && satisfactionSurveyTeardownGeneration == teardownGeneration
        }

        // The survey is a system `.sheet`, and UIKit presents only one sheet per presenter - a link sheet
        // still open would silently drop it while the flag above blocks the rest of the flow. Wait for its
        // dismissal like `Overlayable` does. Form sheets are not closed here (their callers await the
        // form's own finish/cancel); the survey presentation waits for `sheet` to clear instead.
        if safariURL != nil {
            safariURL = nil

            await Task.sleep(seconds: 0.5)
        }

        // A form sheet (pre-chat / transcript) presents the shared overlay slot in its own full-screen cover, so installing
        // the survey now would show it inside that form - and a held survey would count as shown before its own sheet
        // appeared. Wait until the form has closed and finished dismissing (a teardown ends the wait too).
        // Polled on the main actor rather than observed through a Combine pipeline, whose closures would run off it.
        while isStillPresenting(), sheet != nil || isSheetDismissing {
            await Task.sleep(seconds: 0.2)
        }

        guard isStillPresenting(), await !holdSatisfactionSurveyIfItsThreadWasLeft(survey) else {
            return false
        }

        // Repeated because another presenter (e.g. a reconnect's loading overlay) can claim the slot while
        // the hide waits out its dismissal animation, and `showOverlay` would then silently refuse the survey.
        repeat {
            await hideOverlay(file: file, line: line)

            // The awaits above suspend for dismissal animations, during which a disconnect/
            // disappear path can run its own teardown and clear this flag - don't resurrect the survey
            // overlay on top of a session that already decided to tear it down while we were waiting.
            guard isStillPresenting() else {
                return false
            }
        } while overlay != nil

        guard await !holdSatisfactionSurveyIfItsThreadWasLeft(survey) else {
            return false
        }

        // `showOverlay` installs synchronously before its first suspension, so the slot is still free here
        isSatisfactionSurveyOverlayInstalled = true

        // Weak at the outer closure: it is stored in the overlay slot for as long as the survey is shown
        await showOverlay({ [weak self] in
            SatisfactionSurveyOverlayView(
                survey: survey,
                onClose: {
                    Task { @MainActor in
                        await self?.dismissSatisfactionSurvey()
                    }
                },
                onFailure: { error in
                    error.logError()
                },
                surveyContent: { onFailure in
                    SatisfactionSurveyWebView(url: survey.url, onFailure: onFailure)
                }
            )
        }, file: file, line: line)

        return true
    }

    /// Keeps `survey` until the customer opens its thread, and notifies them that it is waiting there.
    @MainActor
    func holdSatisfactionSurvey(_ survey: SatisfactionSurvey) async {
        reserveSatisfactionSurvey(survey)

        await notifyAboutHeldSatisfactionSurvey(survey)
    }

    /// The synchronous first step of `holdSatisfactionSurvey(_:)`: keeps `survey` for its thread.
    @MainActor
    func reserveSatisfactionSurvey(_ survey: SatisfactionSurvey) {
        LogManager.trace("Holding satisfaction survey until its thread is opened")

        pendingSatisfactionSurveys[survey.threadId] = survey
    }

    /// The waiting second step of `holdSatisfactionSurvey(_:)`: schedules the notification pointing to the survey's thread.
    @MainActor
    func notifyAboutHeldSatisfactionSurvey(_ survey: SatisfactionSurvey) async {
        await satisfactionSurveyNotificationScheduler.scheduleNotification(for: survey)

        // Scheduling can take a while (e.g. the first authorization prompt). If the customer opened the thread
        // meanwhile, the survey was shown and its notification removed before this one was added - remove it again.
        if pendingSatisfactionSurveys[survey.threadId] != survey {
            satisfactionSurveyNotificationScheduler.removeNotification(forThreadId: survey.threadId)
        }
    }

    /// Shows the survey held for `threadId`, if any - called once that thread's view has appeared,
    /// and again when another survey is dismissed while that thread is on screen.
    @MainActor
    func showPendingSatisfactionSurveyIfNeeded(for threadId: String?) async {
        guard let threadId, let survey = pendingSatisfactionSurveys[threadId] else {
            return
        }
        // Another thread's survey is still open - e.g. this thread was reached through its notification underneath
        // it. Showing this one would evict that survey for good, so it stays held until that one is dismissed.
        guard !isShowingOtherSatisfactionSurvey(than: survey) else {
            return
        }
        // A presentation of this survey is already in flight (e.g. the thread appeared again while it waits behind a
        // form) - it releases the hold itself once the survey is on screen, so releasing it here would come too early.
        guard !isSatisfactionSurveyActive || activeSatisfactionSurvey != survey else {
            return
        }

        // Kept held (with its notification) until it is actually on screen - a teardown during the presentation's
        // waits would otherwise drop a survey the SDK never re-emits.
        guard await showSatisfactionSurvey(survey) else {
            return
        }

        pendingSatisfactionSurveys[threadId] = nil

        // The customer reached the thread on their own, so the hint pointing there is no longer needed
        satisfactionSurveyNotificationScheduler.removeNotification(forThreadId: threadId)
    }

    /// `true` while a survey other than `survey` is on screen.
    func isShowingOtherSatisfactionSurvey(than survey: SatisfactionSurvey) -> Bool {
        isSatisfactionSurveyActive && activeSatisfactionSurvey != survey
    }

    @MainActor
    func dismissSatisfactionSurvey() async {
        // SwiftUI writes `false` back through the survey sheet's binding once a programmatic dismissal
        // finishes animating, which re-enters this method after the first call already installed End
        // Conversation - without this guard, the `hideOverlay()` below would tear that overlay down again.
        guard isSatisfactionSurveyActive else {
            LogManager.trace("No satisfaction survey is active, ignoring dismissal")
            return
        }

        let threadViewModel = cachedThreadViewModel

        isSatisfactionSurveyOverlayInstalled = false
        await hideOverlay()

        // A disconnect/disappear path may have already torn the survey down via
        // tearDownSatisfactionSurvey() while this await was suspended - if so, the flag is already
        // false and none of the recovery decisions below should run again on its behalf.
        guard isSatisfactionSurveyActive else {
            return
        }

        isSatisfactionSurveyActive = false

        if chatProvider.mode == .liveChat, threadViewModel?.thread?.state == .closed {
            threadViewModel?.clearDeferredClosedThreadRecovery()
            await threadViewModel?.restoreEndConversation()
            return
        } else if chatProvider.mode == .singlethread, threadViewModel?.thread?.state == .closed,
                  await threadViewModel?.recoverClosedThreadIfNeeded() == true {
            // The deferred ready-state flow took over - it either consumed the latch itself via
            // updateThread(), or it failed / was cancelled, and re-driving a load on top of that
            // would pile a spurious error (or a network call against a disconnected chat) on top
            // of whatever it just did.
            return
        }

        // Reached only when neither branch above took over: either the thread isn't closed, or it
        // is closed but was never actually deferred. Either way, clear a stale deferral latch before
        // it can be mistaken for a real one on some later dismissal, then drain `shouldRefreshThread`
        // the normal way - a `.loaded` update that arrived while the survey was active only latches
        // it rather than recovering immediately, and this is what re-drives it instead of waiting on
        // a thread update that may never come.
        threadViewModel?.clearStaleClosedThreadRecoveryDeferral()
        await threadViewModel?.recoverPendingRefreshIfNeeded()

        // Multithread: a survey held for the thread now on screen (reached underneath this one) can be shown now
        await showPendingSatisfactionSurveyIfNeeded(for: cachedListViewModel?.currentThread?.id)
    }

    /// Clears every piece of state a satisfaction survey being shown implies, for any path that removes
    /// the survey's overlay **without** going through `dismissSatisfactionSurvey()`'s deliberate recovery
    /// decision - view teardown, a new thread, and every disconnect path (backgrounding deliberately keeps
    /// the survey). Call this instead of setting `isSatisfactionSurveyActive = false` directly on those paths.
    ///
    /// Left set, `isSatisfactionSurveyActive == true` blocks thread recovery, End Conversation, and
    /// inactivity handling for the rest of the session (it gates `shouldRecover` in every `update*Thread`
    /// method). Left set, `cachedThreadViewModel`'s `didDeferClosedThreadRecovery` latch survives with no
    /// dismissal left to consume it, and gets mistaken for a real deferral by `recoverClosedThreadIfNeeded()`
    /// on some later, unrelated survey dismissal - destructively calling `createThread()` on an archived
    /// transcript the user never asked to replace.
    ///
    /// Deliberately not used by `dismissSatisfactionSurvey()` itself: that method's branches need to read
    /// the deferral latch *before* deciding whether to consume it, so clearing it unconditionally up front
    /// would defeat the actual recovery this method exists to skip.
    @MainActor
    func tearDownSatisfactionSurvey() {
        satisfactionSurveyTeardownGeneration += 1
        isSatisfactionSurveyActive = false
        cachedThreadViewModel?.clearStaleClosedThreadRecoveryDeferral()
    }
}

// MARK: - Private Methods

private extension ChatContainerViewModel {

    /// Holds the survey for its thread again if that thread is no longer the one on screen after the presentation's
    /// waits - a notification or deep link can switch threads meanwhile (multithread only).
    ///
    /// - Returns: `true` if the survey was held again and must not be installed.
    @MainActor
    func holdSatisfactionSurveyIfItsThreadWasLeft(_ survey: SatisfactionSurvey) async -> Bool {
        guard chatProvider.mode == .multithread,
              let listViewModel = cachedListViewModel,
              listViewModel.currentThread?.id != survey.threadId else {
            return false
        }

        LogManager.trace("Satisfaction survey's thread is no longer open, holding it again")

        isSatisfactionSurveyActive = false

        await holdSatisfactionSurvey(survey)

        return true
    }
}
