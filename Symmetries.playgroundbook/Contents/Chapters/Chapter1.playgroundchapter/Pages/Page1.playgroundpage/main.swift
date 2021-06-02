/*:
 # 👋 Welcome to *Symmetries*!

 Symmetry is a fundamental concept of our universe – it arises in many settings of mathematics, physics and nature. This playground aims to give you a brief introduction to the beauty of symmetry.

 ![img](PlatonicSolids.png)

 # ⁉️ What is Symmetry?

 In this playground, our focus lies on symmetries of geometric objects, like regular polygons or polyhedra. Thereby, a *symmetry* is an operation mapping an object onto itself – for example a rotation, a reflection, or a combination of both. A symmetry can swap vertices and edges, but it can't change the shape of the object.

 Mathematicians call the collection of all symmetries of an object its *symmetry group*. The most important property of a symmetry group is this: combining two symmetries **always** yields another symmetry!

 # 👉 Your Turn

 Let's begin by looking at the symmetry group of a square. Therefore, **run the code**.
 The square has a total of **8 symmetries** (including the identity symmetry). Tap on a symmetry to apply it.

 - Note:
 Every object has the *identity symmetry*, denoted by **id**, which does nothing. It is, technically, also a symmetry.

 Play around with the square's symmetries. Try to combine multiple symmetries by performing them in succession, and keep track of where the vertices end up. You may notice the following properties:
  - combining two rotations yields another rotation
  - combining a rotation and a reflection yields a reflection across a *different* axis
  - combining two reflections yields a rotation!

 If you're familiar with the symmetries of the square, [go to the next page](@next).

*/

//#-hidden-code

import PlatonicSolids
import ThreeD
import Views
import UIKit
import PlaygroundSupport

// Create view controller
let square = Square(center: .zero, upAxis: Vec3D(0, 1, 0), rightAxis: Vec3D(1, 0, 0), size: 1, pointRadius: .real(0.025), lineWidth: .real(0.01), color: UIColor(red: 0, green: 0, blue: 0.8, alpha: 1))
let vc = SymmetriesViewController(delegate: SquareDelegate(square: square))

// Setup renderer
let renderer = vc.hostView.renderer
renderer.cameraPosition = Vec3D(0, 0, 4)
renderer.windowSize = CGSize(width: 2, height: 2)
renderer.upAxis = Vec3D(0, 1, 0)
renderer.focusPoint = .zero

// Add square
square.nodes.forEach(renderer.add(node:))

PlaygroundPage.current.liveView = vc

//#-end-hidden-code
