//
//  EmojiPickerViewModel.swift
//  EmojiPickerUI
//
//  Created by Guilherme Rambo on 25/05/20.
//  Copyright © 2020 Guilherme Rambo. All rights reserved.
//

import Foundation
import Combine

final class EmojiPickerViewModel: ObservableObject {

    @Published var searchTerm: String?
    @Published var filteredEmoji: [Emoji]?

    var categories: [String] { database.categories }
    func allEmoji(in category: String) -> [Emoji] { database.allEmoji(in: category) }

    private var cancellables: [Cancellable] = []

    let database: EmojiDatabase

    init(database: EmojiDatabase) {
        self.database = database

        let searchTermBinding = $searchTerm.sink { [unowned self] term in
            guard let term = term, !term.isEmpty else {
                self.filteredEmoji = nil
                return
            }

            self.filteredEmoji = self.database.emoji(matching: term)
        }

        cancellables.append(searchTermBinding)
    }

}
