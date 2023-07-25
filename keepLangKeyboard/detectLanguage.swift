import NaturalLanguage

func detectLanguage(text: String) -> String? {
//    let text = "Your text to identify"
    let recognizer = NLLanguageRecognizer()
    recognizer.processString(text)

    let languageCode = recognizer.dominantLanguage?.rawValue
//        let language = Locale.current.localizedString(forIdentifier: languageCode)
//        print("The text is in \(language ?? "an unknown language")")
//        return langua
//    } else {
//        print("Could not recognize language")
//    }
    return languageCode
}
