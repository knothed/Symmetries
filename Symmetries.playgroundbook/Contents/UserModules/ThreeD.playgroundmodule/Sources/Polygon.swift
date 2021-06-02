import Foundation
import CoreGraphics

internal struct Polygon {
    /// The points defining the edges of the polygon. Any two consecutive points define one edge.
    let points: [CGPoint]

    /// The edges of the polygon.
    let edges: [LineSegment]

    /// Default initializer. The points must be in consecutive (i.e. either clock- or counterclockwise) order.
    @inline(__always)
    init(points: [CGPoint]) {
        self.points = points
        self.edges = (0 ..< points.count).map { i in
            LineSegment(startPoint: points[i], endPoint: points[(i + 1) % points.count])
        }
    }

    /// Calculate all intersections of `self` with `line`.
    @inline(__always)
    func intersections(with line: LineSegment) -> [CGPoint] {
        edges.compactMap { $0.intersection(with: line) }
    }

    /// Determine whether `point` lies inside `self`.
    @inline(__always)
    func contains(_ point: CGPoint) -> Bool {
        // Special check: is point exactly on the edge?
        if distance(to: point) <= 1e-6 { return true }

        // Create random ray and test number of intersections with the polygon
        let angle = CGFloat.random(in: 0 ..< 2 * .pi)
        let endPoint = CGPoint(x: point.x + sin(angle), y: point.y + cos(angle))
        let ray = LineSegment(startPoint: point, endPoint: endPoint)

        // Count number of intersections; odd values yield a point inside the polygon, even values outside
        var oddNumberOfIntersections = false
        for edge in edges {
            if edge.intersection(with: ray, otherIsRay: true) != nil {
                oddNumberOfIntersections.toggle()
            }
        }

        return oddNumberOfIntersections
    }

    /// Calculate the unsigned distance to a point.
    @inline(__always)
    func distance(to point: CGPoint) -> CGFloat {
        var dist = CGFloat.infinity
        for edge in edges {
            dist = min(dist, edge.distance(to: point))
        }
        return dist
    }
}
