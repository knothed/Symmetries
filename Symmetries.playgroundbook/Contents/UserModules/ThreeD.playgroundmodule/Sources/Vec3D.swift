import simd

public typealias Vec3D = simd_double3

/// `VecRef` contains a `Vec3D`. It is used both for performance and for identification reasons when two objects reference the same point.
public class VecRef: Hashable {
    public var value: Vec3D

    /// Default initializer.
    public init(_ value: Vec3D) {
        self.value = value
    }

    public func hash(into hasher: inout Hasher) {
        ObjectIdentifier(self).hash(into: &hasher)
    }

    public static func == (lhs: VecRef, rhs: VecRef) -> Bool {
        lhs === rhs
    }

    /// Rotate `self` by the given rotation.
    public func rotate(by rotation: Rotation) {
        value = rotation.apply(to: value)
    }
}

public extension Vec3D {
    /// Wrap `self` into a `VecRef`
    var ref: VecRef {
        VecRef(self)
    }
}

/// A line segment, consisting of two `VecRef`s.
public class Edge {
    public var vec1: VecRef
    public var vec2: VecRef

    /// Default initializer.
    public init(_ vec1: VecRef, _ vec2: VecRef) {
        self.vec1 = vec1
        self.vec2 = vec2
    }

    /// Determine whether `vec` is one of this edge's vertices.
    public func contains(_ vec: VecRef) -> Bool {
        vec == vec1 || vec == vec2
    }
}

extension Edge: Hashable {
    public func hash(into hasher: inout Hasher) {
        ObjectIdentifier(self).hash(into: &hasher)
    }
    
    public static func == (lhs: Edge, rhs: Edge) -> Bool {
        lhs === rhs
    }
}
