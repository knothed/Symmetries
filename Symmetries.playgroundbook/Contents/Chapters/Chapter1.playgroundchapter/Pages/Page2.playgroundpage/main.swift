/*:
 # 🎱 The Octahedron

 A regular octahedron consists of 6 vertices which make up 8 triangular faces.

 On this page we will explore the symmetry group of such a regular octahedron. In contrast to the square from before, a regular octahedron is much more symmetric: it has a total of 48 symmetries.
 From these 48 symmetries, 24 involve a reflection (i.e. mirroring), which means they cannot be achieved by rotation alone.

 - Note:
Loosely speaking, the size of an object's symmetry group is a measure for how symmetric it is.

 To keep things simple, we'll only look at the 24 rotational symmetries in this example.
 **Run the code** and play around with the symmetries.

 The eight buttons only expose 8 of the 24 symmetries, but you can reach *any* of the 24 symmetries by combining the eight given ones.

  - Note:
  Tap "Reset to default" to move all vertices back to their original positions. When doing this, you apply the *inverse symmetry* of the current symmetry, which is of course also a symmetry.

 # 🟪🟨 Hidden Squares

 Did you see the three squares hiding inside the octahedron? If not, here they are:
  - the first one consists of the vertices 2, 3, 4 and 5
  - the second one consists of the vertices 1, 3, 6 and 5
  - the third one consists of the vertices 1, 2, 6 and 4.

 Each symmetry is related to one of these squares. Try to perform some symmetries while keeping your eyes on one of these squares and see if you can figure out the role that these squares play.


When you are familiar with the symmetries of the octahedron or have had enough, [go to the next page](@next).
 */

//#-hidden-code

import PlatonicSolids
import ThreeD
import Views
import UIKit
import PlaygroundSupport

// Create view controller
let octahedron = Octahedron(sideLength: 1, style: PlatonicSolid.Style(pointRadius: .real(0.025), lineWidth: .real(0.01), color: UIColor(red: 0.7, green: 0, blue: 0, alpha: 1)), text: true)
let vc = SymmetriesViewController(delegate: OctahedronDelegate(octahedron: octahedron))

// Setup renderer
let renderer = vc.hostView.renderer
renderer.cameraPosition = Vec3D(2, -2, 1.8)
renderer.windowSize = CGSize(width: 2, height: 2)
renderer.upAxis = Vec3D(0, 0, 1)
renderer.focusPoint = .zero

// Add octahedron
octahedron.add(to: renderer)

PlaygroundPage.current.liveView = vc

//#-end-hidden-code
