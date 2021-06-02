import Dispatch
import PlatonicSolids
import simd
import ThreeD
import UIKit

public class PlatonicViewController: UIViewController {
    private let showDual: Bool

    /// Default initializer.
    public init(showDual: Bool) {
        self.showDual = showDual
        super.init(nibName: nil, bundle: nil)
        view.backgroundColor = .white
    }

    public required init?(coder: NSCoder) {
        fatalError()
    }

    /// `Scene` describes one of the possible scenes displaying a platonic solid.
    private struct Scene {
        let name: String
        let info: (vertices: Int, edges: Int, faces: Int, symmetries: Int)
        let color: UIColor
        let makeSolid: (PlatonicSolid.Style) -> PlatonicSolid
    }

    /// All scenes.
    private let scenes = [
        Scene(name: "The Tetrahedron", info: (vertices: 4, edges: 6, faces: 4, symmetries: 24), color: UIColor(red: 0.85, green: 0, blue: 0, alpha: 1)) { Tetrahedron(sideLength: 1, style: $0) },
        Scene(name: "The Octahedron", info: (vertices: 6, edges: 12, faces: 8, symmetries: 48), color: UIColor(red: 0, green: 0, blue: 0.5, alpha: 1)) { Octahedron(sideLength: 1, style: $0) },
        Scene(name: "The Hexahedron", info: (vertices: 8, edges: 12, faces: 6, symmetries: 48), color: UIColor(red: 0, green: 0.5, blue: 1, alpha: 1)) { Cube(sideLength: 1, style: $0) },
        Scene(name: "The Icosahedron", info: (vertices: 12, edges: 30, faces: 20, symmetries: 60), color: UIColor(red: 0.9, green: 0.7, blue: 0.1, alpha: 1)) { Icosahedron(sideLength: 1, style: $0) },
        Scene(name: "The Dodecahedron", info: (vertices: 20, edges: 30, faces: 12, symmetries: 60), color: UIColor(red: 0.85, green: 0.3, blue: 0, alpha: 1)) { Dodecahedron(sideLength: 1, style: $0) }
    ]
    private var sceneIndex = 0

    // - UI Elements -
    private let titleLabel = UILabel()
    private var sceneView = RenderHostView()
    private let properties = PlatonicPropertiesView()
    private let leftButton = UIButton(type: .system)
    private let rightButton = UIButton(type: .system)
    private let dualButton = UIButton(type: .system)
    private var renderer: Renderer { sceneView.renderer }

    private var currentSolid: PlatonicSolid!

    /// `True` while a platonic solid transition or a duality animation is running.
    private var isAnimatingDual = false
    private var isAnimatingTransition: Bool {
        get { !sceneView.allowsInteraction || isAnimatingDual }
        set { sceneView.allowsInteraction = !newValue }
    }

    public override func viewDidLoad() {
        titleLabel.backgroundColor = .white
        view.addSubview(titleLabel)
        view.addSubview(sceneView)
        view.addSubview(properties)
        view.addSubview(leftButton)
        view.addSubview(rightButton)

        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        sceneView.translatesAutoresizingMaskIntoConstraints = false
        properties.translatesAutoresizingMaskIntoConstraints = false
        leftButton.translatesAutoresizingMaskIntoConstraints = false
        rightButton.translatesAutoresizingMaskIntoConstraints = false
        dualButton.translatesAutoresizingMaskIntoConstraints = false

        titleLabel.text = "The Icosahedron"
        titleLabel.textAlignment = .center
        titleLabel.font = .systemFont(ofSize: 50, weight: .semibold)

        let config = UIImage.SymbolConfiguration(pointSize: 50, weight: .light, scale: .medium)
        let leftImage = UIImage(systemName: "chevron.left", withConfiguration: config)
        let rightImage = UIImage(systemName: "chevron.right", withConfiguration: config)
        leftButton.tintColor = .black
        rightButton.tintColor = .black
        leftButton.setImage(leftImage, for: .normal)
        rightButton.setImage(rightImage, for: .normal)

        dualButton.setTitle("Make Dual", for: .normal)
        dualButton.titleLabel?.font = UIFont.systemFont(ofSize: 40, weight: .bold)

        if showDual {
            view.addSubview(dualButton)
            NSLayoutConstraint.activate([
                dualButton.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: -20),
                dualButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
                dualButton.widthAnchor.constraint(equalToConstant: 200),
                dualButton.heightAnchor.constraint(equalToConstant: 50),
            ])
        }

