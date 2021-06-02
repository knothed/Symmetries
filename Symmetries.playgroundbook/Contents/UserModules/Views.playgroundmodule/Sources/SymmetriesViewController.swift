import ThreeD
import UIKit

public protocol SymmetriesDelegate: class {
    var renderer: Renderer! { get set }
    func image(for buttonIndex: Int) -> UIImage // buttonIndex is in {0, ..., 7}
    func buttonTapped(index: Int) // index is in {0, ..., 7}
    func reset()
    var buttonColor: UIColor { get }
}

public class SymmetriesViewController: UIViewController {
    public let hostView = RenderHostView()
    private let buttons: SymmetriesButtonsView
    private let resetButton = UIButton()
    private let delegate: SymmetriesDelegate

    public init(delegate: SymmetriesDelegate) {
        self.delegate = delegate
        delegate.renderer = hostView.renderer
        buttons = SymmetriesButtonsView(delegate: delegate)
        super.init(nibName: nil, bundle: nil)
    }

    public required init?(coder: NSCoder) {
        fatalError()
    }

    public override func viewDidLoad() {
        view.backgroundColor = .white
        view.addSubview(hostView)
        view.addSubview(buttons)
        view.addSubview(resetButton)

        resetButton.setTitle("Reset to default", for: .normal)
        resetButton.setTitleColor(delegate.buttonColor, for: .normal)
        resetButton.titleLabel?.font = UIFont.systemFont(ofSize: 25, weight: .thin)
        resetButton.titleLabel?.adjustsFontSizeToFitWidth = true
        resetButton.titleLabel?.minimumScaleFactor = 0.5
        resetButton.addTarget(self, action: #selector(tappedReset), for: .touchUpInside)

        hostView.translatesAutoresizingMaskIntoConstraints = false
        buttons.translatesAutoresizingMaskIntoConstraints = false
        resetButton.translatesAutoresizingMaskIntoConstraints = false

        let w1 = buttons.widthAnchor.constraint(lessThanOrEqualToConstant: 380)
        let w2 = buttons.widthAnchor.constraint(lessThanOrEqualTo: view.widthAnchor)
        w1.priority = w2.priority - 1
        NSLayoutConstraint.activate([
            buttons.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 5),
            buttons.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            w1, w2,
            buttons.heightAnchor.constraint(equalToConstant: 200),
            buttons.heightAnchor.constraint(lessThanOrEqualTo: hostView.heightAnchor),
            hostView.topAnchor.constraint(equalTo: buttons.bottomAnchor),
            hostView.leftAnchor.constraint(equalTo: view.leftAnchor),
            hostView.rightAnchor.constraint(equalTo: view.rightAnchor),
            hostView.bottomAnchor.constraint(equalTo: resetButton.topAnchor),
            resetButton.leftAnchor.constraint(equalTo: view.leftAnchor),
            resetButton.rightAnchor.constraint(equalTo: view.rightAnchor),
            resetButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -15),
            resetButton.heightAnchor.constraint(equalToConstant: 45)
        ])
    }

    @objc private func tappedReset() {
        delegate.reset()
    }
}
