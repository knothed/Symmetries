import Foundation
import QuartzCore
import simd

/// Fade some nodes in, while fading other nodes out.
public class FadeInOutAnimation: Animation {
    private let fadeIn: [Node]
    private let fadeOut: [Node]
    private let fadeInCurve: (Double) -> Double
    private let fadeOutCurve: (Double) -> Double

    /// Default initializer.
    public init(fadeIn: [Node], fadeOut: [Node], duration: Double, fadeInCurve: @escaping (Double) -> Double = Curve.linear, fadeOutCurve: @escaping (Double) -> Double = Curve.linear, animationHasFinished: (() -> Void)? = nil) {
        self.fadeIn = fadeIn
        self.fadeOut = fadeOut
        self.fadeInCurve = fadeInCurve
        self.fadeOutCurve = fadeOutCurve
        super.init(duration: duration, curve: { $0 }, animationHasFinished: animationHasFinished)
    }

    public override func updateNodes(progress: Double, dProgress: Double) {
        fadeIn.forEach { $0.opacity = fadeInCurve(progress) }
        fadeOut.forEach { $0.opacity = 1 - fadeOutCurve(progress) }
    }
}
