/*:
 # ☯️ Duality

 On the final page of this playground, we'll encouter a concept that is just as beautiful as symmetry: *duality*.
 Just as symmetry, duality naturally shows up in many areas and problems of mathematics.

 Starting from a platonic solid, we create it's dual solid by "swapping" its vertices with its faces. This means, wherever our original solid has a face, we create a new vertex at the center of this face, and we then connect all vertices which arise from neighboring faces.

 Convince yourself that this is actually not as complicated as it sounds: **Run the code** and explore the duality hiding in the platonic solids.

 - Note:
 Rotate the platonic solid during the duality animation with your finger. This gives you a better grasp for what exactly is happening.

 ### What is it good for?
 Dual platonic solids share various properties. For example, they have exactly the same symmetry group and therefore the same total number of symmetries. Also, their number of vertices and number of faces is swapped, while the number of edges stays the same.

 Taking the dual of the dual always yields the original platonic solid. The tetrahedron is self-dual – it has as many faces as it has vertices. This is the duality graph:

 ![img](DualityGraph.png)

 # 🧁 Thank You
 ... for participating in this playground. I hope you had fun learning about symmetries and playing around with the platonic solids.

 We conclude this playground by giving a real-world application for using platonic solids. It is well-known that platonic solids are very useful as shapes for dice: normal dice are just hexahedra, and there are dice in the form of every other platonic solid. The D20 for example is a well-known die among D&D players – it is just an icosahedron.

 But did you know that the platonic solids also make very good muffin shapes? Try it! These are some platonic muffins we made a while ago:

 ![img](PlatonicMuffins.png)

 *Bon appétit.*

 */

//#-hidden-code
import Views
import PlaygroundSupport
PlaygroundPage.current.liveView = PlatonicViewController(showDual: true)
//#-end-hidden-code