        NSLayoutConstraint.activate([
            titleLabel.leftAnchor.constraint(equalTo: view.leftAnchor),
            titleLabel.rightAnchor.constraint(equalTo: view.rightAnchor),
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            titleLabel.heightAnchor.constraint(equalToConstant: 100),
            leftButton.widthAnchor.constraint(equalToConstant: 50),
            leftButton.heightAnchor.constraint(equalToConstant: 100),
            leftButton.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 15),
            leftButton.centerYAnchor.constraint(equalTo: sceneView.centerYAnchor),
            rightButton.widthAnchor.constraint(equalToConstant: 50),
            rightButton.heightAnchor.constraint(equalToConstant: 100),
            rightButton.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -15),
            rightButton.centerYAnchor.constraint(equalTo: sceneView.centerYAnchor),
            sceneView.leftAnchor.constraint(equalTo: view.leftAnchor),
            sceneView.rightAnchor.constraint(equalTo: view.rightAnchor),
            sceneView.topAnchor.constraint(equalTo: showDual ? dualButton.bottomAnchor : titleLabel.bottomAnchor),
            sceneView.bottomAnchor.constraint(equalTo: properties.topAnchor),
            properties.leftAnchor.constraint(equalTo: view.leftAnchor),
            properties.rightAnchor.constraint(equalTo: view.rightAnchor),
            properties.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor), 
            properties.heightAnchor.constraint(equalToConstant: 100),
        ])

        leftButton.addTarget(self, action: #selector(left), for: .touchUpInside)
        rightButton.addTarget(self, action: #selector(right), for: .touchUpInside)
        dualButton.addTarget(self, action: #selector(dual), for: .touchUpInside)

        // Camera setup
        renderer.cameraPosition = Vec3D(0, -6, 3)
        renderer.focusPoint = Vec3D(0, 0, 0)
        renderer.windowSize = CGSize(width: 3, height: 3)
        renderer.upAxis = Vec3D(0, 1, 0)

        set(scene: scenes[0])
        sceneView.rotationCenter = { self.currentSolid.center.value }
    }

    /// Add a solid to the screen.
    private func set(scene: Scene, labelsOnly: Bool = false) {
        UIView.transition(with: titleLabel, duration: 0.6, options: .transitionCrossDissolve) {
            self.titleLabel.text = scene.name
        }

        UIView.transition(with: properties, duration: 0.4, options: .transitionCrossDissolve) {
            self.properties.vertices.setValue(scene.info.vertices)
            self.properties.edges.setValue(scene.info.edges)
            self.properties.faces.setValue(scene.info.faces)
            self.properties.symmetries.setValue(scene.info.symmetries)
        }

        let dualColor = scenes[[0, 2, 1, 4, 3][sceneIndex]].color
        UIView.transition(with: dualButton, duration: 0.6, options: .transitionCrossDissolve) {
            self.dualButton.setTitleColor(dualColor, for: .normal)
        }

        if labelsOnly { return }

        currentSolid = scene.makeSolid(style(for: scene))
        currentSolid.scale(by: 1.0 / currentSolid.radius)
        currentSolid.add(to: renderer)
        sceneView.vecs += currentSolid.verticesAndCenter
    }

    private func style(for scene: Scene) -> PlatonicSolid.Style {
        scene.info.vertices > 10 ?
            PlatonicSolid.Style(pointRadius: .real(0.03), lineWidth: .real(0.01), color: scene.color) :
            PlatonicSolid.Style(pointRadius: .real(0.04), lineWidth: .real(0.015), color: scene.color)
    }

    /// Animate to a new scene.
    private func animate(to newScene: Scene, rotatesRight: Bool) {
        let old = currentSolid!
        let factor: Double = rotatesRight ? 1 : -1

        set(scene: newScene)

        // Continue finger-rotation of old solid
        sceneView.rotationCenter = { old.center.value }

        // Move new solid to starting position, then rotate everything 180°
        let rot = Rotation(axis: Vec3D(0, 0.5, 1), angle: factor * .pi, through: Vec3D(0, 2, -1))
        currentSolid.verticesAndCenter.forEach { $0.rotate(by: rot) }

        let anim = RotationAnimation(axis: rot.axis, angle: -rot.angle, through: rot.center, vecs: sceneView.vecs, duration: 1.3, curve: Curve.easeInOut) {
            old.remove(from: self.renderer)
            self.sceneView.vecs = self.currentSolid.verticesAndCenter
            self.sceneView.rotationCenter = { self.currentSolid.center.value }
            self.isAnimatingTransition = false
        }
        let fade = FadeInOutAnimation(fadeIn: currentSolid.nodes, fadeOut: old.nodes, duration: 1.3, fadeInCurve: Curve.linear, fadeOutCurve: Curve.linear)
        renderer.start(anim, fade)
    }

    @objc private func left() {
        if isAnimatingTransition { return }
        isAnimatingTransition = true

        // Move to next scene
        sceneIndex = (sceneIndex + scenes.count - 1) % scenes.count
        let scene = scenes[sceneIndex]

        animate(to: scene, rotatesRight: false)
    }

    @objc private func right() {
        if isAnimatingTransition { return }
        isAnimatingTransition = true

        // Move to next scene
        sceneIndex = (sceneIndex + 1) % scenes.count
        let scene = scenes[sceneIndex]

        animate(to: scene, rotatesRight: true)
    }

    @objc private func dual() {
        if isAnimatingTransition { return }
        isAnimatingDual = true

        // Update scene index
        sceneIndex = [0, 2, 1, 4, 3][sceneIndex]
        let newScene = scenes[sceneIndex]
        set(scene: newScene, labelsOnly: true)

        // Create dual solid; add it piece by piece
        let dual = currentSolid.dual(style: style(for: newScene))
        let points = dual.nodes.filter { $0 is PointNode }
        let lines = dual.nodes.filter { $0 is LineNode }

        // Dim all nodes of the dual
        let alwaysMasked: (masked: Float, normal: Float) = (masked: 0.25, normal: 0.25)
        let normal: (masked: Float, normal: Float) = (masked: 0.25, normal: 1)
        dual.nodes.forEach { $0.maskednessOpacityValues = alwaysMasked }

        // Add points immediately
        points.forEach(renderer.add(node:))
        sceneView.vecs += dual.verticesAndCenter
        sceneView.swipeAnimation?.vecs += dual.verticesAndCenter
        renderer.render()

        // Fade in lines after 1 sec
        let anim = FadeInOutAnimation(fadeIn: lines, fadeOut: [], duration: 0.8, animationHasFinished: {
            let scale = ScaleAnimation(vecs: self.currentSolid.vertices + dual.vertices, scaleCenter: dual.center.value, scaleFactor: 1.0 / dual.radius, duration: 1, curve: Curve.easeInOut)
            let fade = FadeInOutAnimation(fadeIn: [], fadeOut: self.currentSolid.nodes, duration: 0.8, animationHasFinished: {
                after(0.2) {
                    // Replace currentSolid, add new solid to renderer
                    self.currentSolid.remove(from: self.renderer)
                    self.renderer.faces = dual.faces
                    self.sceneView.vecs = dual.verticesAndCenter
                    self.currentSolid = dual

                    // Fade unmasked nodes to full opacity
                    let anim = ChangeMaskednessOpacityAnimation(nodes: dual.nodes, startValue: alwaysMasked, endValue: normal, duration: 0.8, animationHasFinished: {
                        self.isAnimatingDual = false
                    })
                    self.renderer.start(anim)
                }
            })

            self.renderer.start(scale, fade)
        })

        after(0.8) {
            lines.forEach(self.renderer.add(node:))
            lines.forEach { $0.opacity = 0 }
            self.renderer.start(anim)
        }
    }
}

fileprivate func after(_ delay: Double, block: @escaping () -> Void) {
    DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(Int(1000 * delay))) {
        block()
    }
}
