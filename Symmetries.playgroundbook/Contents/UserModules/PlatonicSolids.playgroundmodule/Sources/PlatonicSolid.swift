import ThreeD
import UIKit
import simd

/// A `PlatonicSolid` describes a platonic solid which is centered at the origin.
open class PlatonicSolid {
    public let vertices: [VecRef]
    public let nodes: [Node]
    public let faces: [Face]

    /// The solid's center. When moving the solid via `move`, this is updated accordingly.
    public let center: VecRef
    public var verticesAndCenter: [VecRef] { vertices + [center] }

    /// Style properties of a platonic solid.
    public let style: Style
    public struct Style {
        public let pointRadius: PointNode.Radius
        public let lineWidth: LineNode.Width
        public let color: UIColor

        public init(pointRadius: PointNode.Radius, lineWidth: LineNode.Width, color: UIColor) {
            self.pointRadius = pointRadius
            self.lineWidth = lineWidth
            self.color = color
        }
    }

    /// Default initializer.
    public init(vertices: [VecRef], edges: [Edge], faces: [Face], style: Style, center: VecRef, text: Bool = false) {
        self.faces = faces
        self.style = style
        self.center = center

        let pointNodes: [Node] = vertices.map {
            PointNode(position: $0, color: style.color, radius: style.pointRadius)
        }

        let edgeNodes: [Node] = edges.map {
            LineNode(edge: $0, color: style.color, width: style.lineWidth)
        }

        var textVecs = [VecRef]()
        var textNodes = [Node]()
        if text {
            textVecs = vertices.map { VecRef(1.15 * $0.value) }
            textNodes = textVecs.enumerated().map { i, vec in
                TextNode(position: vec, color: style.color, text: "\(i+1)", textSize: .fixed(25))
            }
        }

        self.vertices = vertices + textVecs
        nodes = pointNodes + edgeNodes + textNodes
    }

    /// Copy `other`.
    internal init(other: PlatonicSolid) {
        vertices = other.vertices
        nodes = other.nodes
        faces = other.faces
        style = other.style
        center = other.center
    }

    /// Create the dual platonic solid.
    public func dual(style: Style? = nil) -> PlatonicSolid {
        // Create vertices: centers of faces
        let dualVertices = Dictionary(faces.map { ($0, $0.center.ref) }) { a, b in a }

        // Create new faces, one per vertex
        let dualFaces: [[VecRef]] = vertices.map {
            let faces = neighbors(of: $0)
            return faces.map { dualVertices[$0]! }
        }

        let (edges, faces, center) = Self.edgesAndFaces(for: dualFaces)
        center.value = self.center.value

        let solid = PlatonicSolid(vertices: Array(dualVertices.values), edges: edges, faces: faces, style: style ?? self.style, center: center)
        return solid
    }

    /// Return all faces containing one vertex, sorted.
    private func neighbors(of vertex: VecRef) -> [Face] {
        var neighbors = faces.filter { $0.vertices.contains(vertex) }

        var sorted = [Face]()
        var current = neighbors.removeFirst()

        while true {
            sorted.append(current)

            if let next = neighbors.firstIndex(where: current.sharesEdge(with:)) {
                current = neighbors.remove(at: next)
            } else {
                return sorted
            }
        }
    }

    /// Add this platonic solid to a renderer.
    public func add(to renderer: Renderer) {
        nodes.forEach(renderer.add(node:))
        renderer.faces += faces
    }

    /// Remove this platonic solid from a renderer.
    public func remove(from renderer: Renderer) {
        nodes.forEach(renderer.remove(node:))
        renderer.faces.removeAll(where: faces.contains)
    }

    /// Move this object by a given vector.
    public func move(by vec: Vec3D) {
        for vertex in verticesAndCenter {
            vertex.value += vec
        }
    }

    /// The distance from the center to any of the vertices.
    public var radius: Double {
        simd_length(center.value - vertices[0].value)
    }

    /// Scale this object by a given factor.
    public func scale(by factor: Double) {
        for vertex in vertices {
            vertex.value = center.value + factor * (vertex.value - center.value)
        }
    }

    /// Create edges and faces from a point-face mapping. Also return the new center of the solid.
    /// Each element in the array corresponds to one face, consisting of an ordered array of points.
    internal static func edgesAndFaces(for faces: [[VecRef]]) -> ([Edge], [Face], VecRef) {
        let center = Vec3D.zero.ref
        var edges = [Edge]()

        // Create an edge or re-use one from the `edges` array
        func edge(_ vec1: VecRef, vec2: VecRef) -> Edge {
            if let edge = (edges.first { $0.contains(vec1) && $0.contains(vec2) }) {
                return edge
            }
            let edge = Edge(vec1, vec2)
            edges.append(edge)
            return edge
        }

        // Convert face array into actual Faces
        let faces: [Face] = faces.map { face -> Face in
            let pairs: [(VecRef, VecRef)] = Array(0 ..< face.count).map { (face[$0], face[($0 + 1) % face.count]) }
            let edges: [Edge] = pairs.map(edge)
            return Face(vertices: face, edges: edges) { $0.center - center.value }
        }

        return (edges, faces, center)
    }
}
