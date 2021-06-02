import CoreGraphics
import Foundation
import simd

/// A line segment connecting two points.
internal struct LineSegment {
    let startPoint: CGPoint
    let endPoint: CGPoint
    let direction: CGPoint
    private let normDir: CGPoint
    private let length: CGFloat

    @inline(__always)
    init(startPoint: CGPoint, endPoint: CGPoint) {
        self.startPoint = startPoint
        self.endPoint = endPoint
        self.direction = CGPoint(x: endPoint.x - startPoint.x, y: endPoint.y - startPoint.y)

        length = sqrt(direction.x * direction.x + direction.y * direction.y)
        normDir = CGPoint(x: direction.x / length, y: direction.y / length)
    }

    /// Intersect two line segments.
    /// If `otherIsRay`, the other line segment is actually a ray starting at `other.startPoint` with direction `direction`. `other.endPoint` is then irrelevant.
    @inline(__always)
    func intersection(with other: LineSegment, otherIsRay: Bool = false) -> CGPoint? {
        let det = self.direction.x * other.direction.y - self.direction.y * other.direction.x
        if abs(det) <= 0.001 { return nil }

        let dx = other.startPoint.x - self.startPoint.x
        let dy = other.startPoint.y - self.startPoint.y
        let u = (dx * other.direction.y - dy * other.direction.x) / det
        let v = (dx * self.direction.y - dy * self.direction.x) / det

        if u < 0 || u > 1 || v < 0 || (v > 1 && !otherIsRay) { return nil }
        return CGPoint(x: startPoint.x + u * direction.x, y: startPoint.y + u * direction.y)
    }

    /// Calculate the distance to a point.
    @inline(__always)
    func distance(to point: CGPoint) -> CGFloat {
        var t = normDir.x * (point.x - startPoint.x) + normDir.y * (point.y - startPoint.y)
        t = max(0, min(length, t))
        let projx = startPoint.x + t * normDir.x
        let projy = startPoint.y + t * normDir.y
        return sqrt((projx - point.x) * (projx - point.x) + (projy - point.y) * (projy - point.y))
    }
}
