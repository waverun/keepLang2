import UIKit

class CustomActionView: UIView {

    // The completion handler will be triggered when a button is pressed.
    var completionHandler: ((String) -> Void)?

    init(languages: [String]) {
        super.init(frame: CGRect.zero)

        self.backgroundColor = .white
        self.layer.cornerRadius = 10

        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.distribution = .fillEqually
        stackView.spacing = 10
        stackView.translatesAutoresizingMaskIntoConstraints = false

        self.addSubview(stackView)

        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: self.topAnchor, constant: 10),
            stackView.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -10),
            stackView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 10),
            stackView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -10),
        ])

        for language in languages {
            let button = UIButton(type: .system)
            button.setTitle(language, for: .normal)
            button.addTarget(self, action: #selector(buttonPressed), for: .touchUpInside)
            stackView.addArrangedSubview(button)
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    @objc private func buttonPressed(sender: UIButton) {
        if let language = sender.title(for: .normal) {
            completionHandler?(language)
        }
    }
}
