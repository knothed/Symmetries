import Foundation
import QuartzCore
import simd

/// Animate the `maskednessOpacityValues` of a set of nodes.
public class ChangeMaskednessOpacityAnimation: Animation {
    private let nodes: [Node]
    private let startValue: (masked: Float, normal: Float)
    private let endValue: (masked: Float, normal: Float)

    /// Default initializer.
    public init(nodes: [Node], startValue: (masked: Float, normal: Float), endValue: (masked: Float, normal: Float), duration: Double, curve: @escaping (Double) -> Double = Curve.linear, animationHasFinished: (() -> Void)? = nil) {
        self.nodes = nodes
        self.startValue = startValue
        self.endValue = endValue
        super.init(duration: duration, curve: curve, animationHasFinished: animationHasFinished)
    }

    public override func updateNodes(progress: Double, dProgress: Double) {
        let values: (masked: Float, normal: Float) = (
            masked: startValue.masked + Float(progress) * (endValue.masked - startValue.masked),
            normal: startValue.normal + Float(progress) * (endValue.normal - startValue.normal)
        )
        for node in nodes {
            node.maskednessOpacityValues = values
        }
    }
}
