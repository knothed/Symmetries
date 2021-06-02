import simd
import UIKit

/// `PointNode` is a node which renders a single point.
public class PointNode: Node {
    private let layer = CALayer()

    /// The point's position in 3D space.
    public var position: VecRef

    public var radius: Radius
    public enum Radius {
        case fixed(CGFloat) // Independent of the 3D-position
        case real(CGFloat) // Actual 3D-ball with this radius
    }

    /// 3D-independent properties.
    public var color: UIColor

    /// Default initializer.
    public init(position: VecRef, color: UIColor = .black, radius: Radius = .fixed(3)) {
        self.position = position
        self.color = color
        self.radius = radius
        layer.disableAnimations()
    }

    /// Add the layer to a renderer.
    public override func add(to layer: CALayer) {
        layer.addSublayer(self.layer)
    }

    public override func removeFromLayer() {
        layer.removeFromSuperlayer()
    }

    /// Render the layer.
    public override func render() {
        guard let renderer = renderer else { return }

        layer.backgroundColor = color.cgColor

        // Project point onto layer
        let (projectedPos, scale) = renderer.projectOntoLayer(vec: position)
        layer.position = projectedPos
        layer.isHidden = scale <= 0

        // Determine maskedness
        let treatAsMasked = maskednessOpacityValues.masked == maskednessOpacityValues.normal
        let masked = treatAsMasked || renderer.isPointMasked(vec: position, projectedPos: projectedPos)
        layer.opacity = (masked ? maskednessOpacityValues.masked : maskednessOpacityValues.normal) * Float(opacity)

        // Calculate radius
        switch radius {
        case .fixed(let radius):
            layer.bounds.size = CGSize(width: 2 * radius, height: 2 * radius)
            layer.cornerRadius = radius

        case .real(let radius):
            let projectedRadius = radius * scale
            layer.bounds.size = CGSize(width: 2 * projectedRadius, height: 2 * projectedRadius)
            layer.cornerRadius = projectedRadius
        }
    }
}
