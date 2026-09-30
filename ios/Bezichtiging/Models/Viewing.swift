import Foundation

enum ViewingType: String, Codable, CaseIterable, Sendable {
    case woning, appartement
    var label: String { self == .woning ? "Woning" : "Appartement" }
    var systemImage: String { self == .woning ? "house" : "building.2" }
}

enum Tenure: String, Codable, CaseIterable, Sendable {
    case koop, huur
    var label: String { self == .koop ? "Koop" : "Huur" }
    var longLabel: String { self == .koop ? "Te koop" : "Te huur" }
    var systemImage: String { self == .koop ? "key" : "tag" }
}

enum Rating: String, Codable, Sendable {
    case goed, niet, na
    var label: String {
        switch self { case .goed: "In orde"; case .niet: "Aandacht"; case .na: "N.v.t." }
    }
    var reportBadge: String {
        let dutch = Market.isDeviceLanguageDutch
        switch self {
        case .goed: return dutch ? "In orde" : "Good"
        case .niet: return dutch ? "Aandacht" : "Attention"
        case .na:   return dutch ? "N.v.t." : "N/A"
        }
    }
}

struct Viewing: Identifiable, Codable, Sendable {
    var id: UUID
    var name: String
    var type: ViewingType
    var tenure: Tenure
    var date: Date
    var answers: [String: Rating]
    var notes: [String: String]
    var photoIds: [String: [String]]       // entryId → [photoId, …] (max 2)
    var itemPhotoIds: [String: [String]]   // itemKey → [photoId, …] (max 2)
    var itemNotes: [String: String]        // itemKey → short note
    var market: Market

    private enum CodingKeys: String, CodingKey {
        case id, name, type, tenure, date, answers, notes, photoIds, itemPhotoIds, itemNotes, market
    }

    init(name: String, type: ViewingType, tenure: Tenure, market: Market = .nl) {
        id = UUID(); self.name = name; self.type = type; self.tenure = tenure
        date = Date(); answers = [:]; notes = [:]; photoIds = [:]
        itemPhotoIds = [:]; itemNotes = [:]; self.market = market
    }

    init(id: UUID, name: String, type: ViewingType, tenure: Tenure, date: Date,
         answers: [String: Rating], notes: [String: String], market: Market = .nl) {
        self.id = id; self.name = name; self.type = type; self.tenure = tenure
        self.date = date; self.answers = answers; self.notes = notes
        self.photoIds = [:]; self.itemPhotoIds = [:]; self.itemNotes = [:]; self.market = market
    }

    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        id           = try c.decode(UUID.self,                 forKey: .id)
        name         = try c.decode(String.self,               forKey: .name)
        type         = try c.decode(ViewingType.self,          forKey: .type)
        tenure       = try c.decode(Tenure.self,               forKey: .tenure)
        date         = try c.decode(Date.self,                 forKey: .date)
        answers      = try c.decode([String: Rating].self,     forKey: .answers)
        notes        = try c.decode([String: String].self,     forKey: .notes)
        photoIds     = try c.decodeIfPresent([String: [String]].self, forKey: .photoIds)     ?? [:]
        itemPhotoIds = try c.decodeIfPresent([String: [String]].self, forKey: .itemPhotoIds) ?? [:]
        itemNotes    = try c.decodeIfPresent([String: String].self,   forKey: .itemNotes)    ?? [:]
        market       = try c.decodeIfPresent(Market.self,      forKey: .market) ?? .nl
    }

    var score: (goed: Int, niet: Int, total: Int) {
        let goed = answers.values.filter { $0 == .goed }.count
        let total = answers.values.filter { $0 == .goed || $0 == .niet }.count
        return (goed, total - goed, total)
    }
}
