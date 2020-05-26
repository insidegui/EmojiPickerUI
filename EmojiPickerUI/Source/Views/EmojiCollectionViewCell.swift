//
//  EmojiCollectionViewCell.swift
//  EmojiPickerUI
//
//  Created by Guilherme Rambo on 25/05/20.
//  Copyright © 2020 Guilherme Rambo. All rights reserved.
//

import UIKit

final class EmojiCollectionViewCell: UICollectionViewCell {

    var emoji: Emoji? {
        didSet {
            label.text = emoji?.string
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)

        setup()
    }

    required init?(coder: NSCoder) {
        fatalError()
    }

    private lazy var label: UILabel = {
        let l = UILabel()

        l.textAlignment = .center
        l.font = UIFont.systemFont(ofSize: 32)
        l.translatesAutoresizingMaskIntoConstraints = false

        return l
    }()

    private func setup() {
        contentView.addSubview(label)

        NSLayoutConstraint.activate([
            label.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            label.centerXAnchor.constraint(equalTo: contentView.centerXAnchor)
        ])
    }
    
}
