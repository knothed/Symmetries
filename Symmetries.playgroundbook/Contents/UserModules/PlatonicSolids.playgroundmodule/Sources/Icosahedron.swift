import simd
import ThreeD
import UIKit

/// An Icosahedron, centered at the origin.
public class Icosahedron: PlatonicSolid {
    /// Default initializer.
    public init(sideLength s: Double, style: Style) {
        let sin72 = sqrt(0.625 + sqrt(5.0) / 8)
        let cos72 = (sqrt(5.0) - 1) / 4
        let sin144 = sqrt(0.625 - sqrt(5.0) / 8)
        let cos144 = -(sqrt(5.0) + 1) / 4

        let r: Double = s * sqrt(10 + 2 * sqrt(5)) / 4 // outer sphere radius
        let p = s * sqrt(0.5 + 0.1 * sqrt(5)) // pentagon outer radius
        let h = r - 0.5 * s // height of pentagon

        // Lower point and pentagon
        let p1 = Vec3D(0, 0, -r).ref
        let p2 = Vec3D(0, -p, -h).ref
        let p3 = Vec3D(sin72 * p, -cos72 * p, -h).ref
        let p4 = Vec3D(sin144 * p, -cos144 * p, -h).ref
        let p5 = Vec3D(-sin144 * p, -cos144 * p, -h).ref
        let p6 = Vec3D(-sin72 * p, -cos72 * p, -h).ref

        // Upper point and hexagon
        let p7 = Vec3D(0, p, h).ref
        let p8 = Vec3D(-sin72 * p, cos72 * p, h).ref
        let p9 = Vec3D(-sin144 * p, cos144 * p, h).ref
        let p10 = Vec3D(sin144 * p, cos144 * p, h).ref
        let p11 = Vec3D(sin72 * p, cos72 * p, h).ref
        let p12 = Vec3D(0, 0, r).ref
        let vertices = [p1, p2, p3, p4, p5, p6, p7, p8, p9, p10, p11, p12]

        let (edges, faces, center) = Self.edgesAndFaces(for: [
            [p1, p2, p3],
            [p1, p3, p4],
            [p1, p4, p5],
            [p1, p5, p6],
            [p1, p2, p6],
            [p2, p9, p10],
            [p2, p3, p10],
            [p3, p10, p11],
            [p3, p4, p11],
            [p4, p7, p11],
            [p4, p5, p7],
            [p5, p7, p8],
            [p5, p6, p8],
            [p6, p8, p9],
            [p2, p6, p9],
            [p9, p10, p12],
            [p10, p11, p12],
            [p7, p11, p12],
            [p7, p8, p12],
            [p8, p9, p12]
        ])

        /* The following would produce a icosahedron standing on a face instead of a vertex.
        // Lower triangle (r1 = triangle outer radius, h = inner sphere radius)
        let p1 = Vec3D(r1, -h, 0).ref (r1: triangle radius)
        let p2 = Vec3D(-cos60 * r1, -h, +sin60 * r1).ref
        let p3 = Vec3D(-cos60 * r1, -h, -sin60 * r1).ref

        // Middle hexagon (r2 = hexagon outer radius)
        let p4 = Vec3D(r2, 0, 0).ref
        let p5 = Vec3D(cos60 * r2, 0, sin60 * r2).ref
        let p6 = Vec3D(-cos60 * r2, 0, sin60 * r2).ref
        let p7 = Vec3D(0, -r2, 0).ref
        let p8 = Vec3D(-cos60 * r2, 0, -sin60 * r2).ref
        let p9 = Vec3D(cos60 * r2, 0, -sin60 * r2).ref

        // Upper triangle
        let p10 = Vec3D(-r1, h, 0).ref
        let p11 = Vec3D(cos60 * r1, h, -sin60 * r1).ref
        let p12 = Vec3D(cos60 * r1, h, +sin60 * r1).ref
        let vertices = [p1, p2, p3, p4, p5, p6, p7, p8, p9, p10, p11, p12]

        let (edges, faces) = Self.edgesAndFaces(for: [
            [p1, p2, p3],
            [p1, p3, p9],
            [p1, p2, p5],
            [p2, p3, p7],
            [p1, p4, p9],
            [p1, p4, p5],
            [p2, p5, p6],
            [p2, p6, p7],
            [p3, p7, p8],
            [p3, p8, p9],
            [p4, p9, p11],
            [p4, p5, p12],
            [p5, p6, p12],
            [p6, p7, p10],
            [p7, p8, p10],
            [p8, p9, p11],
            [p4, p11, p12],
            [p6, p10, p12],
            [p8, p10, p11],
            [p10, p11, p12]
        ]) */

        super.init(vertices: vertices, edges: edges, faces: faces, style: style, center: center)
    }
}
