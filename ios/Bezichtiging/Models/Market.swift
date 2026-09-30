import Foundation

enum Market: String, CaseIterable, Codable, Sendable {
    case nl, uk, us

    var label: String {
        switch self { case .nl: "Nederland"; case .uk: "United Kingdom"; case .us: "United States" }
    }
    var flag: String {
        switch self { case .nl: "🇳🇱"; case .uk: "🇬🇧"; case .us: "🇺🇸" }
    }
    var isEnglish: Bool { self == .uk || self == .us }

    // Markets always shown in onboarding regardless of language.
    static let onboardingMarkets: [Market] = [.nl, .us, .uk]

    static var detected: Market {
        let id = Locale.current.region?.identifier ?? ""
        if id == "GB" { return .uk }
        if id == "US" { return .us }
        return .nl
    }

    // True when the device's primary language is Dutch. Drives all in-app UI language
    // decisions independently of whichever market the user selected for their checklist.
    static var isDeviceLanguageDutch: Bool {
        Locale.preferredLanguages.first?.hasPrefix("nl") == true
    }

    // Dutch device language → NL default; everything else → US.
    // Accepts an injectable list so this logic can be unit-tested.
    static func onboardingDefault(preferredLanguages: [String] = Locale.preferredLanguages) -> Market {
        preferredLanguages.first?.hasPrefix("nl") == true ? .nl : .us
    }
}
