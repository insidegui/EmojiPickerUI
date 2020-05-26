//
//  EmojiPickerManager.swift
//  EmojiPickerUI
//
//  Created by Guilherme Rambo on 25/05/20.
//  Copyright © 2020 Guilherme Rambo. All rights reserved.
//

import UIKit

struct EmojiPickerMetrics {
    static let headerHeight: CGFloat = 54
    static let windowSize = CGSize(width: 300, height: 352)
    static let cornerRadius: CGFloat = 16
    static let verticalMarginFromCaret: CGFloat = 48
    static let marginFromScreenEdges: CGFloat = 22
}

@objc(EPUIEmojiPickerManager)
@objcMembers public final class EmojiPickerManager: NSObject {

    public typealias TargetView = UIView & UITextInput

    public static let shared = EmojiPickerManager()

    public static func install() {
        UIKeyCommand.swizzleKeyCommandsForEmojiPicker()
    }

    private var window: EmojiPickerWindow?
    private weak var targetView: TargetView?

    public override init() {
        super.init()

        NotificationCenter.default.addObserver(self, selector: #selector(didPickEmoji), name: .FloatingEmojiPickerDidPickEmoji, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(didResignSearchField), name: .emojiPickerDidResignSearchField, object: nil)
    }

    public lazy var database: EmojiDatabase = {
        guard let url = Bundle(for: EmojiPickerViewModel.self).url(forResource: "emoji", withExtension: "csv") else {
            fatalError("Missing emoji.csv in EmojiPickerUI bundle")
        }
        return BuiltinEmojiDatabase(url: url)
    }()

    @objc(showForView:)
    public func show(for view: TargetView) {
        self.targetView = view

        guard let refWindow = view.window, let scene = refWindow.windowScene else { return }

        window = EmojiPickerWindow(windowScene: scene)

        window?.rootViewController = EmojiPickerFlowController(database: database)

        window?.animateIn(from: view)

        _ = targetView?.resignFirstResponder()
    }

    @objc private func didPickEmoji(_ note: Notification) {
        guard let str = note.object as? String else { return }

        guard let target = targetView else { return }

        window?.animateOut(into: target, insertEmoji: { [weak target] in
            target?.insertText(str)
        }, completion: { [weak self] in
            self?.focusInput()
        })
    }

    @objc private func didResignSearchField() {
        focusInput()
    }

    func dismiss() {
        window?.dismiss { [weak self] in
            self?.focusInput()
        }
    }

    private func focusInput() {
        _ = targetView?.becomeFirstResponder()
    }

}
