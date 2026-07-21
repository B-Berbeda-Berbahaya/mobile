import Foundation
import simd

public struct Triangulator {
    public static func triangulate(points: [SIMD3<Float>]) -> [UInt32] {
        guard points.count >= 3 else { return [] }
        
        let vertices = points.map { SIMD2<Float>($0.x, $0.z) }
        var indices = Array(0..<vertices.count)
        var triangles: [UInt32] = []
        
        // Hitung signed area untuk mencari arah putaran (Winding Order)
        var area: Float = 0
        for i in 0..<vertices.count {
            let p1 = vertices[i]
            let p2 = vertices[(i + 1) % vertices.count]
            area += (p1.x * p2.y) - (p2.x * p1.y)
        }
        
        let isCCW = area > 0
        
        var loops = 0
        let maxLoops = indices.count * 10
        
        while indices.count > 3 && loops < maxLoops {
            loops += 1
            var earFound = false
            
            for i in 0..<indices.count {
                let prevIdx = indices[(i - 1 + indices.count) % indices.count]
                let currIdx = indices[i]
                let nextIdx = indices[(i + 1) % indices.count]
                
                let a = vertices[prevIdx]
                let b = vertices[currIdx]
                let c = vertices[nextIdx]
                
                if isEar(a: a, b: b, c: c, polygon: vertices, indices: indices, currentIndices: [prevIdx, currIdx, nextIdx], isCCW: isCCW) {
                    if isCCW {
                        triangles.append(UInt32(prevIdx))
                        triangles.append(UInt32(currIdx))
                        triangles.append(UInt32(nextIdx))
                    } else {
                        triangles.append(UInt32(nextIdx))
                        triangles.append(UInt32(currIdx))
                        triangles.append(UInt32(prevIdx))
                    }
                    indices.remove(at: i)
                    earFound = true
                    break
                }
            }
            
            if !earFound {
                break
            }
        }
        
        // Sisa 3 vertex terakhir
        if indices.count == 3 {
            if isCCW {
                triangles.append(UInt32(indices[0]))
                triangles.append(UInt32(indices[1]))
                triangles.append(UInt32(indices[2]))
            } else {
                triangles.append(UInt32(indices[2]))
                triangles.append(UInt32(indices[1]))
                triangles.append(UInt32(indices[0]))
            }
        } else {
            // Fallback Triangle Fan jika macet (terjadi jika polygon self-intersecting)
            for i in 1..<(indices.count - 1) {
                if isCCW {
                    triangles.append(UInt32(indices[0]))
                    triangles.append(UInt32(indices[i]))
                    triangles.append(UInt32(indices[i + 1]))
                } else {
                    triangles.append(UInt32(indices[i + 1]))
                    triangles.append(UInt32(indices[i]))
                    triangles.append(UInt32(indices[0]))
                }
            }
        }
        
        return triangles
    }
    
    private static func isEar(a: SIMD2<Float>, b: SIMD2<Float>, c: SIMD2<Float>, polygon: [SIMD2<Float>], indices: [Int], currentIndices: [Int], isCCW: Bool) -> Bool {
        let cross = (b.x - a.x) * (c.y - a.y) - (b.y - a.y) * (c.x - a.x)
        if isCCW {
            if cross <= 0 { return false } // Concave
        } else {
            if cross >= 0 { return false } // Concave
        }
        
        for idx in indices {
            if currentIndices.contains(idx) { continue }
            let p = polygon[idx]
            if isPointInTriangle(p: p, a: a, b: b, c: c) {
                return false // Ada titik lain di dalam segitiga
            }
        }
        
        return true
    }
    
    private static func isPointInTriangle(p: SIMD2<Float>, a: SIMD2<Float>, b: SIMD2<Float>, c: SIMD2<Float>) -> Bool {
        let s1 = (c.x - b.x) * (p.y - b.y) - (c.y - b.y) * (p.x - b.x)
        let s2 = (a.x - c.x) * (p.y - c.y) - (a.y - c.y) * (p.x - c.x)
        let s3 = (b.x - a.x) * (p.y - a.y) - (b.y - a.y) * (p.x - a.x)
        
        let hasNeg = (s1 < 0) || (s2 < 0) || (s3 < 0)
        let hasPos = (s1 > 0) || (s2 > 0) || (s3 > 0)
        
        return !(hasNeg && hasPos)
    }
}
