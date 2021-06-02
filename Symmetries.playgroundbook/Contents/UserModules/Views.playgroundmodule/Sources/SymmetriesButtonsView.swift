import UIKit

/// `SymmetriesButtonsView` displays 8 buttons, each of which triggers an action.
internal class SymmetriesButtonsView: UIView {
    private var buttons = [UIButton]()
    private let delegate: SymmetriesDelegate

    init(delegate: SymmetriesDelegate) {
        self.delegate = delegate
        super.init(frame: .zero)
        setupView()
    }

    private func setupView() {
        let bottom = UIStackView()
        bottom.axis = .horizontal
        bottom.distribution = .equalSpacing

        let top = UIStackView()
        top.axis = .horizontal
        top.distribution = .equalSpacing

        top.translatesAutoresizingMaskIntoConstraints = false
        bottom.translatesAutoresizingMaskIntoConstraints = false

        addSubview(bottom)
        addSubview(top)

        NSLayoutConstraint.activate([
            top.topAnchor.constraint(equalTo: topAnchor),
            top.leftAnchor.constraint(equalTo: leftAnchor),
            top.rightAnchor.constraint(equalTo: rightAnchor),
            top.bottomAnchor.constraint(equalTo: bottom.topAnchor),
            bottom.leftAnchor.constraint(equalTo: leftAnchor),
            bottom.rightAnchor.constraint(equalTo: rightAnchor),
            bottom.bottomAnchor.constraint(equalTo: bottomAnchor),
            bottom.heightAnchor.constraint(equalTo: top.heightAnchor),
        ])

        buttons = (0...7).map { index in
            let button = UIButton(type: .custom)
            button.tintColor = .gray
            button.setImage(delegate.image(for: index), for: .normal)
            NSLayoutConstraint.activate([button.widthAnchor.constraint(equalTo: button.heightAnchor)])
            button.addTarget(self, action: #selector(buttonTapped(button:)), for: .touchUpInside)
            return button
        }

        buttons[0..<4].forEach(top.addArrangedSubview(_:))
        buttons[4..<8].forEach(bottom.addArrangedSubview(_:))
    }

    @objc private func buttonTapped(button: UIButton) {
        let index = buttons.firstIndex(of: button)!
        delegate.buttonTapped(index: index)
    }

    required init?(coder: NSCoder) {
        fatalError()
    }
}
