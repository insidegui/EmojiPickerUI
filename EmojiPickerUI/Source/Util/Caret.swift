//
//  Caret.swift
//  EmojiPickerUI
//
//  Created by Guilherme Rambo on 26/05/20.
//  Copyright © 2020 Guilherme Rambo. All rights reserved.
//

import UIKit

fileprivate let caretViewClass: AnyClass? = NSClassFromString("UITextSelectionView")

extension UITextInput where Self: UIView {

    func findCaret() -> UIView? {
        recursivelyLookForCaret(startingAt: self)
    }

    private func recursivelyLookForCaret(startingAt referenceView: UIView) -> UIView? {
        guard let cls = caretViewClass else { return nil }

        if referenceView.isKind(of: cls) { return referenceView }

        for subview in referenceView.subviews {
            if let caret = recursivelyLookForCaret(startingAt: subview) {
                return caret
            }
        }

        return nil
    }

}
