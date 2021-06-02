import QuartzCore
import simd

/// `Node` defines an abstract node which can be rendered by a `Renderer`.
open class Node {
    /// The renderer which the node belongs to.
    public unowned internal(set) var renderer: Renderer?

    /// The opacity. Changing the opacity should immediately update the node, without needing to call `render`.
    public var opacity = 1.0
    public var maskednessOpacityValues: (masked: Float, normal: Float) = (masked: 0.25, normal: 1.0)

    /// Default initializer.
    public init() {
    }

    /// Add the node to the renderer's layer. This is only called a single time, when adding the node to a renderer.
    open func add(to layer: CALayer) {
    }

    /// Remove the node from the renderer's layer. This is only called a single time, when removing the node from a renderer.
    open func removeFromLayer() {
    }

    /// Render this node by updating the backing layer or similar.
    open func render() {
    }
}
