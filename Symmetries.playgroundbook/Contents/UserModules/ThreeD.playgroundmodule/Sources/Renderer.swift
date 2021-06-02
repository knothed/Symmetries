import QuartzCore
import simd

/// `Renderer` renders a set of `Nodes` onto a layer.
/// Thereby, `Renderer` defines a camera position and view direction, and projects all nodes onto the view plane.
public final class Renderer {
    /// The layer onto which all nodes are rendered.
    public let layer: CALayer
    private var boundsObservation: NSKeyValueObservation!

    /// `focusPoint` is the point that is looked at by the camera, which is located at `cameraPosition`.
    /// `cameraPosition` and `focusPoint` must not be equal to each other.
    public var cameraPosition: Vec3D = .zero
    public var focusPoint: Vec3D = .one

    /// The up-axis of the view plane. It must lie in the view plane.
    public var upAxis: Vec3D = Vec3D(-1, -1, 1)

    /// The size of the view plane. After rendering, the layer always fully contains this view plane.
    /// The plane's center is `focusPoint` and it is orthogonal to `focusPoint - cameraPosition`.
    public var windowSize: CGSize = CGSize(width: 1, height: 1)

    /// The scale factor for converting objects on the plane onto the actual layer.
    /// The scale factor is chosen so that the window is always fully visible inside the layer, regardless of the aspect ratios.
    public var planeToLayerScaleFactor: CGFloat {
        min(layer.bounds.width / windowSize.width, layer.bounds.height / windowSize.height)
    }

    /// Default initializer.
    public init() {
        layer = CALayer()
        layer.disableAnimations()
        layer.masksToBounds = true
        layer.anchorPoint = CGPoint(x: 0.5, y: 0.5)

        displayLink = CADisplayLink(target: self, selector: #selector(updateAnimations))
        displayLink.add(to: .current, forMode: .default)
        displayLink.isPaused = true

        boundsObservation = layer.observe(\.bounds) { _, _  in
            self.render()
        }
    }

    /// Add a node.
    public func add(node: Node) {
        nodes.append(node)
        node.add(to: layer)
        node.renderer = self
    }

    /// Remove a node.
    public func remove(node: Node) {
        nodes.removeAll { $0 === node }
        node.removeFromLayer()
        node.renderer = nil
    }

    // MARK: Rendering
    public private(set) var nodes = [Node]()

    /// The axes, which lie on the view plane.
    public private(set) var axes: (up: Vec3D, right: Vec3D) = (.zero, .zero)

    /// Faces are used to mask nodes if these are behind the faces.
    public var faces = [Face]()
    internal private(set) var faceProjections = [(Face, Polygon, Double)]() // (Face, Polygon, distance from camera)

    /// `projectionCache` caches projections of Vec3Ds onto the view plane during a single render cycle.
    private var projectionCache = [VecRef: (CGPoint, CGFloat)]()

    public private(set) var largestVertexScaleFactor: CGFloat = 0

    /// Render all nodes onto the layer.
    /// Calling `render` re-renderes everything.
    public func render() {
        projectionCache.removeAll()

        projectFaces()
        nodes.forEach { $0.render() }

        largestVertexScaleFactor = projectionCache.values.map { $1 }.max() ?? 0
        projectionCache.removeAll()
    }

    /// Project all faces onto the plane and fill `faceProjections`.
    private func projectFaces() {
        faceProjections = faces.map { $0.projectOntoLayer(using: self) }
    }

    /// The same as `projectOntoLayer(vec: Vec3D)`, but caching and reusing the results.
    public func projectOntoLayer(vec: VecRef) -> (CGPoint, CGFloat) {
        if let result = projectionCache[vec] {
            return result
        } else {
            let result = projectOntoLayer(vec: vec.value)
            projectionCache[vec] = result
            return result
        }
    }

    /// Project a 3D-point onto the backing layer by looking at the object from the camera position.
    /// Return two things:
    ///  - the projected position on the layer
    ///  - the projection scale factor – how much larger (infinitesimal) distances are on the layer than they are in the 3D space. If it is zero or negative, the object is behind the camera.
    public func projectOntoLayer(vec: Vec3D) -> (CGPoint, CGFloat) {
        // Distance from camera to point
        let ray = vec - cameraPosition
        let distToPoint = simd_length(ray)

        // Distance from camera to plane (along `ray`)
        let direction = simd_normalize(ray)
        let normal = simd_normalize(focusPoint - cameraPosition)
        let distToPlane = simd_distance(focusPoint, cameraPosition) / (simd_dot(direction, normal))

        if distToPoint == 0 || distToPlane.isNaN || distToPlane.isInfinite { return (.zero, .zero) }

        // Project `vec` onto plane
        let scale = distToPlane / distToPoint
        let projected = cameraPosition + ray * scale

        // Project up-axis onto the plane (in case it isn't already) and normalize
        axes.up = simd_normalize(self.upAxis - simd_dot(self.upAxis, normal) * normal)
        axes.right = simd_cross(normal, axes.up)

        // Find 2D coordinates respective to up and right axes
        let x = simd_dot(projected - focusPoint, axes.right)
        let y = -simd_dot(projected - focusPoint, axes.up)

        // Scale onto layer, keeping the window centered and fully visible
        let layerPosition = CGPoint(
            x: layer.bounds.midX + planeToLayerScaleFactor * CGFloat(x),
            y: layer.bounds.midY + planeToLayerScaleFactor * CGFloat(y)
        )
        
        return (layerPosition, CGFloat(scale) * planeToLayerScaleFactor)
    }

    /// Determine whether the point at the given position and projected position is masked by any of the faces.
    public func isPointMasked(vec: VecRef, projectedPos: CGPoint) -> Bool {
        return isPointMaskedImpl(vec: vec, isOnFace: { $0.vertices.contains(vec) }, projectedPos: projectedPos)
    }

    /// Determine whether the point at the given position and projected position is masked by any of the faces.
    internal func isPointMaskedImpl(vec: VecRef, isOnFace: (Face) -> Bool, projectedPos: CGPoint) -> Bool {
        let distanceToCamera = simd_distance(vec.value, cameraPosition)

        for (face, polygon, minDistance) in faceProjections {
            if minDistance > distanceToCamera || isOnFace(face) { continue } // No intersection possible

            if !polygon.contains(projectedPos) { continue } // Not intersecting on the layer

            // Now the ray through the point intersects with the face. Check whether the point is actually behind the face in 3D space
            let planeDist = face.distance(to: cameraPosition, in: vec.value - cameraPosition)
            if planeDist < distanceToCamera {
                return true
            }
        }

        return false
    }

    // MARK: Animations
    /// All animations which are currently running on this renderer.
    private var animations = [Animation]()
    private var displayLink: CADisplayLink!

    /// Start an animation which is related to this renderer.
    public func start(_ animation: Animation) {
        animation.startTime = CFAbsoluteTimeGetCurrent()
        animations.append(animation)
        displayLink.isPaused = false
    }

    /// Start multiple animations which are related to this renderer.
    public func start(_ animations: Animation...) {
        animations.forEach(start(_:))
    }

    @objc private func updateAnimations() {
        for animation in animations where !animation.finished {
            animation.update()
        }

        // Re-render and remove finished animations
        if !animations.isEmpty { render() }
        animations.removeAll(where: \.finished)

        displayLink.isPaused = animations.isEmpty
    }
}
