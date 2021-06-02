import simd
import UIKit

/// `TextNode` is a node which renders text.
public class TextNode: Node {
    private let layer = CATextLayer()

    /// The point's position in 3D space.
    public var position: VecRef

    public var textSize: TextSize
    public enum TextSize {
        case fixed(CGFloat) // Independent of the 3D-position
        case real(CGFloat) // Actual 3D-ball with this radius
    }

    /// 3D-independent properties.
    public var color: UIColor
    public var text: String

    /// Default initializer.
    public init(position: VecRef, color: UIColor = .black, text: String, textSize: TextSize = .fixed(30)) {
        self.position = position
        self.color = color
        self.textSize = textSize
        self.text = text

        layer.disableAnimations()
        layer.contentsScale = UIScreen.main.scale
        layer.alignmentMode = .center
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

        layer.foregroundColor = color.cgColor

        // Project point onto layer
        let (projectedPos, scale) = renderer.projectOntoLayer(vec: position)
        layer.position = CGPoint(x: round(projectedPos.x), y: round(projectedPos.y))
        layer.isHidden = scale <= 0

        /* Determine maskedness
        let treatAsMasked = maskednessOpacityValues.masked == maskednessOpacityValues.normal
        let masked = treatAsMasked || renderer.isPointMasked(vec: position, projectedPos: projectedPos)
        layer.opacity = (masked ? maskednessOpacityValues.masked : maskednessOpacityValues.normal) * Float(opacity)*/

        // Calculate text size
        var size: CGFloat
        switch textSize {
        case .fixed(let textSize): size = textSize
        case .real(let textSize): size = scale * textSize
        }

        layer.string = text
        layer.font = UIFont.systemFont(ofSize: size, weight: .light)
        layer.fontSize = size
        layer.bounds.size = CGSize(width: 1.2 * size, height: 1.2 * size)
    }
}
