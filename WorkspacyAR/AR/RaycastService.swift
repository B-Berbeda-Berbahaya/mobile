import ARKit
import RealityKit

public struct RaycastService {
    public init() {}
    
    public func raycastWorldPosition(from screenPoint: CGPoint, in arView: ARView) -> SIMD3<Float>? {
        let results = arView.raycast(from: screenPoint, allowing: .estimatedPlane, alignment: .horizontal)
        
        guard let firstResult = results.first else {
            return nil
        }
        
        let transform = firstResult.worldTransform
        return SIMD3<Float>(transform.columns.3.x, transform.columns.3.y, transform.columns.3.z)
    }
}
