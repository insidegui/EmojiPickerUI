//
//  EmojiDatabase.swift
//  EmojiPickerUI
//
//  Created by Guilherme Rambo on 26/05/20.
//  Copyright © 2020 Guilherme Rambo. All rights reserved.
//

import Foundation

public protocol EmojiDatabase: AnyObject {
    var categories: [String] { get }
    func allEmoji(in category: String) -> [Emoji]
    func emoji(matching searchTerm: String) -> [Emoji]
}
