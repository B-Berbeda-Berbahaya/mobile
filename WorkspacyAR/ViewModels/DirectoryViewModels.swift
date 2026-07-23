//
//  Directory.swift
//  WorkspacyAR
//
//  Created by Mochammad Athar Humam Ghazanfar on 14/07/26.
//

import Foundation

@Observable
final class DirectoryViewModel {
    var sections: [DeskItemSection] = DeskItemSection.catalog
    var searchText = ""
    var selectedItem: DeskItem?

    var filteredSections: [DeskItemSection] {
        guard !searchText.isEmpty else { return sections }
        return sections.compactMap { section in
            let matches = section.items.filter { $0.name.localizedCaseInsensitiveContains(searchText) }
            return matches.isEmpty ? nil : DeskItemSection(title: section.title, items: matches)
        }
    }

    func select(_ item: DeskItem) {
        selectedItem = item
    }
}
