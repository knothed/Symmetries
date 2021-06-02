import PlatonicSolids
import simd
import ThreeD
import UIKit

/// `RenderHostView` wraps the layer from a `Renderer` and allows for rotation using the finger.
public class RenderHostView: UIView, UIGestureRecognizerDelegate {
    public let renderer = Renderer()
    private var panGesture: UIPanGestureRecognizer!
    private var rotationGesture: UIRotationGestureRecognizer!

    public var rotationCenter: () -> Vec3D = { .zero }

    /// When `true`, the user can rotate the whole renderer content about the origin using their finger.
    public var allowsInteraction = true {
        didSet {
            let toggle = allowsInteraction ? addGestureRecognizer : removeGestureRecognizer
            toggle(panGesture)
            toggle(rotationGesture)
        }
    }

    /// The vertices which will be rotated on a pan gesture.
    public var vecs = [VecRef]()
    internal var swipeAnimation: RotationAnimation?

    /// Default initializer.
    public override init(frame: CGRect = .zero) {
        super.init(frame: frame)
        backgroundColor = .white
        layer.addSublayer(renderer.layer)

        panGesture = UIPanGestureRecognizer(target: self, action: #selector(didPan))
        addGestureRecognizer(panGesture)
        rotationGesture = UIRotationGestureRecognizer(target: self, action: #selector(didRotate))
        addGestureRecognizer(rotationGesture)
    }

    public override func layoutSubviews() {
        renderer.layer.frame = bounds
    }

    public required init?(coder: NSCoder) {
        fatalError()
    }

    // MARK: Panning
    var lastPos: CGPoint?
    @objc private func didPan() {
        guard allowsInteraction else { return }

        // After releasing finger: animate further rotation
        if panGesture.state == .ended {
            let velocity = panGesture.velocity(in: self)
            if velocity == .zero { return }
            let (axis, v0) = rotation(for: simd_double2(Double(velocity.x), Double(velocity.y)))
            swipeAnimation = animation(around: axis, velocity: v0, friction: 0.998) {
                self.swipeAnimation = nil
            }
            renderer.start(swipeAnimation!)

            lastPos = nil
            return
        }

        else if panGesture.state == .began {
            lastPos = panGesture.translation(in: self)
            return
        }

        // During panning: Calculate difference
        let pos = panGesture.translation(in: self)
        defer { lastPos = pos }
        guard let last = lastPos, last != pos else { return }
        let diff: simd_double2 = simd_double2(Double(pos.x - last.x), Double(pos.y - last.y))

        let (axis, angle) = rotation(for: diff)

        // Apply rotation to each vector
        let rot = Rotation(axis: axis, angle: angle, through: rotationCenter())
        for vec in vecs { vec.rotate(by: rot) }

        renderer.render()
    }

    private func rotation(for diff: simd_double2) -> (axis: Vec3D, angle: Double) {
        // Scale by scene radius and by view scale factor
        let radius = vecs.map { simd_length($0.value) }.max() ?? 1
        let scaledDiff = diff / Double(max(1, renderer.largestVertexScaleFactor)) / radius
        let angle = simd_length(scaledDiff)

        // Find axis
        let swipe = simd_normalize(diff)
        let axis = swipe.x * renderer.axes.up + swipe.y * renderer.axes.right

        return (axis: axis, angle: angle)
    }

    public override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard allowsInteraction else { return }

        stopAnimation()
        super.touchesBegan(touches, with: event)
    }

    var lastRot: Double?
    @objc private func didRotate() {
        guard allowsInteraction else { return }

        // After releasing finger: animate further rotation
        if rotationGesture.state == .ended {
            let velocity = rotationGesture.velocity
            if velocity == .zero { return }
            let (axis, v0) = (simd_normalize(renderer.focusPoint - renderer.cameraPosition), Double(velocity))
            swipeAnimation = animation(around: axis, velocity: v0, friction: 0.998) {
                self.swipeAnimation = nil
            }
            renderer.start(swipeAnimation!)

            lastRot = nil
            return
        }

        else if rotationGesture.state == .began {
            lastRot = Double(rotationGesture.rotation)
            return
        }

        // During panning: Calculate difference
        let value = Double(rotationGesture.rotation)
        defer { lastRot = value }
        guard let last = lastRot, last != value else { return }
        let diff = value - last

        let (axis, angle) = (simd_normalize(renderer.focusPoint - renderer.cameraPosition), Double(diff))

        // Apply rotation to each vector
        let rot = Rotation(axis: axis, angle: angle, through: rotationCenter())
        for vec in vecs { vec.rotate(by: rot) }

        renderer.render()
    }

    /// Create a rotation animation with a friction curve.
    private func animation(around axis: Vec3D, velocity v0: Double, friction d: Double, animationHasFinished: @escaping () -> Void) -> RotationAnimation {
        let finalAngle = -v0 / (1000 * log(d))
        let eps: Double = 0.001 // neglegible angle difference
        let T = (log(-1000 * eps * log(d)) - log(abs(v0))) / (1000 * log(d))
        let f: (Double) -> Double = { v0 * (pow(d, 1000.0 * $0) - 1.0) / (1000.0 * log(d)) } // (0, inf) -> (0, finalAngle)
        let curve: (Double) -> Double = { f($0 * T) / finalAngle } // (0, 1) -> (0, 1)
        return RotationAnimation(axis: axis, angle: finalAngle, through: self.rotationCenter(), vecs: vecs, duration: T, curve: curve, animationHasFinished: animationHasFinished)
    }

    /// Stop the currently running animation.
    public func stopAnimation() {
        swipeAnimation?.stop()
        swipeAnimation = nil
    }
}
