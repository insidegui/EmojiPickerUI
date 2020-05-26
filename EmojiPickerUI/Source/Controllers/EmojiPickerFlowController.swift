//
//  EmojiPickerFlowController.swift
//  EmojiPickerUI
//
//  Created by Guilherme Rambo on 25/05/20.
//  Copyright © 2020 Guilherme Rambo. All rights reserved.
//

import UIKit
import Combine

extension Notification.Name {
    static let FloatingEmojiPickerDidPickEmoji = Notification.Name("codes.rambo.EmojiPickerDidPickEmoji")
    static let FloatingEmojiPickerDidSnapshotSelectedEmoji = Notification.Name("codes.rambo.FloatingEmojiPickerDidSnapshotSelectedEmoji")
}

protocol EmojiPickerTransitionParticipant: AnyObject {
    func performEmojiPickerTransition()
}

final class EmojiPickerFlowController: UIViewController, EmojiPickerTransitionParticipant {

    private var cancellables: [Cancellable] = []

    let database: EmojiDatabase

    init(database: EmojiDatabase) {
        self.database = database

        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError()
    }

    override var keyCommands: [UIKeyCommand]? {
        [UIKeyCommand(input: UIKeyCommand.inputEscape, modifierFlags: [], action: #selector(close))]
    }

    @objc private func close() {
        EmojiPickerManager.shared.dismiss()
    }

    lazy var viewModel: EmojiPickerViewModel = {
        EmojiPickerViewModel(database: database)
    }()

    private lazy var headerController: EmojiPickerHeaderViewController = {
        let c = EmojiPickerHeaderViewController()

        c.textDidChange = { [weak self] term in
            self?.viewModel.searchTerm = term
        }
        
        return c
    }()

    private lazy var collectionController: EmojiCollectionViewController = {
        EmojiCollectionViewController(viewModel: viewModel)
    }()

    override func loadView() {
        view = UIView()
        view.backgroundColor = .systemBackground
        view.layer.cornerRadius = EmojiPickerMetrics.cornerRadius
        view.layer.cornerCurve = .continuous
        view.clipsToBounds = true

        addChild(collectionController)
        collectionController.view.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(collectionController.view)
        collectionController.didMove(toParent: self)

        addChild(headerController)
        view.addSubview(headerController.view)
        headerController.didMove(toParent: self)

        NSLayoutConstraint.activate([
            headerController.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            headerController.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            headerController.view.topAnchor.constraint(equalTo: view.topAnchor),
            collectionController.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionController.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionController.view.topAnchor.constraint(equalTo: headerController.view.bottomAnchor),
            collectionController.view.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])

        let filterBinding = viewModel.$filteredEmoji.sink { [weak self] _ in
            self?.collectionController.filteringChanged()
        }
        cancellables.append(filterBinding)

        headerController.view.alpha = 0
        collectionController.view.alpha = 0
    }

    func performEmojiPickerTransition() {
        headerController.view.alpha = 1
        collectionController.view.alpha = 1
    }

}
