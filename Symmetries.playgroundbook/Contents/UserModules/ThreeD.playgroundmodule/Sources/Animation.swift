import Foundation
import QuartzCore

/// An `Animation` is used to smoothly animate positions or other properties of nodes.
/// After each frame, the corresponding nodes are re-rendered.
open class Animation {
    public var finished = false
    internal var startTime: Double!

    /// The duration of the animation.
    public let duration: Double

    /// A callback which is called when the animation has finished.
    private let animationHasFinished: (() -> Void)?

    /// A map from `[0, 1]` to `[0, 1]` for non-linear animation behavior.
    private let curve: (Double) -> Double

    private var lastUserProgress: Double = 0

    /// Default initializer.
    public init(duration: Double, curve: @escaping (Double) -> Double, animationHasFinished: (() -> Void)? = nil) {
        self.duration = duration
        self.curve = curve
        self.animationHasFinished = animationHasFinished
    }

    internal func update() {
        let elapsed = CFAbsoluteTimeGetCurrent() - startTime
        let progress = max(0, min(1, elapsed / duration))
        let userProgress = max(0, min(1, curve(progress)))

        updateNodes(progress: userProgress, dProgress: userProgress - lastUserProgress)
        lastUserProgress = userProgress

        // Finish animation
        if progress == 1 {
            finished = true
            animationHasFinished?()
        }
    }

    /// Override to update the animatede nodes.
    /// `progress` is between 0 and 1. `dProgress` indicates the difference between the last progress value and the current progress value.
    open func updateNodes(progress: Double, dProgress: Double) {
    }
}

public struct Curve {
    public static let linear: (Double) -> Double = { $0 }
    public static let easeIn: (Double) -> Double = { $0 * $0 }
    public static let easeOut: (Double) -> Double = { 2.0 * $0 * (1.0 - 0.5 * $0) }
    public static let easeInOut: (Double) -> Double = { $0 * $0 * (3.0 - 2.0 * $0) }
}
