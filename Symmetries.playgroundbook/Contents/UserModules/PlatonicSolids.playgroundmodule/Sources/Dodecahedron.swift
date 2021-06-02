import Foundation

/// An Dodecahedron, centered at the origin.
public class Dodecahedron: PlatonicSolid {
    /// Default initializer.
    public convenience init(sideLength a: Double, style: Style) {
        let icosahedron = Icosahedron(sideLength: a * 1.5 * (sqrt(5) - 1), style: style)
        self.init(other: icosahedron.dual())
    }
}
