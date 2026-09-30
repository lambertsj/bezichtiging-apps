import Foundation

// MARK: – Address

/// A Dutch address as the risk scanner needs it. Comes from a PDOK suggestion.
struct ScanAddress: Codable, Hashable, Sendable {
    var label: String
    var postcode: String
    var huisnummer: Int
    var huisletter: String?
    var toevoeging: String?

    private enum CodingKeys: String, CodingKey {
        case label = "weergavenaam", postcode, huisnummer, huisletter
        case toevoeging = "huisnummertoevoeging"
    }
}

// MARK: – Scan result (mirrors worker/src/risico/kaarten.js)

struct RiskScanResult: Codable, Sendable {
    struct Address: Codable, Sendable {
        let regel: String
        let postcode: String
        let woonplaats: String
        let bouwjaar: Int?
        let oppervlakte: Int?
        let woonfunctie: Bool
    }
    let adres: Address
    let kaarten: [RiskCard]
}

struct RiskCard: Codable, Identifiable, Sendable {
    enum Section: String, Codable, CaseIterable, Sendable {
        case bouwkundig, milieu, juridisch
        var title: String {
            switch self {
            case .bouwkundig: "Bouwkundig"
            case .milieu: "Milieu en klimaat"
            case .juridisch: "Juridisch"
            }
        }
    }
    enum Status: String, Codable, Sendable {
        case ok, onbekend, mislukt
        case geenData = "geen_data"
    }
    enum Risk: String, Codable, Sendable { case laag, gemiddeld, hoog }

    let id: String
    let sectie: Section
    let titel: String
    let status: Status
    let waarde: String?
    let risico: Risk?
    let zekerheid: Double?
    let feiten: [String]
    /// Question for the makelaar. Only present when the flag warrants one.
    let vraag: String?
}

extension RiskScanResult {
    func cards(in section: RiskCard.Section) -> [RiskCard] {
        kaarten.filter { $0.sectie == section }
    }
    var questions: [String] { kaarten.compactMap(\.vraag) }
}

// MARK: – Client

struct RiskScanError: LocalizedError, Sendable {
    let message: String
    var errorDescription: String? { message }
}

struct RiskScanClient: Sendable {
    var endpoint = RiskScanClient.defaultEndpoint
    var session: URLSession = .shared

    static var defaultEndpoint: URL {
        #if DEBUG
        // Point at `wrangler dev` or a stub while developing.
        if let override = ProcessInfo.processInfo.environment["RISK_SCAN_ENDPOINT"],
           let url = URL(string: override) { return url }
        #endif
        return URL(string: "https://bezichtiging.app/api/risico")!
    }

    func scan(_ address: ScanAddress) async throws -> RiskScanResult {
        var request = URLRequest(url: endpoint, timeoutInterval: 15)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        var body: [String: String] = ["postcode": address.postcode, "huisnummer": String(address.huisnummer)]
        if let l = address.huisletter, !l.isEmpty { body["huisletter"] = l }
        if let t = address.toevoeging, !t.isEmpty { body["toevoeging"] = t }
        request.httpBody = try JSONEncoder().encode(body)

        let (data, response) = try await session.data(for: request)
        let status = (response as? HTTPURLResponse)?.statusCode ?? 0
        guard status == 200 else {
            // The worker always answers errors as {fout, melding} in Dutch.
            struct Failure: Decodable { let melding: String }
            let melding = (try? JSONDecoder().decode(Failure.self, from: data))?.melding
            throw RiskScanError(message: melding ?? "De risicoscan is niet gelukt. Probeer het nog een keer.")
        }
        return try JSONDecoder().decode(RiskScanResult.self, from: data)
    }

    /// Address autocomplete via PDOK Locatieserver: free, no key, built for type-ahead.
    /// Kadaster's BAG API is only called once, by the worker, on submit.
    func suggestions(for query: String) async throws -> [ScanAddress] {
        var components = URLComponents(string: "https://api.pdok.nl/bzk/locatieserver/search/v3_1/suggest")!
        components.queryItems = [
            URLQueryItem(name: "q", value: query),
            URLQueryItem(name: "fq", value: "type:adres"),
            URLQueryItem(name: "rows", value: "6"),
            URLQueryItem(name: "fl", value: "weergavenaam,postcode,huisnummer,huisletter,huisnummertoevoeging"),
        ]
        struct Envelope: Decodable {
            struct Response: Decodable { let docs: [ScanAddress] }
            let response: Response
        }
        let (data, _) = try await session.data(for: URLRequest(url: components.url!, timeoutInterval: 5))
        return try JSONDecoder().decode(Envelope.self, from: data).response.docs
    }
}
