//
//  BuiltinEmojiDatabase.swift
//  EmojiPickerUI
//
//  Created by Guilherme Rambo on 26/05/20.
//  Copyright © 2020 Guilherme Rambo. All rights reserved.
//

import Foundation

/// Provided as a sample emoji database, not meant to be used in production.
/// emoji.csv taken from https://www.kaggle.com/eliasdabbas/emoji-data-descriptions-codepoints/data
final class BuiltinEmojiDatabase: EmojiDatabase {

    var categories: [String] { Array(groups) }

    func allEmoji(in category: String) -> [Emoji] {
        return categoryToEmojiMap[category] ?? []
    }

    func emoji(matching searchTerm: String) -> [Emoji] {
        emojiData.filter({ $0.metadata.lowercased().contains(searchTerm.lowercased()) })
    }

    private let url: URL

    init(url: URL) {
        self.url = url

        readDatabase()
    }

    private var emojiData: [Emoji] = []
    private var categoryToEmojiMap: [String: [Emoji]] = [:]

    private var groups = Set<String>()

    private func readDatabase() {
        do {
            let data = try Data(contentsOf: url)
            let contents = String(decoding: data, as: UTF8.self)

            // NOTE: This parsing is not great, but good enough for what we're doing here.
            contents.components(separatedBy: "\n").forEach { line in
                processDatabaseLine(line.components(separatedBy: ","))
            }
        } catch {
            fatalError("Giving up: \(error)")
        }
    }

    private func processDatabaseLine(_ item: [String]) {
        guard item.count > 2 else { return }

        var emoji = Emoji(string: item[0], skinToneVariants: [])
        emoji.metadata = item[1]

        let category = item[2]

        if categoryToEmojiMap[category] != nil {
            categoryToEmojiMap[category]?.append(emoji)
        } else {
            categoryToEmojiMap[category] = [emoji]
        }

        groups.insert(category)
        emojiData.append(emoji)
    }

}
