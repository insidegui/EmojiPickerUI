//
//  KeyCommandSwizzler.swift
//  EmojiPickerUI
//
//  Created by Guilherme Rambo on 26/05/20.
//  Copyright © 2020 Guilherme Rambo. All rights reserved.
//

import UIKit
import ObjectiveC

@objc extension UIKeyCommand {

    static func swizzleKeyCommandsForEmojiPicker() {
        guard let m1 = class_getInstanceMethod(UIResponder.self, #selector(getter: UIResponder.keyCommands)) else { return }
        guard let m2 = class_getInstanceMethod(Self.self, #selector(emojiPickerUI_keyCommands)) else { return }

        guard let originalImpl = class_getInstanceMethod(Self.self, #selector(originalKeyCommands)) else { return }

        class_addMethod(UIResponder.self, #selector(originalKeyCommands), method_getImplementation(originalImpl), method_getTypeEncoding(originalImpl)!)
        method_exchangeImplementations(m1, m2)
    }

    @objc func originalKeyCommands() -> [UIKeyCommand]? {
        // implementation added at runtime
        return nil
    }

    @objc func emojiPickerUI_keyCommands() -> [UIKeyCommand]? {
        guard isKind(of: UITextView.self) || isKind(of: UITextField.self) else { return originalKeyCommands() }

        let comm = UIKeyCommand(input: " ", modifierFlags: [.command, .control], action: #selector(UIResponder.showEmojiPicker))

        guard let original = originalKeyCommands() else {
            return [comm]
        }

        return original + [comm]
    }

}

extension UIResponder {

    @objc func showEmojiPicker() {
        guard let target = self as? (UIView & UITextInput) else { return }

        EmojiPickerManager.shared.show(for: target)
    }

}
