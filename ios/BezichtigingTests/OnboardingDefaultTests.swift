import XCTest
@testable import Bezichtiging

final class OnboardingDefaultTests: XCTestCase {

    // MARK: - Market.onboardingDefault

    func testDutchLanguageDefaultsToNL() {
        XCTAssertEqual(Market.onboardingDefault(preferredLanguages: ["nl-NL"]), .nl)
    }

    func testDutchNLBEDefaultsToNL() {
        XCTAssertEqual(Market.onboardingDefault(preferredLanguages: ["nl-BE"]), .nl)
    }

    func testEnglishUSDefaultsToUS() {
        XCTAssertEqual(Market.onboardingDefault(preferredLanguages: ["en-US"]), .us)
    }

    func testEnglishGBDefaultsToUS() {
        XCTAssertEqual(Market.onboardingDefault(preferredLanguages: ["en-GB"]), .us)
    }

    func testFrenchDefaultsToUS() {
        XCTAssertEqual(Market.onboardingDefault(preferredLanguages: ["fr-FR"]), .us)
    }

    func testGermanDefaultsToUS() {
        XCTAssertEqual(Market.onboardingDefault(preferredLanguages: ["de-DE"]), .us)
    }

    func testEmptyLanguageListDefaultsToUS() {
        XCTAssertEqual(Market.onboardingDefault(preferredLanguages: []), .us)
    }

    // MARK: - Market.onboardingMarkets

    func testOnboardingMarketsContainsNL() {
        XCTAssertTrue(Market.onboardingMarkets.contains(.nl))
    }

    func testOnboardingMarketsContainsUS() {
        XCTAssertTrue(Market.onboardingMarkets.contains(.us))
    }

    func testOnboardingMarketsContainsUK() {
        XCTAssertTrue(Market.onboardingMarkets.contains(.uk))
    }

    func testOnboardingMarketsContainsAllThree() {
        XCTAssertEqual(Market.onboardingMarkets.count, 3)
    }

    // MARK: - App name

    func testAppNameDutchIsBezichtiging() {
        XCTAssertEqual(L.appName(.nl), "Bezichtiging")
    }

    func testAppNameUSIsHomeViewing() {
        XCTAssertEqual(L.appName(.us), "Home Viewing")
    }

    func testAppNameUKIsHomeViewing() {
        XCTAssertEqual(L.appName(.uk), "Home Viewing")
    }
}
