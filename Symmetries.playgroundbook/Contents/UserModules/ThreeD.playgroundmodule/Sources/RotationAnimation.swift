import Foundation
import QuartzCore
import simd

/// RotationAnimation rotates all vertices around the origin.
public class RotationAnimation: Animation {
    private let axis: Vec3D
    private let angle: Double
    private let center: () -> Vec3D

    public var vecs: [VecRef]

    /// Default initializer.
    public init(axis: Vec3D, angle: Double, through center: @escaping @autoclosure () -> Vec3D = Vec3D.zero, vecs: [VecRef], duration: Double, curve: @escaping (Double) -> Double = Curve.linear, animationHasFinished: (() -> Void)? = nil) {
        self.axis = axis
        self.angle = angle
        self.center = center
        self.vecs = vecs
        super.init(duration: duration, curve: curve, animationHasFinished: animationHasFinished)
    }

    public override func updateNodes(progress: Double, dProgress: Double) {
        let dRot = Rotation(axis: axis, angle: angle * dProgress, through: center())
        for vec in vecs { vec.rotate(by: dRot) }
    }

    /// Stop the animation at the current progress.
    public func stop() {
        finished = true
    }
}

/// `Rotation` describes the rotation around an axis about an angle.
public struct Rotation {
    public var axis: Vec3D { quaternion.axis }
    public var angle: Double { quaternion.angle }
    public let center: Vec3D
    public let quaternion: simd_quatd

    public init(axis: Vec3D, angle: Double, through center: Vec3D = .zero) {
        self.center = center
        quaternion = simd_quatd(angle: angle, axis: simd_normalize(axis))
    }

    public init(center: Vec3D = .zero, quaternion: simd_quatd) {
        self.quaternion = quaternion
        self.center = center
    }

    /// Rotate `vec` by `self`.
    public func apply(to vec: Vec3D) -> Vec3D {
        quaternion.act(vec - center) + center
    }

    /// Calculate `self ◦ other`. This **only** works if both rotations have center zero.
    public func concat(other: Rotation) -> Rotation {
        return Rotation(quaternion: quaternion * other.quaternion)
    }
}
