import simd
import UIKit

/// `LineNode` is a node which renders a line segment.
open class LineNode: Node {
    private let layer = CAShapeLayer()

    /// The line.
    public var edge: Edge

    public var width: Width
    public enum Width {
        case fixed(CGFloat) // Independent of the 3D-position
        case real(CGFloat) // Actual 3D-line with this width. The width is interpolated linearly (which is wrong but simple)
    }

    /// 3D-independent properties.
    public var color: UIColor

    /// Default initializer.
    public init(edge: Edge, color: UIColor = .black, width: Width = .fixed(3)) {
        self.edge = edge
        self.color = color
        self.width = width
        layer.disableAnimations()
        layer.lineWidth = 0
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

        layer.fillColor = color.cgColor

        // Project line onto layer
        let (pos1, scale1) = renderer.projectOntoLayer(vec: edge.vec1)
        let (pos2, scale2) = renderer.projectOntoLayer(vec: edge.vec2)
        layer.isHidden = scale1 <= 0 || scale2 <= 0

        // Determine maskedness
        let treatAsMasked = maskednessOpacityValues.masked == maskednessOpacityValues.normal
        let masked = treatAsMasked || isMasked(renderer: renderer)
        layer.opacity = (masked ? maskednessOpacityValues.masked : maskednessOpacityValues.normal) * Float(opacity)

        // Calculate length (i.e. layer.width), center and rotation
        let dx = pos2.x - pos1.x, dy = pos2.y - pos1.y
        let length = sqrt(dx * dx + dy * dy)
        layer.bounds.size.width = length
        layer.position = CGPoint(x: (pos1.x + pos2.x) / 2, y: (pos1.y + pos2.y) / 2)
        layer.transform = CATransform3DMakeRotation(atan2(dy, dx), 0, 0, 1)

        // Calculate width (i.e. layer.height)
        var height1: CGFloat
        var height2: CGFloat
        switch width {
        case .fixed(let width):
            height1 = width
            height2 = width

        case .real(let width):
            height1 = width * scale1
            height2 = width * scale2
        }
        let height = max(height1, height2)
        layer.bounds.size.height = height

        // Draw linear path
        let l = height == height1 ? 0 : length
        let path = CGMutablePath()
        path.move(to: CGPoint(x: l, y: 0))
        path.addLine(to: CGPoint(x: l, y: height))
        path.addLine(to: CGPoint(x: length - l, y: height / 2 + min(height1, height2) / 2))
        path.addLine(to: CGPoint(x: length - l, y: height / 2 - min(height1, height2) / 2))
        layer.path = path
    }

    /// Calculate whether the whole line is masked.
    /// In a general setting, we would have to calculate which exact portions of the line are masked and which are not.
    /// In our specific case - platonic solids - a line is either fully masked or not at all, which makes this *much* easier.
    /// We just look at any point on the line - if it is masked, the whole line is masked.
    private func isMasked(renderer: Renderer) -> Bool {
        let midpoint = ((edge.vec1.value + edge.vec2.value) / 2).ref
        let projection = renderer.projectOntoLayer(vec: midpoint.value).0
        return renderer.isPointMaskedImpl(vec: midpoint, isOnFace: { $0.edges.contains(edge) }, projectedPos: projection)
    }
}
