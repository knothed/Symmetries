import Foundation
import QuartzCore
import simd

/// Scale vertices around some cneter point.
public class ScaleAnimation: Animation {
    private let vecs: [VecRef]
    private let scaleCenter: Vec3D
    private let scaleFactor: Double

    /// Default initializer.
    public init(vecs: [VecRef], scaleCenter: Vec3D, scaleFactor: Double, duration: Double, curve: @escaping (Double) -> Double = Curve.linear, animationHasFinished: (() -> Void)? = nil) {
        self.vecs = vecs
        self.scaleCenter = scaleCenter
        self.scaleFactor = scaleFactor
        super.init(duration: duration, curve: curve, animationHasFinished: animationHasFinished)
    }

    public override func updateNodes(progress: Double, dProgress: Double) {
        for vec in vecs {
            vec.value = (vec.value - scaleCenter) * pow(scaleFactor, dProgress) + scaleCenter
        }
    }
}
