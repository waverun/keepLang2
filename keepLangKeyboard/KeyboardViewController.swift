import UIKit
import AudioToolbox

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

    let germanAlphabets = [
        "QWERTZUIOPÜ",
        "ASDFGHJKLÖÄ",
        "YXCVBNM"
    ].map { $0.lowercased() }

    let specialSymbols = [
        "~`!@#$%^&*()",
        "-_=+[{]};:'\"",
        "<,>.?/|\\"
    ]

//    let generator = UIImpactFeedbackGenerator(style: .heavy)

    let numbers = "1234567890"

    var buttons: [UIButton] = []

    var alphabets = [String]()
    var stackViews = [UIStackView]()
    var shiftMode = false

    func isOpenAccessGranted() -> Bool {
        if #available(iOS 11.0, *) {
            return UIPasteboard.general.hasStrings
        } else {
            return UIPasteboard.general.isKind(of: UIPasteboard.self)
        }
    }

    // MARK: - Move cursor:

    func addPanGesttureRecognizer(spaceButton: UIButton) {
        let panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(handlePanGesture(_:)))
        view.addGestureRecognizer(panGestureRecognizer)
    }

    func changeButtonsAlpha(alpha: CGFloat) {
        for button in buttons {
            let currentColor = button.titleColor(for: .normal)
            let transparentColor = currentColor?.withAlphaComponent(alpha) // Set the opacity to your needs
            button.setTitleColor(transparentColor, for: .normal)
        }
    }

    @objc func handlePanGesture(_ recognizer: UIPanGestureRecognizer) {
        let maxVelocity: CGFloat = 1000  // Define your max velocity

        switch recognizer.state {
            case .began:
                changeButtonsAlpha(alpha: 0)
                vibrate()
            case .changed:
//                let translation = recognizer.translation(in: view)
                let velocity = recognizer.velocity(in: view)
                let currentVelocity = hypot(velocity.x, velocity.y)  // Get the magnitude of the velocity vector

                // Calculate a scale factor based on the current velocity.
                // The slower the movement (smaller velocity), the larger the scale.
                let scaleFactor = maxVelocity / (currentVelocity + 50)  // The "+ 50" prevents division by zero

                // Get the original translation
                var translation = recognizer.translation(in: view)

                // Apply the scale factor to the translation
                translation.x *= scaleFactor
                translation.y *= scaleFactor

                let cursorMovement = translation.x / 11 // Adjust this value to your needs

                // Calculate cursor movement based on translation
                let isMovingLeft = cursorMovement < 0
                let numberOfMovements = abs(Int(cursorMovement))
                print("handlePanGesture: changed: x: \(translation.x) numberOfMovements: \(numberOfMovements)")
                if numberOfMovements > 0 {
                    recognizer.setTranslation(.zero, in: view)
                }
                for _ in 0..<numberOfMovements {
                    if isMovingLeft {
                        textDocumentProxy.adjustTextPosition(byCharacterOffset: -1)
                    } else {
                        textDocumentProxy.adjustTextPosition(byCharacterOffset: 1)
                    }
                }
                recognizer.setTranslation(.zero, in: view) // Reset the pan gesture's translation
            case .ended:
                changeButtonsAlpha(alpha: 1)
            default: break
        }
    }

    // MARK: - Controller functions:

    override func viewDidLoad() {
        super.viewDidLoad()

        switch true {
            case isOpenAccessGranted(): print("Full access")
            default: print("No full access")
        }

        alphabets = englishAlphabets // Default to English keyboard

        // Add this line to set a height constraint
        self.inputView?.addConstraint(NSLayoutConstraint(item: self.inputView!, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 270))

        setupKeyboard()
    }

    override func viewDidAppear(_ animated: Bool) {
        let previousText = textDocumentProxy.documentContextBeforeInput ?? ""

        let followingText = textDocumentProxy.documentContextAfterInput ?? ""

        if let language = detectLanguage(text: previousText + followingText) {
            switch language {
                case "he": alphabets = hebrewAlphabets
                case "de": alphabets = germanAlphabets
                default: alphabets = englishAlphabets
            }
            setupKeyboard()
            setupConstraints()
        }
    }

    override func updateViewConstraints() {
        setupConstraints()
        super.updateViewConstraints()
    }

    func vibrate() {
        //        DispatchQueue.main.async { [weak self] in
        //        let generator = UIImpactFeedbackGenerator(style: .heavy)
        //        generator.prepare()
        //            self?.generator.impactOccurred()
        AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
        //        }
    }

    func setupKeyboard() {
        for stackView in stackViews {
            stackView.removeFromSuperview()
        }

        stackViews.removeAll()
        buttons.removeAll()

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
        spaceReturnStackView.distribution = .fill  // change the distribution
        spaceReturnStackView.spacing = 6  // add spacing between buttons

        let switchButton = createButtonWithImage(systemName: "globe")
        setupButtonWidth(button: switchButton, width: 60) // Adjust the width to your desired size
        switchButton.addTarget(self, action: #selector(switchPressed), for: .touchUpInside)
        switchButton.setContentHuggingPriority(.defaultHigh, for: .horizontal)  // set high hugging priority
        let longPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(switchLongPressed))
        switchButton.addGestureRecognizer(longPressGestureRecognizer)
        spaceReturnStackView.addArrangedSubview(switchButton)

        let spaceButton = createButton(title: "Space")
        spaceButton.addTarget(self, action: #selector(spacePressed), for: .touchUpInside)
        spaceButton.setContentHuggingPriority(.defaultLow, for: .horizontal)  // set low hugging priority
        spaceReturnStackView.addArrangedSubview(spaceButton)
        addPanGesttureRecognizer(spaceButton: spaceButton)

        let returnButton = createButtonWithImage(systemName: "return.right")
        setupButtonWidth(button: returnButton, width: 60) // Adjust the width to your desired size
        returnButton.addTarget(self, action: #selector(returnPressed), for: .touchUpInside)
        returnButton.setContentHuggingPriority(.defaultHigh, for: .horizontal)  // set high hugging priority
        spaceReturnStackView.addArrangedSubview(returnButton)

        let deleteButton = createButtonWithImage(systemName: "delete." + (alphabets == hebrewAlphabets ? "right" : "left"))
        deleteButton.addTarget(self, action: #selector(deletePressed), for: .touchUpInside)
        let deleteKeyRow = shortestRowInd()
        stackViews[deleteKeyRow].insertArrangedSubview(deleteButton, at: stackViews[deleteKeyRow].arrangedSubviews.count)

        view.addSubview(spaceReturnStackView)
        stackViews.append(spaceReturnStackView)

        let leadingConstraint = spaceReturnStackView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 6)
        let trailingConstraint = spaceReturnStackView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -6)
        NSLayoutConstraint.activate([leadingConstraint, trailingConstraint])
    }

    func shortestRowInd() -> Int {
        var smallestRowInd = 0
        var shortestCount = Int.max

        for (index, row) in stackViews.enumerated() {
            let totalArrangedSubviews = row.arrangedSubviews.count
            if  totalArrangedSubviews < shortestCount {
                shortestCount = totalArrangedSubviews
                smallestRowInd = index
            }
        }

        return smallestRowInd
    }

    @objc func deletePressed() {
        (textDocumentProxy as UIKeyInput).deleteBackward()
    }

    func setupConstraints() {
        for (index, stackView) in stackViews.enumerated() {
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 6).isActive = true
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -6).isActive = true
            stackView.heightAnchor.constraint(equalToConstant: 50).isActive = true

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
                button.topAnchor.constraint(equalTo: container.topAnchor, constant: 4),
                button.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -4),
                button.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 4),
                button.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -4)
            ])

            stackView.addArrangedSubview(container)
        }

        return stackView
    }

    func createButton(title: String) -> UIButton {
        let button = UIButton(type: .system)
        button.setTitle(title, for: [])
        button.backgroundColor = UIColor.white
        button.setTitleColor(UIColor.black, for: .normal)
        button.layer.cornerRadius = 5
        button.layer.masksToBounds = true
        button.translatesAutoresizingMaskIntoConstraints = false

        // Set a larger font size for the button title
        button.titleLabel?.font = UIFont.systemFont(ofSize: 24)

        buttons.append(button)

        return button
    }

    func createButtonWithImage(systemName: String) -> UIButton {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: systemName)?.withRenderingMode(.alwaysOriginal), for: .normal)

        button.backgroundColor = UIColor.white
        button.layer.cornerRadius = 5
        button.layer.masksToBounds = true
        button.translatesAutoresizingMaskIntoConstraints = false

        return button
    }

    func setupButtonWidth(button: UIButton, width: CGFloat) {
        let widthConstraint = button.widthAnchor.constraint(equalToConstant: width)
        widthConstraint.priority = UILayoutPriority.defaultHigh // 750, less than required (1000)
        widthConstraint.isActive = true
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
        switch true {
            case alphabets == englishAlphabets:
                alphabets = hebrewAlphabets
            case alphabets == hebrewAlphabets:
                alphabets = germanAlphabets
            case alphabets == germanAlphabets:
                alphabets = specialSymbols
            default:
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

    @objc func handleTap(_ sender: UITapGestureRecognizer) {
        if let actionView = self.view.subviews.first(where: { $0 is CustomActionView }) {
            let location = sender.location(in: self.view)
            if !actionView.frame.contains(location) {
                actionView.removeFromSuperview()
                if let recognizer = self.view.gestureRecognizers?.first(where: { $0.name == "TapToRemoveActionView" }) {
                    self.view.removeGestureRecognizer(recognizer)
                }
            }
        }
    }

    @objc func switchLongPressed(_ sender: UILongPressGestureRecognizer) {
        func addTapView() {
            let tap = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
            tap.cancelsTouchesInView = false  // Allow other button actions to be triggered
            self.view.addGestureRecognizer(tap)
            tap.name = "TapToRemoveActionView"
        }

        if sender.state == .began {
            let actionView = CustomActionView(languages: ["English", "Hebrew", "German", "Special Symbols"])
            actionView.translatesAutoresizingMaskIntoConstraints = false
            actionView.completionHandler = { language in
                switch language {
                    case "English":
                        self.alphabets = self.englishAlphabets
                    case "Hebrew":
                        self.alphabets = self.hebrewAlphabets
                    case "German":
                        self.alphabets = self.germanAlphabets
                    case "Special Symbols":
                        self.alphabets = self.specialSymbols
                    default:
                        break
                }
                actionView.removeFromSuperview()
                self.setupKeyboard()
                self.setupConstraints()
            }

            self.view.addSubview(actionView)
            addTapView()

            NSLayoutConstraint.activate([
                actionView.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
                actionView.centerYAnchor.constraint(equalTo: self.view.centerYAnchor),
                actionView.widthAnchor.constraint(equalToConstant: 200),
                actionView.heightAnchor.constraint(equalToConstant: 150)
            ])
        }
    }
}
