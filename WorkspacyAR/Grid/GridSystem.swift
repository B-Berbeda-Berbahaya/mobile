import Foundation
import simd
import Combine

public final class GridSystem: ObservableObject {
    @Published public private(set) var origin: SIMD3<Float>? = nil
    @Published public private(set) var cells: [GridCoordinate: GridCell] = [:]
    public let cellSize: Float
    
    public init(cellSize: Float = 0.1) { // 10cm grid cells
        self.cellSize = cellSize
    }
    
    public func setOriginIfNeeded(_ worldPosition: SIMD3<Float>) {
        if origin == nil {
            origin = worldPosition
        }
    }
    
    public func markAvailable(_ coordinate: GridCoordinate) {
        if case .occupied = cells[coordinate] {
            return
        }
        cells[coordinate] = .empty
    }
    
    public func markOccupied(_ coordinate: GridCoordinate, objectID: UUID) {
        cells[coordinate] = .occupied(objectID: objectID)
    }
    
    public func markAvailableAgain(_ coordinate: GridCoordinate) {
        cells[coordinate] = .empty
    }
    
    public func isAvailable(_ coordinate: GridCoordinate) -> Bool {
        return cells[coordinate] == .empty
    }
    
    public func clear() {
        cells.removeAll()
        origin = nil
    }
}
