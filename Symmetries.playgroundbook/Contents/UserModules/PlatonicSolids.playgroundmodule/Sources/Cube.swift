import ThreeD
import UIKit

/// A Cube, centered at the origin.
public class Cube: PlatonicSolid {
    /// Default initializer.
    public init(sideLength s: Double, style: Style) {
        let r = s / 2

        let p1 = Vec3D(+r, +r, +r).ref
        let p2 = Vec3D(+r, +r, -r).ref
        let p3 = Vec3D(+r, -r, -r).ref
        let p4 = Vec3D(+r, -r, +r).ref
        let p5 = Vec3D(-r, +r, +r).ref
        let p6 = Vec3D(-r, +r, -r).ref
        let p7 = Vec3D(-r, -r, -r).ref
        let p8 = Vec3D(-r, -r, +r).ref
        let vertices = [p1, p2, p3, p4, p5, p6, p7, p8]

        let (edges, faces, center) = Self.edgesAndFaces(for: [
            [p1, p2, p3, p4],
            [p5, p6, p7, p8],
            [p1, p2, p6, p5],
            [p3, p4, p8, p7],
            [p1, p4, p8, p5],
            [p2, p3, p7, p6]
        ])

        super.init(vertices: vertices, edges: edges, faces: faces, style: style, center: center)
    }
}
