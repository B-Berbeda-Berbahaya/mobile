//
//  Directory.swift
//  WorkspacyAR
//
//  Created by Mochammad Athar Humam Ghazanfar on 14/07/26.
//

import Foundation

struct DeskItem: Identifiable, Hashable, Codable {
    var id = UUID()
    let name: String
    let systemImage: String          // SF Symbol name, placeholder until real thumbnails exist
    var modelFileName: String? = nil // TODO: USDZ filename once assets exist

    static let example = DeskItem(name: "Monitor", systemImage: "display")
}

struct DeskItemSection: Identifiable, Hashable, Codable {
    var id = UUID()
    let title: String
    let items: [DeskItem]

    static let mockData: [DeskItemSection] = [
        DeskItemSection(title: "Monitor", items: [
            DeskItem(name: "27\" LED Monitor", systemImage: "display"),
            DeskItem(name: "Desktop Monitor", systemImage: "desktopcomputer"),
            DeskItem(name: "Portable Monitor", systemImage: "display")
        ]),
        DeskItemSection(title: "Flower Vase", items: [
            DeskItem(name: "Ceramic Vase", systemImage: "leaf"),
            DeskItem(name: "Glass Vase", systemImage: "leaf.fill"),
            DeskItem(name: "Small Pot", systemImage: "drop.fill")
        ]),
        DeskItemSection(title: "Pencil Case", items: [
            DeskItem(name: "Zip Pouch", systemImage: "pencil"),
            DeskItem(name: "Desk Organizer", systemImage: "tray.full.fill"),
            DeskItem(name: "Roll-Up Case", systemImage: "ruler.fill")
        ])
    ]
}

//DeskItemSection(title: "Monitor", items: [
//    DeskItem(name: "27\" LED Monitor", systemImage: "display", modelFileName: "monitor_led_27in.usdz"),
//    // same pattern for the rest — just add modelFileName to each existing item
//])
