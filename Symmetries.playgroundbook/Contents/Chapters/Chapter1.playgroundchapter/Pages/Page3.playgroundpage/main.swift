/*:
 # 🖐 The Platonic Solids

 On the last page we learned about the symmetries of an octahedron. The octahedron is one of the five **platonic solids**.

 What makes them special is that they are, in a certain sense, *very symmetric*. As they are regular polyhedra, they consist of multiple similar copies of a regular polygon. Therefore, a platonic solid looks the same from every perspective: no matter which face is on top, the platonic solid looks identical, as all faces look the same. Additionally, rotating a face does not change this fact, because all faces are rotationally-symmetric, regular polygons.
 This explains the large number of symmetries a platonic solid has.

 On this page you can freely play around with the five platonic solids. **Run the code** and have fun!
 In addition to the number of edges, vertices and faces, the number of each platonic solid's symmetries is also displayed at the bottom of the screen.

 - Note:
 Use one finger to rotate the platonic solid. You can also use a two-finger rotation gesture.

 # 🧮 The Euler Characteristic

 As a short insertion, we'll state a beautiful mathematical result related to polyhedra: Euler's polyhedron formula. It does not only hold the platonic solids, but for all polyhedra, given they have no holes in them.

 In short, it states **V - E + F = 2**. Or: Vertices - Edges + Faces = 2.

 This is a central, very popular geometric result and was already proven in 1758 by Leonhard Euler.

 With this beautiful formula in mind, let's go to the [final page](@next).
 */

//#-hidden-code
import Views
import PlaygroundSupport
PlaygroundPage.current.liveView = PlatonicViewController(showDual: false)
//#-end-hidden-code
