//
//  EmojiCollectionViewController.swift
//  EmojiPickerUI
//
//  Created by Guilherme Rambo on 25/05/20.
//  Copyright © 2020 Guilherme Rambo. All rights reserved.
//

import UIKit
import Combine

final class EmojiCollectionViewController: UICollectionViewController {

    private static func makeLayout() -> UICollectionViewFlowLayout {
        let l = UICollectionViewFlowLayout()

        l.itemSize = CGSize(width: 48, height: 48)
        l.scrollDirection = .horizontal
        l.minimumLineSpacing = 8
        l.minimumInteritemSpacing = 8
        l.sectionInset = UIEdgeInsets(top: 8, left: 0, bottom: 8, right: 16)

        return l
    }

    let viewModel: EmojiPickerViewModel

    private var filteredEmoji: [Emoji]? {
        didSet {
            guard filteredEmoji != oldValue else { return }

            collectionView?.reloadData()
        }
    }

    func filteringChanged() {
        filteredEmoji = viewModel.filteredEmoji
    }

    init(viewModel: EmojiPickerViewModel) {
        self.viewModel = viewModel

        super.init(collectionViewLayout: Self.makeLayout())
    }

    required init?(coder: NSCoder) {
        fatalError()
    }

    private static let cellIdentifier = "emojicell"

    override func viewDidLoad() {
        super.viewDidLoad()

        collectionView?.register(EmojiCollectionViewCell.self, forCellWithReuseIdentifier: Self.cellIdentifier)

        collectionView?.isOpaque = false
        collectionView?.backgroundColor = .clear
    }

    // MARK: UICollectionViewDataSource

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        if filteredEmoji != nil {
            return 1
        } else {
            return viewModel.categories.count
        }
    }

    private func emoji(at indexPath: IndexPath) -> Emoji {
        if let filteredEmoji = filteredEmoji {
            return filteredEmoji[indexPath.item]
        } else {
            return viewModel.allEmoji(in: viewModel.categories[indexPath.section])[indexPath.item]
        }
    }

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if let filteredEmoji = filteredEmoji {
            return filteredEmoji.count
        } else {
            return viewModel.allEmoji(in: viewModel.categories[section]).count
        }
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Self.cellIdentifier, for: indexPath) as! EmojiCollectionViewCell
    
        cell.emoji = emoji(at: indexPath)
    
        return cell
    }

    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let cell = collectionView.cellForItem(at: indexPath), let window = cell.window {
            postSnapshot(contentView: cell.contentView, cell: cell, window: window)
        }

        NotificationCenter.default.post(name: .FloatingEmojiPickerDidPickEmoji, object: emoji(at: indexPath).string)
    }

    private func postSnapshot(contentView: UIView, cell: UIView, window: UIWindow) {
        let renderer = UIGraphicsImageRenderer(bounds: contentView.bounds, format: .init(for: traitCollection))

        let image = renderer.image { ctx in
            contentView.layer.render(in: ctx.cgContext)
        }

        let frame = cell.convert(contentView.frame, to: window)
        let snap = EmojiSnapshot(image: image, frame: frame)

        NotificationCenter.default.post(name: .FloatingEmojiPickerDidSnapshotSelectedEmoji, object: snap)
    }

}

