import PlatonicSolids
import simd
import ThreeD
import UIKit

public class OctahedronDelegate: SymmetriesDelegate {
    public let octahedron: Octahedron
    public var renderer: Renderer!
    public var buttonColor: UIColor { octahedron.style.color }

    private var isAnimating = false
    private var rotation = Rotation(axis: .one, angle: .zero)

    /// Default initializer.
    public init(octahedron: Octahedron) {
        self.octahedron = octahedron
    }

    /// All symmetries along with an image.
    private lazy var actions: [(rotation: Rotation, image: String)] = [
        (octahedron.quad1LeftRotation, "quad1-left"),
        (octahedron.quad1RightRotation, "quad1-right"),
        (octahedron.quad2Rotation, "quad2-rotate"),
        (octahedron.quad3Rotation, "quad3-rotate"),
        (octahedron.quad1HorizMirror, "quad1-horiz"),
        (octahedron.quad1VertMirror, "quad1-vert"),
        (octahedron.quad2Mirror, "quad2-mirror"),
        (octahedron.quad3Mirror, "quad3-mirror")
    ]

    public func image(for index: Int) -> UIImage {
        let name = actions[index].image
        return UIImage(named: name) ?? UIImage()
    }

    public func buttonTapped(index: Int) {
        guard !isAnimating else { return }
        isAnimating = true

        // Rotate around symmetry axis
        let rot = actions[index].rotation
        let duration = index > 3 ? 0.6 : 0.4
        rotation = rot.concat(other: rotation)
        let anim = RotationAnimation(axis: rot.axis, angle: rot.angle, through: .zero, vecs: octahedron.vertices, duration: duration, curve: Curve.linear) {
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
        let anim = RotationAnimation(axis: rotation.axis, angle: reverseAngle, through: .zero, vecs: octahedron.vertices, duration: 0.4, curve: Curve.linear) {
            self.isAnimating = false
        }
        renderer.start(anim)
        rotation = Rotation(axis: .one, angle: .zero)
    }

    /// Perform an animation indicating that nothing is happening.
    private func identityAnim() {
        let scaleIn = ScaleAnimation(vecs: octahedron.vertices, scaleCenter: .zero, scaleFactor: 1.1, duration: 0.2, curve: Curve.easeOut) {
            let scaleOut = ScaleAnimation(vecs: self.octahedron.vertices, scaleCenter: .zero, scaleFactor: 1.0/1.1, duration: 0.2, curve: Curve.easeIn) {
                self.isAnimating = false
            }
            self.renderer.start(scaleOut)
        }
        renderer.start(scaleIn)
    }
}
