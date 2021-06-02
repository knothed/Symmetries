import Foundation
import simd

/// A `Face` describes a polygon which lies planar in 3D space.
public class Face {
    /// The vertices, in sequential order.
    public let vertices: [VecRef]

    /// The edges, in sequential order.
    public let edges: [Edge]

    /// A normal vector to the plane containing this face.
    /// Always calculated on-demand (as the values inside `vertices` can change during a face's lifetime).
    public let normal: (Face) -> Vec3D

    /// The center, calculated as the average of all vertices.
    public var center: Vec3D {
        vertices.map(\.value).reduce(.zero, +) / Double(vertices.count)
    }

    /// Default initializer.
    public init(vertices: [VecRef], edges: [Edge], normal: @escaping (Face) -> Vec3D) {
        self.vertices = vertices
        self.edges = edges
        self.normal = normal
    }

    /// Project this face onto the renderer's layer. Also return the minimum distance to the face.
    internal func projectOntoLayer(using renderer: Renderer) -> (Face, Polygon, Double) {
        let distance = vertices.map { simd_distance(renderer.cameraPosition, $0.value) }.min()!
        let projectedVertices = vertices.map { renderer.projectOntoLayer(vec: $0).0 }
        return (self, Polygon(points: projectedVertices), distance)
    }

    /// Calculate the distance from the camera to the plane containing this face along the given direction.
    internal func distance(to camera: Vec3D, in direction: Vec3D) -> Double {
        // Find nadir of camera on plane
        let v = camera - vertices[0].value
        let unitN = simd_normalize(normal(self))
        let dist = simd_dot(v, unitN)
        let nadir = camera - dist * unitN

        // Calculate distance from camera to plane along `direction`
        let direction = simd_normalize(direction)
        let distToPlane = simd_distance(camera, nadir) / (simd_dot(direction, unitN))
        return abs(distToPlane)
    }


    /// Determines whether `self` shares at least one edge with `other`.
    public func sharesEdge(with other: Face) -> Bool {
        !Set(edges).intersection(other.edges).isEmpty
    }
}

extension Face: Hashable {
    public func hash(into hasher: inout Hasher) {
        ObjectIdentifier(self).hash(into: &hasher)
    }

    public static func == (lhs: Face, rhs: Face) -> Bool {
        lhs === rhs
    }
}
