//
//  Emoji.swift
//  EmojiPickerUI
//
//  Created by Guilherme Rambo on 26/05/20.
//  Copyright © 2020 Guilherme Rambo. All rights reserved.
//

import Foundation

public struct Emoji: Hashable, Codable {

    public let string: String
    public var skinToneVariants: [Emoji]
    public var metadata: String = ""

    public init(string: String, skinToneVariants: [Emoji] = []) {
        self.string = string
        self.skinToneVariants = skinToneVariants
    }

}
