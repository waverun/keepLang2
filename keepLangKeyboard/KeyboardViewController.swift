import UIKit

class KeyboardViewController: UIInputViewController {

    @IBOutlet var nextKeyboardButton: UIButton!

    let englishAlphabets = [
        "QWERTYUIOP",
        "ASDFGHJKL",
        "ZXCVBNM"
    ].map { $0.lowercased() } // We start with lowercase English keyboard

    let hebrewAlphabets = [
        "קראטוןםפ",
        "שדגכעיחלך",
        "זסבהנמצתץ"
    ]

    let numbers = "1234567890"

    var alphabets = [String]()
    var stackViews = [UIStackView]()
    var shiftMode = false

    override func viewDidLoad() {
        super.viewDidLoad()

        alphabets = englishAlphabets // Default to English keyboard

        // Add this line to set a height constraint
        self.inputView?.addConstraint(NSLayoutConstraint(item: self.inputView!, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 260))

        setupKeyboard()
    }

    override func updateViewConstraints() {
        setupConstraints()
        super.updateViewConstraints()
    }

    func setupKeyboard() {
        for stackView in stackViews {
            stackView.removeFromSuperview()
        }
        stackViews.removeAll()

        for row in alphabets {
            let stackView = createStackView(with: Array(row))
            view.addSubview(stackView)
            stackViews.append(stackView)
        }

        // Adding the shift button to the last row of letters
        let shiftButton = createButton(title: "⇧")
        shiftButton.addTarget(self, action: #selector(shiftPressed), for: .touchUpInside)
        stackViews[stackViews.count - 1].insertArrangedSubview(shiftButton, at: 0)

        let numberStackView = createStackView(with: Array(numbers))
        view.addSubview(numberStackView)
        stackViews.append(numberStackView)

        let spaceReturnStackView = UIStackView()
        spaceReturnStackView.translatesAutoresizingMaskIntoConstraints = false

        let switchButton = createButton(title: "Switch")
        switchButton.addTarget(self, action: #selector(switchPressed), for: .touchUpInside)
        spaceReturnStackView.addArrangedSubview(switchButton)

        let spaceButton = createButton(title: "Space")
        spaceButton.addTarget(self, action: #selector(spacePressed), for: .touchUpInside)
        spaceReturnStackView.addArrangedSubview(spaceButton)

        let returnButton = createButton(title: "Return")
        returnButton.addTarget(self, action: #selector(returnPressed), for: .touchUpInside)
        spaceReturnStackView.addArrangedSubview(returnButton)

        view.addSubview(spaceReturnStackView)
        stackViews.append(spaceReturnStackView)
    }

    func setupConstraints() {
        for (index, stackView) in stackViews.enumerated() {
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
            stackView.heightAnchor.constraint(equalToConstant: 40).isActive = true

            if index == 0 {
                stackView.topAnchor.constraint(equalTo: view.topAnchor, constant: 20).isActive = true
            } else {
                stackView.topAnchor.constraint(equalTo: stackViews[index-1].bottomAnchor).isActive = true
            }
        }
    }

    func createStackView(with characters: [Character]) -> UIStackView {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.distribution = .fillEqually

        for character in characters {
            let button = createButton(title: String(character))
            button.translatesAutoresizingMaskIntoConstraints = false
            button.addTarget(self, action: #selector(keyPressed), for: .touchUpInside)

            let container = UIView()
            container.translatesAutoresizingMaskIntoConstraints = false
            container.addSubview(button)

            NSLayoutConstraint.activate([
                button.topAnchor.constraint(equalTo: container.topAnchor, constant: 8),
                button.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -8),
                button.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 6),
                button.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -6)
            ])

            stackView.addArrangedSubview(container)
        }

        return stackView
    }

//    func createStackView(with characters: [Character]) -> UIStackView {
//        let stackView = UIStackView()
//        stackView.translatesAutoresizingMaskIntoConstraints = false
//        stackView.distribution = .fillEqually
//        for character in characters {
//            let button = createButton(title: String(character))
//            button.addTarget(self, action: #selector(keyPressed), for: .touchUpInside)
//            stackView.addArrangedSubview(button)
//        }
//        return stackView
//    }

    func createButton(title: String) -> UIButton {
        let button = UIButton(type: .system)
        button.setTitle(title, for: [])
        button.backgroundColor = UIColor.white
        button.setTitleColor(UIColor.black, for: .normal)
        button.layer.cornerRadius = 5
        button.layer.masksToBounds = true
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }

    @objc func keyPressed(_ sender: UIButton) {
        guard let key = sender.title(for: []) else { return }
        (textDocumentProxy as UIKeyInput).insertText("\(key)")
    }

    @objc func spacePressed() {
        (textDocumentProxy as UIKeyInput).insertText(" ")
    }

    @objc func returnPressed() {
        (textDocumentProxy as UIKeyInput).insertText("\n")
    }

    @objc func switchPressed() {
        if alphabets == englishAlphabets {
            alphabets = hebrewAlphabets
        } else {
            alphabets = englishAlphabets
        }

        setupKeyboard()
        setupConstraints()
    }

    @objc func shiftPressed() {
        shiftMode.toggle() // Switches between true and false each time it's pressed

        // Update the characters of the alphabets
        if shiftMode {
            alphabets = alphabets.map { $0.uppercased() }
        } else {
            alphabets = alphabets.map { $0.lowercased() }
        }

        setupKeyboard()
        setupConstraints()
    }
}
