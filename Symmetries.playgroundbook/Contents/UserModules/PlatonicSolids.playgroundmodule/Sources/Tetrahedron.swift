import Foundation
import simd
import ThreeD
import UIKit

/// A Tetrahedron, centered at the origin.
public class Tetrahedron: PlatonicSolid {
    /// Default initializer.
    public init(sideLength s: Double, style: Style) {
        let r_o = sqrt(6.0) / 4.0 * s // Outer sphere radius
        let r_i = sqrt(6.0) / 12.0 * s // Inner sphere radius
        let up = Vec3D(0, 0, 1)
        let p1 = VecRef(up * r_o)

        // Points on the lower triangle
        let bottomTriangleCenter = -up * r_i
        let d = sqrt(r_o * r_o - r_i * r_i)
        let vec = Vec3D(0, d, 0)
        let rot120 = simd_quatd(angle: 2 * .pi / 3, axis: up)
        let p2 = VecRef(bottomTriangleCenter + vec)
        let p3 = VecRef(bottomTriangleCenter + rot120.act(vec))
        let p4 = VecRef(bottomTriangleCenter + rot120.inverse.act(vec))
        let vertices = [p1, p2, p3, p4]

        let (edges, faces, center) = Self.edgesAndFaces(for: [
            [p1, p2, p3],
            [p1, p2, p4],
            [p1, p3, p4],
            [p2, p3, p4],
        ])

        super.init(vertices: vertices, edges: edges, faces: faces, style: style, center: center)
    }
}
