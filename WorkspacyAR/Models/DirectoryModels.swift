//
//  Directory.swift
//  WorkspacyAR
//
//  Created by Mochammad Athar Humam Ghazanfar on 14/07/26.
//

import Foundation

import Foundation

struct DeskItem: Identifiable, Hashable {
    var id: String { objectType.id }
    let objectType: PlaceableObjectType
    
    var name: String { objectType.displayName }
    var systemImage: String { objectType.sfSymbol }
    var modelFileName: String { objectType.assetName }
}

struct DeskItemSection: Identifiable, Hashable {
    var id: String { title }
    let title: String
    let items: [DeskItem]
    
    static let catalog: [DeskItemSection] = {
        let grouped = Dictionary(grouping: PlaceableObjectType.allCases) { $0.category }
        return ItemCategory.allCases.compactMap { category in
            guard let types = grouped[category], !types.isEmpty else { return nil }
            return DeskItemSection(
                title: category.rawValue,
                items: types.map { DeskItem(objectType: $0) }
            )
        }
    }()
}
