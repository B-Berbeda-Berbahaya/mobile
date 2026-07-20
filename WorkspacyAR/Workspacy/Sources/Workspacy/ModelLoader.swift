//
//  ModelLoader.swift
//  Workspacy
//
//  Created by Mochammad Athar Humam Ghazanfar on 17/07/26.
//

//import RealityKit
//
//public enum ModelLoader {
//
//    public static func load(named name: String) async throws -> Entity {
//        try await Entity(named: name, in: .module)
//    }
//}


import RealityKit

public enum ModelLoader {

    public static func load(named name: String) async throws -> Entity {
        do {
            let entity = try await Entity(named: name, in: .module)
            print("✅ Loaded \(name)")
            return entity
        } catch {
            print("❌ Failed to load \(name)")
            print(error)
            throw error
        }
    }
}
