import UIKit

class KeyboardViewController: UIInputViewController {

    @IBOutlet var nextKeyboardButton: UIButton!

    let alphabets = [
        "QWERTYUIOP",
        "ASDFGHJKL",
        "ZXCVBNM"
    ]
    let numbers = "1234567890"
    var stackViews = [UIStackView]()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Add this line to set a height constraint
        self.inputView?.addConstraint(NSLayoutConstraint(item: self.inputView!, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 260))

        for row in alphabets {
            let stackView = createStackView(with: Array(row))
            view.addSubview(stackView)
            stackViews.append(stackView)
        }

        let numberStackView = createStackView(with: Array(numbers))
        view.addSubview(numberStackView)
        stackViews.append(numberStackView)

        let spaceReturnStackView = UIStackView()
        spaceReturnStackView.translatesAutoresizingMaskIntoConstraints = false
        let spaceButton = createButton(title: "Space")
        spaceButton.addTarget(self, action: #selector(spacePressed), for: .touchUpInside)
        spaceReturnStackView.addArrangedSubview(spaceButton)

        let returnButton = createButton(title: "Return")
        returnButton.addTarget(self, action: #selector(returnPressed), for: .touchUpInside)
        spaceReturnStackView.addArrangedSubview(returnButton)

        view.addSubview(spaceReturnStackView)
        stackViews.append(spaceReturnStackView)
    }

    override func updateViewConstraints() {
        setupConstraints()
        super.updateViewConstraints()
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
            button.addTarget(self, action: #selector(keyPressed), for: .touchUpInside)
            stackView.addArrangedSubview(button)
        }
        return stackView
    }

    func createButton(title: String) -> UIButton {
        let button = UIButton(type: .system)
        button.setTitle(title, for: [])
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
}

//import UIKit
//
//class KeyboardViewController: UIInputViewController {
//
//    @IBOutlet var nextKeyboardButton: UIButton!
//
//    let alphabets = [
//        "QWERTYUIOP",
//        "ASDFGHJKL",
//        "ZXCVBNM"
//    ]
//    let numbers = "1234567890"
//
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        // Add this line to set a height constraint
//        self.inputView?.addConstraint(NSLayoutConstraint(item: self.inputView!, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 260))
//
//        let width = UIScreen.main.bounds.width
//        let height = CGFloat(40.0)
//
//        var yPosition = CGFloat(20)
//        for row in alphabets {
//            let stackView = createStackView(with: Array(row), at: CGRect(x: 0, y: yPosition, width: width, height: height))
//            view.addSubview(stackView)
//            yPosition += height
//        }
//
//        let numberStackView = createStackView(with: Array(numbers), at: CGRect(x: 0, y: yPosition, width: width, height: height))
//        view.addSubview(numberStackView)
//        yPosition += height
//
//        let spaceReturnStackView = UIStackView(frame: CGRect(x: 0, y: yPosition, width: width, height: height))
//        let spaceButton = createButton(title: "Space")
//        spaceButton.addTarget(self, action: #selector(spacePressed), for: .touchUpInside)
//        spaceReturnStackView.addArrangedSubview(spaceButton)
//
//        let returnButton = createButton(title: "Return")
//        returnButton.addTarget(self, action: #selector(returnPressed), for: .touchUpInside)
//        spaceReturnStackView.addArrangedSubview(returnButton)
//
//        view.addSubview(spaceReturnStackView)
//    }
//
//    func createStackView(with characters: [Character], at frame: CGRect) -> UIStackView {
//        let stackView = UIStackView(frame: frame)
//        stackView.distribution = .fillEqually
//        for character in characters {
//            let button = createButton(title: String(character))
//            button.addTarget(self, action: #selector(keyPressed), for: .touchUpInside)
//            stackView.addArrangedSubview(button)
//        }
//        return stackView
//    }
//
//    func createButton(title: String) -> UIButton {
//        let button = UIButton(type: .system)
//        button.setTitle(title, for: [])
//        button.sizeToFit()
//        button.translatesAutoresizingMaskIntoConstraints = false
//        return button
//    }
//
//    @objc func keyPressed(_ sender: UIButton) {
//        guard let key = sender.title(for: []) else { return }
//        (textDocumentProxy as UIKeyInput).insertText("\(key)")
//    }
//
//    @objc func spacePressed() {
//        (textDocumentProxy as UIKeyInput).insertText(" ")
//    }
//
//    @objc func returnPressed() {
//        (textDocumentProxy as UIKeyInput).insertText("\n")
//    }
//}

//import UIKit
//
//class KeyboardViewController: UIInputViewController {
//
//    @IBOutlet var nextKeyboardButton: UIButton!
//
//    override func updateViewConstraints() {
//        super.updateViewConstraints()
//
//        // Add custom view sizing constraints here
//    }
//
//    override func viewDidLoad() {
//        super.viewDidLoad()
//
//        // Perform custom UI setup here
//        self.nextKeyboardButton = UIButton(type: .system)
//
//        // Add this line to set a height constraint
//        self.inputView?.addConstraint(NSLayoutConstraint(item: self.inputView!, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 260))
//
//        self.nextKeyboardButton.setTitle(NSLocalizedString("Next Keyboard", comment: "Title for 'Next Keyboard' button"), for: [])
//        self.nextKeyboardButton.sizeToFit()
//        self.nextKeyboardButton.translatesAutoresizingMaskIntoConstraints = false
//
//        self.nextKeyboardButton.addTarget(self, action: #selector(handleInputModeList(from:with:)), for: .allTouchEvents)
//
//        self.view.addSubview(self.nextKeyboardButton)
//
//        self.nextKeyboardButton.leftAnchor.constraint(equalTo: self.view.leftAnchor).isActive = true
//        self.nextKeyboardButton.bottomAnchor.constraint(equalTo: self.view.bottomAnchor).isActive = true
//    }
//
//    override func viewWillLayoutSubviews() {
//        self.nextKeyboardButton.isHidden = !self.needsInputModeSwitchKey
//        super.viewWillLayoutSubviews()
//    }
//
//    override func textWillChange(_ textInput: UITextInput?) {
//        // The app is about to change the document's contents. Perform any preparation here.
//    }
//
//    override func textDidChange(_ textInput: UITextInput?) {
//        // The app has just changed the document's contents, the document context has been updated.
//
//        var textColor: UIColor
//        let proxy = self.textDocumentProxy
//        if proxy.keyboardAppearance == UIKeyboardAppearance.dark {
//            textColor = UIColor.white
//        } else {
//            textColor = UIColor.black
//        }
//        self.nextKeyboardButton.setTitleColor(textColor, for: [])
//    }
//}
