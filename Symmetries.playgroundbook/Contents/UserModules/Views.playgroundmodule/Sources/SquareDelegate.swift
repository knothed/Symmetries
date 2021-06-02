import simd
import ThreeD
import UIKit

/// The dihedral group D4.
/// An element is of the form `σ^i` or `σ^i ◦ τ`, where σ is a clockwise rotation around 90° and τ is a reflection about the central vertical axis.
/// For example, `σ^2 ◦ τ` is a rotation about the central horizontal axis.
public struct D4 {
    let rots: Int // modulo 4: 0°, 90°, 180°, 270°
    let reflection: Bool

    public init(rots: Int, reflection: Bool) {
        self.rots = (rots % 4) < 0 ? (rots % 4 + 4) : rots % 4
        self.reflection = reflection
    }

    static func concat(a: D4, b: D4) -> D4 {
        let rots = a.reflection ? a.rots - b.rots : a.rots + b.rots
        let reflection = a.reflection != b.reflection
        return D4(rots: rots, reflection: reflection)
    }
}

/// A 3D rectangle, consisting of points and lines, and providing rotation and reflection operations.
public class Square {
    public let nodes: [Node]
    public let vecs: [VecRef]
    public var color: UIColor

    private let normal: Vec3D
    private let upAxis: Vec3D
    private let rightAxis: Vec3D

    /// Default initializer.
    public init(center: Vec3D, upAxis: Vec3D, rightAxis: Vec3D, size: Double, pointRadius: PointNode.Radius, lineWidth: LineNode.Width, color: UIColor = .black) {
        self.color = color
        self.upAxis = simd_normalize(upAxis)
        self.rightAxis = simd_normalize(rightAxis)
        normal = simd_cross(upAxis, rightAxis)

        // Create nodes
        let radius = size / 2
        let mul: (Double, Vec3D) -> Vec3D = { $0 * $1 } // Type-checking performance
        let corners: [VecRef] = [
            VecRef(center + mul(radius, upAxis) - mul(radius, rightAxis)),
            VecRef(center + mul(radius, upAxis) + mul(radius, rightAxis)),
            VecRef(center - mul(radius, upAxis) + mul(radius, rightAxis)),
            VecRef(center - mul(radius, upAxis) - mul(radius, rightAxis)),
        ]

        let points: [Node] = corners.map { a -> Node in
            PointNode(position: a, color: color, radius: pointRadius)
        }

        let edges: [Edge] = Array(0 ..< 4).map { Edge(corners[$0], corners[($0+1) % 4]) }
        let edgeNodes: [Node] = edges.map { a -> Node in
            LineNode(edge: a, color: color, width: lineWidth)
        }

        let textVecs = corners.map { VecRef(1.15 * $0.value) }
        let textNodes: [Node] = textVecs.enumerated().map { i, vec in
            TextNode(position: vec, color: color, text: "\(i+1)", textSize: .fixed(25))
        }

        nodes = points + edgeNodes + textNodes
        vecs = corners + textVecs
    }

    /// Return the rotation that is performed for a given symmetry.
    public func rotation(for d4: D4) -> Rotation {
        if d4.reflection {
            let axis = [upAxis, upAxis + rightAxis, rightAxis, upAxis - rightAxis][d4.rots]
            return Rotation(axis: axis, angle: .pi)
        } else {
            let angle = Double(d4.rots) * .pi / 2
            return Rotation(axis: normal, angle: angle > .pi ? angle - 2 * .pi : angle)
        }
    }
}

public class SquareDelegate: SymmetriesDelegate {
    public let square: Square
    public var renderer: Renderer!
    public var buttonColor: UIColor { square.color }

    private var isAnimating = false
    private var rotation = Rotation(axis: .one, angle: .zero)

    /// Default initializer.
    public init(square: Square) {
        self.square = square
    }

    /// All symmetries along with an image.
    private let actions: [(symmetry: D4, image: String)] = [
        (D4(rots: 0, reflection: false), "id"),
        (D4(rots: 1, reflection: false), "90-left"),
        (D4(rots: 2, reflection: false), "180"),
        (D4(rots: 3, reflection: false), "90-right"),
        (D4(rots: 2, reflection: true), "horiz"),
        (D4(rots: 0, reflection: true), "vert"),
        (D4(rots: 1, reflection: true), "mainDiag"),
        (D4(rots: 3, reflection: true), "antiDiag")
    ]

    public func image(for index: Int) -> UIImage {
        let name = actions[index].image
        return UIImage(named: name) ?? UIImage()
    }

    public func buttonTapped(index: Int) {
        guard !isAnimating else { return }
        isAnimating = true

        if index == 0 {
            return identityAnim()
        }

        // Rotate around symmetry axis
        let symmetry = actions[index].symmetry
        let duration = index == 2 ? 0.8 : 0.4
        let rot = square.rotation(for: symmetry)
        rotation = rot.concat(other: rotation)
        let anim = RotationAnimation(axis: rot.axis, angle: rot.angle, through: .zero, vecs: square.vecs, duration: duration, curve: Curve.linear) {
            self.isAnimating = false
        }
        renderer.start(anim)
    }

    public func reset() {
        guard !isAnimating else { return }
        isAnimating = true

        if !rotation.axis.x.isFinite || abs(rotation.angle) < 0.01 {
            return identityAnim()
        }

        // Inverse rotation
        let angle = rotation.angle
        let reverseAngle = abs(angle) > .pi + 0.01 ? sign(angle) * (2 * .pi - abs(angle)) : -angle
        let anim = RotationAnimation(axis: rotation.axis, angle: reverseAngle, through: .zero, vecs: square.vecs, duration: 0.4, curve: Curve.linear) {
            self.isAnimating = false
        }
        renderer.start(anim)
        rotation = Rotation(axis: .one, angle: .zero)
    }

    /// Perform an animation indicating that nothing is happening.
    private func identityAnim() {
        let scaleIn = ScaleAnimation(vecs: square.vecs, scaleCenter: .zero, scaleFactor: 1.1, duration: 0.2, curve: Curve.easeOut) {
            let scaleOut = ScaleAnimation(vecs: self.square.vecs, scaleCenter: .zero, scaleFactor: 1.0/1.1, duration: 0.2, curve: Curve.easeIn) {
                self.isAnimating = false
            }
            self.renderer.start(scaleOut)
        }
        renderer.start(scaleIn)
    }
}
