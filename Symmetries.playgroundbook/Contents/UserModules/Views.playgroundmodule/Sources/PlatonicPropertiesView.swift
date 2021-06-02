import UIKit

/// `PlatonicPropertiesView` displays three properties - vertices, edges and faces count - of a platonic solid, side by side.
internal class PlatonicPropertiesView: UIView {
    let vertices = PropertyView()
    let edges = PropertyView()
    let faces = PropertyView()
    let symmetries = PropertyView()

    init() {
        super.init(frame: .zero)
        setupView()
    }

    private func setupView() {
        let stack = UIStackView()
        addSubview(stack)
        stack.pin(to: self)

        stack.axis = .horizontal
        stack.distribution = .fillEqually
        stack.addArrangedSubview(vertices)
        stack.addArrangedSubview(edges)
        stack.addArrangedSubview(faces)
        stack.addArrangedSubview(symmetries)
        vertices.setTitle("Vertices")
        edges.setTitle("Edges")
        faces.setTitle("Faces")
        symmetries.setTitle("Symmetries")
    }

    required init?(coder: NSCoder) {
        fatalError()
    }
}

/// `PropertyView` contains two labels to display a single property and its value.
internal class PropertyView: UIView {
    private let titleLabel = UILabel()
    private let valueLabel = UILabel()

    /// Default initializer.
    init() {
        super.init(frame: .zero)

        let stack = UIStackView()
        addSubview(stack)
        stack.pin(to: self)

        stack.axis = .vertical
        stack.distribution = .fillEqually
        stack.addArrangedSubview(titleLabel)
        stack.addArrangedSubview(valueLabel)

        titleLabel.font = UIFont.systemFont(ofSize: 30, weight: .thin)
        titleLabel.adjustsFontSizeToFitWidth = true
        titleLabel.textAlignment = .center
        valueLabel.font = UIFont.systemFont(ofSize: 40, weight: .light)
        valueLabel.adjustsFontSizeToFitWidth = true
        valueLabel.textAlignment = .center
    }

    required init?(coder: NSCoder) {
        fatalError()
    }

    func setTitle(_ title: String) {
        titleLabel.text = "\(title)"
    }

    func setValue(_ value: Int) {
        valueLabel.text = "\(value)"
    }
}

internal extension UIView {
    func pin(to other: UIView) {
        translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            leftAnchor.constraint(equalTo: other.leftAnchor),
            rightAnchor.constraint(equalTo: other.rightAnchor),
            topAnchor.constraint(equalTo: other.topAnchor),
            bottomAnchor.constraint(equalTo: other.bottomAnchor),
        ])
    }
}
