import Foundation
import ThreeD

/// An Octahedron, centered at the origin.
public class Octahedron: PlatonicSolid {
    public let quad1LeftRotation: Rotation
    public let quad1RightRotation: Rotation
    public let quad1HorizMirror: Rotation
    public let quad1VertMirror: Rotation
    public let quad2Rotation: Rotation
    public let quad2Mirror: Rotation
    public let quad3Rotation: Rotation
    public let quad3Mirror: Rotation

    /// Default initializer.
    public init(sideLength a: Double, style: Style, text: Bool = false) {
        let b = a / sqrt(2)
        let p1 = Vec3D(0, 0, b).ref
        let p2 = Vec3D(0, -b, 0).ref
        let p3 = Vec3D(-b, 0, 0).ref
        let p4 = Vec3D(0, b, 0).ref
        let p5 = Vec3D(b, 0, 0).ref
        let p6 = Vec3D(0, 0, -b).ref
        let vertices = [p1, p2, p3, p4, p5, p6]

        let (edges, faces, center) = Self.edgesAndFaces(for: [
            [p1, p2, p3],
            [p1, p3, p4],
            [p1, p4, p5],
            [p1, p2, p5],
            [p6, p2, p3],
            [p6, p3, p4],
            [p6, p4, p5],
            [p6, p2, p5]
        ])

        quad1LeftRotation = Rotation(axis: Vec3D(0, 0, 1), angle: .pi / 2)
        quad1RightRotation = Rotation(axis: Vec3D(0, 0, 1), angle: -.pi / 2)
        quad1HorizMirror = Rotation(axis: Vec3D(1, 1, 0), angle: -.pi)
        quad1VertMirror = Rotation(axis: Vec3D(1, -1, 0), angle: -.pi)
        quad2Rotation = Rotation(axis: Vec3D(0, 1, 0), angle: .pi / 2)
        quad2Mirror = Rotation(axis: Vec3D(1, 0, 1), angle: .pi)
        quad3Rotation = Rotation(axis: Vec3D(1, 0, 0), angle: .pi / 2)
        quad3Mirror = Rotation(axis: Vec3D(0, 1, -1), angle: .pi)

        super.init(vertices: vertices, edges: edges, faces: faces, style: style, center: center, text: text)
    }
}
