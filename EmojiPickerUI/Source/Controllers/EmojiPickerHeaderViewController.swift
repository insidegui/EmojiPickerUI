//
//  EmojiPickerHeaderViewController.swift
//  EmojiPickerUI
//
//  Created by Guilherme Rambo on 25/05/20.
//  Copyright © 2020 Guilherme Rambo. All rights reserved.
//

import UIKit

extension Notification.Name {
    static let emojiPickerDidResignSearchField = Notification.Name("codes.rambo.emojiPickerDidResignSearchField")
}

final class EmojiPickerHeaderViewController: UIViewController {

    var textDidChange: (String?) -> Void = { _ in }

    private(set) lazy var grabberView: UIView = {
        let v = UIView()

        v.backgroundColor = .separator
        v.heightAnchor.constraint(equalToConstant: 6).isActive = true
        v.widthAnchor.constraint(equalToConstant: 36).isActive = true
        v.layer.cornerRadius = 3
        v.translatesAutoresizingMaskIntoConstraints = false
        if #available(iOS 13.4, *) {
            v.addInteraction(UIPointerInteraction())
        }

        let pan = UIPanGestureRecognizer(target: self, action: #selector(drag(using:)))
        v.addGestureRecognizer(pan)
        
        return v
    }()

    private lazy var searchField: UISearchTextField = {
        let v = UISearchTextField()

        v.translatesAutoresizingMaskIntoConstraints = false
        v.delegate = self

        return v
    }()

    override func loadView() {
        view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(grabberView)
        view.addSubview(searchField)

        NSLayoutConstraint.activate([
            view.heightAnchor.constraint(equalToConstant: EmojiPickerMetrics.headerHeight),
            grabberView.topAnchor.constraint(equalTo: view.topAnchor, constant: 8),
            grabberView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            searchField.topAnchor.constraint(equalTo: grabberView.bottomAnchor, constant: 8),
            searchField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            searchField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
        ])

        searchField.addTarget(self, action: #selector(textChanged), for: .editingChanged)
    }

    @objc private func textChanged(_ field: UITextField) {
        textDidChange(field.text)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        view.window?.makeKey()

        perform(#selector(focusSearchField), with: nil, afterDelay: 0.1)
    }

    @objc private func focusSearchField() {
        _ = searchField.becomeFirstResponder()
    }

    @objc private func drag(using recognizer: UIPanGestureRecognizer) {
        guard let target = view.window as? DraggableTarget else { return }
        target.handleDrag(with: recognizer)
    }

}

extension EmojiPickerHeaderViewController: UITextFieldDelegate {

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        _ = textField.resignFirstResponder()

        NotificationCenter.default.post(name: .emojiPickerDidResignSearchField, object: textField)

        textDidChange(textField.text)

        return true
    }

}
