import Foundation
import Observation

@Observable
@MainActor
final class ViewingStore {
    var viewings: [Viewing] = []
    var market: Market = .nl
    var hasCompletedOnboarding: Bool = false

    private let saveKey      = "bz.viewings.v2"
    private let marketKey    = "bz.market"
    private let onboardingKey = "bz.onboarded"

    init() {
        let storedMarket = UserDefaults.standard.string(forKey: marketKey)
        // Existing installs that already have a saved market are treated as onboarded.
        hasCompletedOnboarding = UserDefaults.standard.bool(forKey: onboardingKey) || storedMarket != nil
        if let raw = storedMarket, let m = Market(rawValue: raw) { market = m }
        load()
        #if DEBUG
        if viewings.isEmpty && hasCompletedOnboarding { viewings = Self.seedViewings; save() }
        #endif
    }

    func completeOnboarding(market m: Market) {
        market = m
        UserDefaults.standard.set(m.rawValue, forKey: marketKey)
        hasCompletedOnboarding = true
        UserDefaults.standard.set(true, forKey: onboardingKey)
        #if DEBUG
        if viewings.isEmpty { viewings = Self.seedViewings; save() }
        #endif
    }

    func setMarket(_ m: Market) {
        market = m
        UserDefaults.standard.set(m.rawValue, forKey: marketKey)
    }

    // MARK: – CRUD
    @discardableResult
    func create(name: String, type: ViewingType, tenure: Tenure) -> UUID {
        let v = Viewing(name: name, type: type, tenure: tenure, market: market)
        viewings.insert(v, at: 0)
        save()
        return v.id
    }

    func setAnswer(viewingId: UUID, key: String, rating: Rating?) {
        guard let i = viewings.firstIndex(where: { $0.id == viewingId }) else { return }
        if let r = rating { viewings[i].answers[key] = r }
        else { viewings[i].answers.removeValue(forKey: key) }
        save()
    }

    func delete(viewingId: UUID) {
        PhotoStore.deleteAll(viewingId: viewingId)
        viewings.removeAll { $0.id == viewingId }
        save()
    }

    func addPhoto(viewingId: UUID, entryId: String, photoId: String) {
        guard let i = viewings.firstIndex(where: { $0.id == viewingId }) else { return }
        var ids = viewings[i].photoIds[entryId] ?? []
        guard ids.count < 2 else { return }
        ids.append(photoId)
        viewings[i].photoIds[entryId] = ids
        save()
    }

    func removePhoto(viewingId: UUID, entryId: String, photoId: String) {
        guard let i = viewings.firstIndex(where: { $0.id == viewingId }) else { return }
        viewings[i].photoIds[entryId]?.removeAll { $0 == photoId }
        PhotoStore.delete(id: photoId, viewingId: viewingId)
        save()
    }

    func deleteAllViewings() {
        for v in viewings { PhotoStore.deleteAll(viewingId: v.id) }
        viewings = []
        save()
    }

    func setNote(viewingId: UUID, entryId: String, text: String) {
        guard let i = viewings.firstIndex(where: { $0.id == viewingId }) else { return }
        if text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            viewings[i].notes.removeValue(forKey: entryId)
        } else {
            viewings[i].notes[entryId] = text
        }
        save()
    }

    // MARK: – Item-level photos and notes (attached to individual checklist items)

    func addItemPhoto(viewingId: UUID, itemKey: String, photoId: String) {
        guard let i = viewings.firstIndex(where: { $0.id == viewingId }) else { return }
        var ids = viewings[i].itemPhotoIds[itemKey] ?? []
        guard ids.count < 2 else { return }
        ids.append(photoId)
        viewings[i].itemPhotoIds[itemKey] = ids
        save()
    }

    func removeItemPhoto(viewingId: UUID, itemKey: String, photoId: String) {
        guard let i = viewings.firstIndex(where: { $0.id == viewingId }) else { return }
        viewings[i].itemPhotoIds[itemKey]?.removeAll { $0 == photoId }
        PhotoStore.delete(id: photoId, viewingId: viewingId)
        save()
    }

    func setItemNote(viewingId: UUID, itemKey: String, text: String) {
        guard let i = viewings.firstIndex(where: { $0.id == viewingId }) else { return }
        if text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            viewings[i].itemNotes.removeValue(forKey: itemKey)
        } else {
            viewings[i].itemNotes[itemKey] = text
        }
        save()
    }

    // MARK: – Persistence
    private func save() {
        guard let data = try? JSONEncoder().encode(viewings) else { return }
        UserDefaults.standard.set(data, forKey: saveKey)
    }

    private func load() {
        guard let data = UserDefaults.standard.data(forKey: saveKey),
              let decoded = try? JSONDecoder().decode([Viewing].self, from: data)
        else { return }
        viewings = decoded
    }

    // MARK: – Seed data
    static let seedViewings: [Viewing] = {
        let fmt = DateFormatter(); fmt.dateFormat = "d MMM yyyy"; fmt.locale = Locale(identifier: "nl_NL")
        return [
            // 1 – Rijtjeswoning Eindhoven
            Viewing(id: UUID(uuidString: "00000000-0000-0000-0000-000000000001")!,
                    name: "Rijtjeswoning Eindhoven", type: .woning, tenure: .koop,
                    date: fmt.date(from: "22 mei 2026") ?? Date(),
                    answers: [
                        "bouwkundig-0": .goed, "bouwkundig-2": .goed, "bouwkundig-3": .goed,
                        "bouwkundig-4": .goed, "bouwkundig-5": .goed, "bouwkundig-6": .niet,
                        "bouwkundig-8": .goed, "bouwkundig-9": .goed,
                        "vocht-energie-0": .goed, "vocht-energie-1": .goed, "vocht-energie-2": .niet,
                        "vocht-energie-4": .goed, "vocht-energie-7": .goed, "vocht-energie-8": .goed,
                        "installaties-0": .goed, "installaties-1": .goed, "installaties-3": .goed,
                        "installaties-4": .goed, "installaties-5": .goed, "installaties-10": .goed,
                        "binnen-0": .goed, "binnen-2": .goed, "binnen-4": .goed,
                        "binnen-6": .niet, "binnen-10": .goed,
                        "locatie-0": .goed, "locatie-1": .goed, "locatie-4": .goed, "locatie-7": .goed,
                        "verkoper-0": .goed, "verkoper-2": .goed, "verkoper-5": .goed, "verkoper-8": .goed,
                        "historie-0": .goed, "historie-4": .goed, "historie-7": .goed,
                        "kosten-0": .goed, "kosten-1": .goed, "kosten-2": .goed, "kosten-3": .niet,
                        "gevoel-0": .goed, "gevoel-1": .goed, "gevoel-2": .goed, "gevoel-7": .goed,
                        "gevel-0": .goed, "gevel-1": .goed, "gevel-4": .goed, "gevel-8": .niet, "gevel-9": .goed,
                        "woonkamer-0": .goed, "woonkamer-2": .goed, "woonkamer-4": .goed, "woonkamer-7": .goed,
                        "keuken-0": .goed, "keuken-3": .goed, "keuken-6": .goed, "keuken-7": .goed,
                        "badkamer-0": .goed, "badkamer-2": .niet, "badkamer-5": .goed, "badkamer-8": .goed,
                        "slaapkamer-0": .goed, "slaapkamer-1": .goed, "slaapkamer-4": .goed,
                        "tuin-0": .goed, "tuin-3": .goed, "tuin-5": .goed, "tuin-6": .goed,
                    ],
                    notes: [
                        "bouwkundig": "Kozijnen voorzijde: houtrot onderzijde raamkozijn. Meenemen in onderhandeling of reparatie voor overdracht eisen.",
                        "badkamer": "Schimmel linkerbenedenhoek bij douche, ventilatie onvoldoende. Badkamerrenovatie inbegrepen in verbouwingsbudget ±€10k.",
                        "kosten": "Verbouwingskosten (badkamer + kozijnen) inbegrepen in bod. Vraagprijs overigens marktconform voor de wijk.",
                    ]),

            // 2 – Twee-onder-een-kapwoning Delft
            Viewing(id: UUID(uuidString: "00000000-0000-0000-0000-000000000002")!,
                    name: "Twee-onder-een-kapwoning Delft", type: .woning, tenure: .koop,
                    date: fmt.date(from: "15 mei 2026") ?? Date(),
                    answers: [
                        "bouwkundig-0": .niet, "bouwkundig-1": .niet, "bouwkundig-2": .niet,
                        "bouwkundig-4": .niet, "bouwkundig-5": .niet, "bouwkundig-6": .niet,
                        "bouwkundig-8": .niet, "bouwkundig-9": .niet,
                        "vocht-energie-0": .niet, "vocht-energie-1": .niet, "vocht-energie-2": .niet,
                        "vocht-energie-4": .niet, "vocht-energie-5": .niet, "vocht-energie-7": .niet,
                        "installaties-0": .goed, "installaties-1": .niet, "installaties-4": .niet,
                        "installaties-5": .niet, "installaties-7": .niet,
                        "binnen-0": .niet, "binnen-4": .niet, "binnen-6": .niet,
                        "locatie-0": .goed, "locatie-4": .goed, "locatie-6": .goed,
                        "verkoper-0": .goed, "verkoper-1": .niet, "verkoper-2": .niet,
                        "kosten-0": .niet, "kosten-2": .goed, "kosten-3": .niet,
                        "gevoel-0": .niet, "gevoel-2": .goed, "gevoel-3": .goed, "gevoel-7": .niet,
                        "gevel-0": .niet, "gevel-1": .niet, "gevel-4": .niet, "gevel-8": .niet,
                        "woonkamer-0": .goed, "woonkamer-3": .niet,
                        "keuken-0": .goed, "keuken-7": .niet,
                        "badkamer-0": .niet, "badkamer-2": .niet,
                        "kelder-0": .niet, "kelder-1": .niet, "kelder-2": .niet,
                        "tuin-0": .goed, "tuin-3": .niet,
                    ],
                    notes: [
                        "bouwkundig": "Substantiële gebreken door de hele woning. Scheuren in achtergevel mogelijk structureel. Bouwkundige keuring absoluut vereist vóór elk bod.",
                        "vocht-energie": "Asbest verdacht op dak en in de kelder. Energielabel G – geen isolatie aanwezig. Totale energiemaatregelen ±€30k.",
                        "kelder": "Ernstige vochtproblemen, zoutuitslag op alle muren. Sanering noodzakelijk. Kosten onbekend.",
                        "gevoel": "Prettige buurt, maar de woning is een volledig renovatieproject. Vraagprijs staat in geen verhouding tot de staat.",
                    ]),

            // 3 – Tussenwoning Almere
            Viewing(id: UUID(uuidString: "00000000-0000-0000-0000-000000000003")!,
                    name: "Tussenwoning Almere", type: .woning, tenure: .koop,
                    date: fmt.date(from: "8 mei 2026") ?? Date(),
                    answers: [
                        "bouwkundig-0": .goed, "bouwkundig-2": .goed, "bouwkundig-3": .goed,
                        "bouwkundig-4": .goed, "bouwkundig-5": .goed, "bouwkundig-6": .goed,
                        "bouwkundig-8": .goed, "bouwkundig-9": .goed,
                        "vocht-energie-0": .goed, "vocht-energie-1": .goed, "vocht-energie-2": .goed,
                        "vocht-energie-4": .goed, "vocht-energie-5": .goed, "vocht-energie-6": .goed,
                        "vocht-energie-7": .goed, "vocht-energie-8": .goed, "vocht-energie-10": .goed,
                        "installaties-0": .goed, "installaties-1": .goed, "installaties-2": .goed,
                        "installaties-3": .goed, "installaties-4": .goed, "installaties-5": .goed,
                        "installaties-10": .goed,
                        "binnen-0": .goed, "binnen-2": .goed, "binnen-4": .goed, "binnen-5": .goed,
                        "binnen-6": .goed, "binnen-8": .goed, "binnen-10": .goed,
                        "locatie-0": .goed, "locatie-4": .goed, "locatie-5": .goed, "locatie-7": .goed,
                        "verkoper-0": .goed, "verkoper-2": .goed, "verkoper-5": .goed, "verkoper-6": .goed,
                        "historie-0": .goed, "historie-1": .goed, "historie-4": .goed, "historie-6": .goed,
                        "kosten-0": .goed, "kosten-1": .goed, "kosten-2": .goed, "kosten-3": .goed,
                        "gevoel-0": .goed, "gevoel-1": .goed, "gevoel-2": .goed,
                        "gevoel-4": .goed, "gevoel-6": .goed, "gevoel-7": .goed,
                        "gevel-0": .goed, "gevel-1": .goed, "gevel-4": .goed, "gevel-9": .goed,
                        "woonkamer-0": .goed, "woonkamer-2": .goed, "woonkamer-7": .goed, "woonkamer-9": .goed,
                        "keuken-0": .goed, "keuken-1": .goed, "keuken-3": .goed, "keuken-7": .goed,
                        "badkamer-0": .goed, "badkamer-2": .goed, "badkamer-5": .goed, "badkamer-8": .goed,
                        "slaapkamer-0": .goed, "slaapkamer-1": .goed, "slaapkamer-3": .goed,
                        "tuin-0": .goed, "tuin-3": .goed, "tuin-5": .goed, "tuin-6": .goed,
                    ],
                    notes: [
                        "bouwkundig": "Woning uit 2014, uitstekende staat. Geen gebreken aangetroffen.",
                        "gevoel": "Prettige buurt, woning voldoet aan alle wensen. Vraagprijs scherp; snel handelen gewenst.",
                    ]),

            // 4 – Vrijstaande woning Wassenaar
            Viewing(id: UUID(uuidString: "00000000-0000-0000-0000-000000000004")!,
                    name: "Vrijstaande woning Wassenaar", type: .woning, tenure: .koop,
                    date: fmt.date(from: "30 apr 2026") ?? Date(),
                    answers: [
                        "bouwkundig-0": .goed, "bouwkundig-2": .goed, "bouwkundig-3": .goed,
                        "bouwkundig-4": .goed, "bouwkundig-5": .goed, "bouwkundig-6": .goed,
                        "bouwkundig-7": .goed, "bouwkundig-8": .goed, "bouwkundig-9": .goed,
                        "vocht-energie-0": .goed, "vocht-energie-1": .goed, "vocht-energie-4": .goed,
                        "vocht-energie-5": .goed, "vocht-energie-6": .goed, "vocht-energie-7": .goed,
                        "vocht-energie-8": .goed, "vocht-energie-10": .goed, "vocht-energie-11": .goed,
                        "installaties-0": .goed, "installaties-2": .goed, "installaties-3": .goed,
                        "installaties-4": .goed, "installaties-5": .goed, "installaties-6": .goed,
                        "installaties-9": .goed, "installaties-10": .goed,
                        "binnen-0": .goed, "binnen-2": .goed, "binnen-4": .goed, "binnen-5": .goed,
                        "binnen-6": .goed, "binnen-8": .goed, "binnen-9": .goed, "binnen-10": .goed,
                        "locatie-0": .goed, "locatie-1": .goed, "locatie-4": .goed, "locatie-8": .goed,
                        "locatie-9": .goed,
                        "verkoper-0": .goed, "verkoper-2": .goed, "verkoper-4": .goed, "verkoper-5": .goed,
                        "historie-0": .goed, "historie-1": .goed, "historie-4": .goed,
                        "historie-5": .goed, "historie-6": .goed, "historie-7": .goed,
                        "kosten-0": .goed, "kosten-1": .goed, "kosten-2": .goed, "kosten-4": .goed,
                        "gevoel-0": .goed, "gevoel-1": .goed, "gevoel-2": .goed, "gevoel-4": .goed,
                        "gevoel-5": .goed, "gevoel-6": .goed, "gevoel-7": .goed, "gevoel-8": .goed,
                        "gevel-0": .goed, "gevel-1": .goed, "gevel-4": .goed, "gevel-8": .goed, "gevel-9": .goed,
                        "hal-0": .goed, "hal-1": .goed, "hal-4": .goed, "hal-5": .goed, "hal-7": .goed,
                        "woonkamer-0": .goed, "woonkamer-2": .goed, "woonkamer-7": .goed, "woonkamer-9": .goed,
                        "keuken-0": .goed, "keuken-1": .goed, "keuken-3": .goed, "keuken-7": .goed,
                        "badkamer-0": .goed, "badkamer-2": .goed, "badkamer-5": .goed, "badkamer-8": .goed,
                        "slaapkamer-0": .goed, "slaapkamer-1": .goed, "slaapkamer-3": .goed,
                        "garage-0": .goed, "garage-2": .goed, "garage-5": .goed,
                        "tuin-0": .goed, "tuin-3": .goed, "tuin-4": .goed, "tuin-5": .goed, "tuin-6": .goed,
                    ],
                    notes: [
                        "bouwkundig": "Volledig gerenoveerd in 2019, bouwkundig rapport beschikbaar. Uitstekende staat door de hele woning.",
                        "kosten": "Vraagprijs aan de bovenkant van de markt, maar gerechtvaardigd door ligging en staat. Verbouwingsbudget nihil.",
                        "gevoel": "Droomwoning qua indeling, ligging en uitstraling. Alles klopt. Vraag: past het comfortabel in het budget?",
                    ]),

            // 5 – Hoekwoning Haarlem
            Viewing(id: UUID(uuidString: "00000000-0000-0000-0000-000000000005")!,
                    name: "Hoekwoning Haarlem", type: .woning, tenure: .koop,
                    date: fmt.date(from: "24 apr 2026") ?? Date(),
                    answers: [
                        "bouwkundig-0": .goed, "bouwkundig-2": .goed, "bouwkundig-3": .goed,
                        "bouwkundig-4": .niet, "bouwkundig-5": .niet, "bouwkundig-6": .goed,
                        "bouwkundig-8": .goed, "bouwkundig-9": .niet,
                        "vocht-energie-0": .goed, "vocht-energie-1": .goed, "vocht-energie-2": .goed,
                        "vocht-energie-4": .niet, "vocht-energie-7": .niet, "vocht-energie-8": .goed,
                        "installaties-0": .goed, "installaties-1": .niet, "installaties-3": .goed,
                        "installaties-4": .goed, "installaties-5": .goed, "installaties-10": .goed,
                        "binnen-0": .goed, "binnen-2": .goed, "binnen-4": .goed, "binnen-6": .goed,
                        "locatie-0": .goed, "locatie-1": .goed, "locatie-4": .goed, "locatie-6": .goed,
                        "verkoper-0": .goed, "verkoper-2": .niet, "verkoper-5": .goed,
                        "kosten-0": .goed, "kosten-1": .goed, "kosten-2": .goed, "kosten-3": .niet,
                        "gevoel-0": .goed, "gevoel-2": .goed, "gevoel-6": .goed, "gevoel-7": .goed,
                        "gevel-0": .goed, "gevel-1": .niet, "gevel-4": .niet,
                        "gevel-5": .niet, "gevel-8": .goed, "gevel-9": .goed,
                        "woonkamer-0": .goed, "woonkamer-2": .goed, "woonkamer-7": .goed,
                        "keuken-0": .goed, "keuken-7": .goed,
                        "badkamer-0": .goed, "badkamer-2": .goed, "badkamer-5": .goed,
                        "slaapkamer-0": .goed, "slaapkamer-1": .goed, "slaapkamer-4": .goed,
                        "zolder-0": .goed, "zolder-2": .niet, "zolder-4": .niet, "zolder-5": .niet,
                        "tuin-0": .goed, "tuin-3": .goed, "tuin-6": .goed,
                    ],
                    notes: [
                        "bouwkundig": "Dak aan vervanging toe: dakpannen verzakt, goten versleten. Bouwkundige keuring aanvragen. CV-ketel 2007 – vervanging nabij.",
                        "vocht-energie": "Energielabel D. Spouwmuur en dakisolatie onvoldoende. Energiemaatregelen ±€15k voor label C.",
                        "zolder": "Vochtplekken bij dakkapel; nader onderzoek nodig. Dakkapel zit los op de nok.",
                        "verkoper": "Verkoper niet transparant over eerdere lekkage dak. Extra aandacht bij bouwkundige keuring.",
                    ]),

            // 6 – Jaren '30 woning Amsterdam-West
            Viewing(id: UUID(uuidString: "00000000-0000-0000-0000-000000000006")!,
                    name: "Jaren '30 woning Amsterdam-West", type: .woning, tenure: .koop,
                    date: fmt.date(from: "17 apr 2026") ?? Date(),
                    answers: [
                        "bouwkundig-0": .niet, "bouwkundig-1": .niet, "bouwkundig-2": .niet,
                        "bouwkundig-3": .goed, "bouwkundig-4": .niet, "bouwkundig-5": .niet,
                        "bouwkundig-6": .niet, "bouwkundig-8": .niet, "bouwkundig-9": .niet,
                        "vocht-energie-0": .niet, "vocht-energie-1": .niet, "vocht-energie-3": .niet,
                        "vocht-energie-4": .niet, "vocht-energie-5": .niet, "vocht-energie-8": .niet,
                        "installaties-0": .goed, "installaties-1": .niet, "installaties-4": .niet,
                        "installaties-5": .niet, "installaties-7": .niet,
                        "binnen-0": .goed, "binnen-2": .niet, "binnen-4": .niet, "binnen-6": .niet,
                        "locatie-0": .goed, "locatie-1": .niet, "locatie-4": .goed, "locatie-6": .goed,
                        "verkoper-0": .goed, "verkoper-1": .niet, "verkoper-2": .goed,
                        "historie-0": .goed, "historie-1": .niet, "historie-2": .niet, "historie-3": .niet,
                        "kosten-0": .niet, "kosten-2": .goed, "kosten-3": .niet,
                        "gevoel-0": .goed, "gevoel-2": .goed, "gevoel-3": .goed, "gevoel-7": .niet,
                        "gevel-0": .niet, "gevel-1": .niet, "gevel-8": .niet,
                        "woonkamer-0": .goed, "woonkamer-3": .niet,
                        "keuken-0": .goed, "keuken-7": .niet,
                        "badkamer-0": .niet, "badkamer-2": .niet,
                        "kelder-0": .niet, "kelder-1": .niet,
                        "tuin-0": .goed, "tuin-3": .goed, "tuin-6": .goed,
                    ],
                    notes: [
                        "bouwkundig": "Oorspronkelijk jaren-'30 karakter intact, maar woning vraagt om substantiële investering. Mogelijk asbestverdacht plafond zolderverdieping.",
                        "vocht-energie": "Geen isolatie, enkel glas, energielabel E. Totale investering energiemaatregelen ±€25–30k.",
                        "gevoel": "Prachtige uitstraling en toplocatie. Enkel geschikt als renovatieproject; realistische totaalkosten ±€60–80k.",
                        "historie": "Diverse doe-het-zelf verbouwingen zonder vergunning. Juridisch advies noodzakelijk.",
                    ]),

            // 7 – Nieuwbouwwoning Nieuwegein
            Viewing(id: UUID(uuidString: "00000000-0000-0000-0000-000000000007")!,
                    name: "Nieuwbouwwoning Nieuwegein", type: .woning, tenure: .koop,
                    date: fmt.date(from: "10 apr 2026") ?? Date(),
                    answers: [
                        "bouwkundig-0": .goed, "bouwkundig-2": .goed, "bouwkundig-3": .goed,
                        "bouwkundig-4": .goed, "bouwkundig-5": .goed, "bouwkundig-6": .goed,
                        "bouwkundig-8": .goed, "bouwkundig-9": .goed,
                        "vocht-energie-0": .goed, "vocht-energie-1": .goed, "vocht-energie-4": .goed,
                        "vocht-energie-5": .goed, "vocht-energie-6": .goed, "vocht-energie-7": .goed,
                        "vocht-energie-8": .goed, "vocht-energie-10": .goed, "vocht-energie-11": .goed,
                        "installaties-0": .goed, "installaties-2": .goed, "installaties-3": .goed,
                        "installaties-4": .goed, "installaties-5": .goed, "installaties-6": .goed,
                        "installaties-8": .goed, "installaties-9": .goed, "installaties-10": .goed,
                        "binnen-0": .goed, "binnen-2": .goed, "binnen-4": .goed, "binnen-5": .goed,
                        "binnen-6": .goed, "binnen-8": .goed, "binnen-10": .goed,
                        "locatie-0": .goed, "locatie-4": .goed, "locatie-5": .goed, "locatie-7": .goed,
                        "verkoper-0": .goed, "verkoper-4": .goed, "verkoper-5": .goed, "verkoper-6": .goed,
                        "historie-0": .goed, "historie-1": .goed, "historie-6": .goed,
                        "kosten-0": .goed, "kosten-1": .goed, "kosten-2": .goed, "kosten-3": .goed,
                        "gevoel-0": .goed, "gevoel-1": .goed, "gevoel-2": .goed,
                        "gevoel-4": .goed, "gevoel-5": .goed, "gevoel-7": .goed,
                        "hal-0": .goed, "hal-4": .goed, "hal-5": .goed, "hal-6": .goed,
                        "woonkamer-0": .goed, "woonkamer-2": .goed, "woonkamer-7": .goed, "woonkamer-8": .goed,
                        "keuken-0": .goed, "keuken-1": .goed, "keuken-3": .goed, "keuken-7": .goed,
                        "badkamer-0": .goed, "badkamer-2": .goed, "badkamer-5": .goed, "badkamer-8": .goed,
                        "slaapkamer-0": .goed, "slaapkamer-1": .goed, "slaapkamer-3": .goed,
                        "tuin-0": .goed, "tuin-3": .goed, "tuin-5": .goed,
                    ],
                    notes: [
                        "bouwkundig": "Woning opgeleverd in 2023. Geen gebreken aangetroffen. Bouwgarantie nog 7 jaar lopend.",
                        "vocht-energie": "Energielabel A+++. Warmtepomp, vloerverwarming en zonnepanelen (eigendom). Geen gasaansluiting.",
                        "gevoel": "Alles is nieuw en verzorgd. Buurt nog in ontwikkeling; fase 2 woningen worden volgend jaar gebouwd.",
                    ]),

            // 8 – Halfvrijstaande woning Arnhem
            Viewing(id: UUID(uuidString: "00000000-0000-0000-0000-000000000008")!,
                    name: "Halfvrijstaande woning Arnhem", type: .woning, tenure: .koop,
                    date: fmt.date(from: "3 apr 2026") ?? Date(),
                    answers: [
                        "bouwkundig-0": .goed, "bouwkundig-2": .goed, "bouwkundig-3": .goed,
                        "bouwkundig-4": .goed, "bouwkundig-5": .goed, "bouwkundig-6": .goed,
                        "bouwkundig-8": .goed, "bouwkundig-9": .goed,
                        "vocht-energie-0": .goed, "vocht-energie-1": .goed, "vocht-energie-4": .goed,
                        "vocht-energie-7": .goed, "vocht-energie-10": .niet, "vocht-energie-11": .goed,
                        "installaties-0": .goed, "installaties-1": .goed, "installaties-3": .goed,
                        "installaties-4": .goed, "installaties-5": .goed, "installaties-10": .goed,
                        "binnen-0": .goed, "binnen-2": .goed, "binnen-4": .goed, "binnen-6": .goed,
                        "locatie-0": .goed, "locatie-1": .goed, "locatie-4": .goed, "locatie-9": .goed,
                        "verkoper-0": .goed, "verkoper-2": .goed, "verkoper-5": .goed, "verkoper-6": .goed,
                        "kosten-0": .goed, "kosten-1": .goed, "kosten-2": .goed, "kosten-4": .goed,
                        "gevoel-0": .goed, "gevoel-2": .goed, "gevoel-4": .goed, "gevoel-7": .goed,
                        "gevel-0": .goed, "gevel-1": .goed, "gevel-4": .goed, "gevel-9": .goed,
                        "woonkamer-0": .goed, "woonkamer-2": .goed, "woonkamer-7": .goed,
                        "keuken-0": .goed, "keuken-3": .goed, "keuken-7": .goed,
                        "badkamer-0": .goed, "badkamer-2": .goed, "badkamer-5": .goed,
                        "slaapkamer-0": .goed, "slaapkamer-1": .goed, "slaapkamer-4": .goed,
                        "garage-0": .goed, "garage-2": .goed, "garage-4": .goed,
                        "tuin-0": .niet, "tuin-1": .niet, "tuin-3": .goed, "tuin-5": .goed, "tuin-7": .niet,
                    ],
                    notes: [
                        "tuin": "Erfgrens onduidelijk aan rechterzijde. Buurboom hangt deels over perceel; eigendomsvraag uitzoeken. Achterom op slot zonder sleutel.",
                        "vocht-energie": "Zonnepanelen geleased – contract overdraagbaar maar vraag volledige specificatie en resterende looptijd op.",
                    ]),

            // 9 – Vrijstaande woning Breda
            Viewing(id: UUID(uuidString: "00000000-0000-0000-0000-000000000009")!,
                    name: "Vrijstaande woning Breda", type: .woning, tenure: .koop,
                    date: fmt.date(from: "26 mrt 2026") ?? Date(),
                    answers: [
                        "bouwkundig-0": .niet, "bouwkundig-2": .niet, "bouwkundig-3": .goed,
                        "bouwkundig-4": .niet, "bouwkundig-5": .niet, "bouwkundig-6": .niet,
                        "bouwkundig-8": .goed, "bouwkundig-9": .niet,
                        "vocht-energie-0": .niet, "vocht-energie-1": .niet, "vocht-energie-4": .niet,
                        "vocht-energie-5": .niet, "vocht-energie-7": .niet, "vocht-energie-8": .niet,
                        "installaties-0": .goed, "installaties-1": .niet, "installaties-4": .niet,
                        "installaties-5": .niet, "installaties-7": .goed,
                        "binnen-0": .goed, "binnen-4": .niet, "binnen-6": .niet,
                        "locatie-0": .goed, "locatie-1": .goed, "locatie-8": .goed, "locatie-9": .goed,
                        "verkoper-0": .goed, "verkoper-1": .niet, "verkoper-3": .goed,
                        "kosten-0": .niet, "kosten-2": .goed, "kosten-3": .niet,
                        "gevoel-0": .goed, "gevoel-2": .goed, "gevoel-3": .goed, "gevoel-7": .niet,
                        "gevel-0": .niet, "gevel-1": .niet, "gevel-4": .niet, "gevel-8": .niet,
                        "woonkamer-0": .goed, "woonkamer-3": .niet,
                        "keuken-0": .goed, "keuken-7": .niet,
                        "badkamer-0": .niet, "badkamer-2": .niet,
                        "zolder-2": .niet, "zolder-4": .niet, "zolder-5": .niet,
                        "tuin-0": .goed, "tuin-1": .goed, "tuin-3": .goed, "tuin-6": .goed,
                    ],
                    notes: [
                        "bouwkundig": "Woning uit 1975, nooit grondig gerenoveerd. Fundering onbekend – rapport opvragen. Dak en gevel hebben directe aandacht nodig.",
                        "vocht-energie": "Geen isolatie aanwezig, enkel glas, energielabel F. Energiemaatregelen ±€35k.",
                        "kosten": "Vraagprijs te hoog gezien de staat. Verbouwingsreserve noodzakelijk van minimaal €50k.",
                        "gevoel": "Geweldige ruimte en tuin. Potentieel aanwezig maar vereist volledig renovatietraject.",
                    ]),

            // 10 – Tussenwoning Tilburg
            Viewing(id: UUID(uuidString: "00000000-0000-0000-0000-000000000010")!,
                    name: "Tussenwoning Tilburg", type: .woning, tenure: .koop,
                    date: fmt.date(from: "19 mrt 2026") ?? Date(),
                    answers: [
                        "bouwkundig-0": .goed, "bouwkundig-2": .goed, "bouwkundig-3": .goed,
                        "bouwkundig-4": .goed, "bouwkundig-5": .goed, "bouwkundig-6": .niet,
                        "bouwkundig-8": .goed, "bouwkundig-9": .goed,
                        "vocht-energie-0": .goed, "vocht-energie-1": .niet, "vocht-energie-4": .niet,
                        "vocht-energie-7": .goed, "vocht-energie-8": .goed,
                        "installaties-0": .goed, "installaties-1": .niet, "installaties-3": .goed,
                        "installaties-4": .goed, "installaties-5": .goed, "installaties-10": .goed,
                        "binnen-0": .goed, "binnen-2": .goed, "binnen-4": .goed, "binnen-6": .niet,
                        "locatie-0": .goed, "locatie-4": .goed, "locatie-6": .goed, "locatie-7": .goed,
                        "verkoper-0": .goed, "verkoper-2": .goed, "verkoper-5": .goed, "verkoper-8": .goed,
                        "kosten-0": .goed, "kosten-1": .goed, "kosten-2": .goed,
                        "gevoel-0": .goed, "gevoel-2": .goed, "gevoel-4": .goed, "gevoel-7": .goed,
                        "gevel-0": .goed, "gevel-1": .goed, "gevel-4": .goed, "gevel-8": .niet, "gevel-9": .goed,
                        "woonkamer-0": .goed, "woonkamer-2": .goed, "woonkamer-7": .goed,
                        "keuken-0": .goed, "keuken-7": .goed,
                        "badkamer-0": .niet, "badkamer-2": .niet, "badkamer-5": .goed,
                        "slaapkamer-0": .goed, "slaapkamer-1": .goed, "slaapkamer-4": .goed,
                        "tuin-0": .goed, "tuin-3": .goed, "tuin-5": .goed, "tuin-6": .goed,
                    ],
                    notes: [
                        "bouwkundig": "Kozijnen achterzijde: lichte houtrot onderzijde. CV-ketel bouwjaar 2009 – vervanging binnen 2 jaar verwacht.",
                        "badkamer": "Schimmelvorming rondom douche, kitwerk sterk verouderd. Renovatie ±€9k.",
                        "vocht-energie": "Energielabel C. Spouwmuurvulling aanwezig maar mogelijk niet volledig. Laten controleren.",
                    ]),

            // 11 – Appartement Utrecht Binnenstad
            Viewing(id: UUID(uuidString: "00000000-0000-0000-0000-000000000011")!,
                    name: "Appartement Utrecht Binnenstad", type: .appartement, tenure: .koop,
                    date: fmt.date(from: "12 mrt 2026") ?? Date(),
                    answers: [
                        // bouwkundig appartement (idx 0–5)
                        "bouwkundig-0": .goed, "bouwkundig-1": .goed, "bouwkundig-2": .goed,
                        "bouwkundig-3": .goed, "bouwkundig-4": .goed, "bouwkundig-5": .goed,
                        // vocht-energie appartement (idx 0–10, geen spouwmuur)
                        "vocht-energie-0": .goed, "vocht-energie-1": .goed, "vocht-energie-4": .goed,
                        "vocht-energie-7": .goed, "vocht-energie-8": .goed,
                        // installaties appartement (idx 0–10, stadsverwarming op 2)
                        "installaties-0": .goed, "installaties-1": .goed, "installaties-2": .niet,
                        "installaties-5": .goed, "installaties-6": .goed, "installaties-9": .goed,
                        "installaties-10": .goed,
                        "binnen-0": .goed, "binnen-2": .goed, "binnen-4": .goed, "binnen-6": .goed,
                        "binnen-8": .goed, "binnen-10": .goed,
                        "locatie-0": .goed, "locatie-1": .goed, "locatie-4": .goed,
                        "locatie-6": .goed, "locatie-8": .goed,
                        "verkoper-0": .goed, "verkoper-2": .goed, "verkoper-5": .goed, "verkoper-6": .goed,
                        // historie appartement (idx 0–8, geen schilder/dak woning, wel MJOP op 5)
                        "historie-0": .goed, "historie-4": .goed, "historie-5": .goed,
                        "historie-6": .goed, "historie-8": .goed,
                        // kosten appartement (idx 0–7, VvE op 6)
                        "kosten-0": .goed, "kosten-1": .goed, "kosten-2": .goed,
                        "kosten-4": .goed, "kosten-5": .goed, "kosten-6": .goed,
                        "gevoel-0": .goed, "gevoel-1": .goed, "gevoel-2": .goed, "gevoel-7": .goed,
                        "gemeenschappelijk-0": .goed, "gemeenschappelijk-1": .goed,
                        "gemeenschappelijk-3": .goed, "gemeenschappelijk-6": .goed, "gemeenschappelijk-8": .goed,
                        // hal appartement (idx 0–6, geen brievenbus/trap woning)
                        "hal-0": .goed, "hal-3": .goed, "hal-6": .goed,
                        "woonkamer-0": .goed, "woonkamer-2": .goed, "woonkamer-7": .goed,
                        "keuken-0": .goed, "keuken-3": .goed, "keuken-7": .goed,
                        "badkamer-0": .goed, "badkamer-2": .goed, "badkamer-5": .goed,
                        "slaapkamer-0": .goed, "slaapkamer-1": .goed, "slaapkamer-4": .goed,
                        "balkon-0": .goed, "balkon-1": .goed, "balkon-3": .goed,
                        "berging-0": .goed, "berging-1": .goed, "berging-2": .goed,
                    ],
                    notes: [
                        "bouwkundig": "Appartement volledig gerenoveerd in 2021. Uitstekende bouwkundige staat.",
                        "kosten": "VvE actief met goed gevuld reservefonds. Bijdrage €175/mnd inclusief opstalverzekering. Stadsverwarming: gebonden tarief; opvragen bij eigenaar.",
                        "gevoel": "Prachtige locatie in historisch centrum. Efficiënte indeling, lichtinval uitstekend.",
                    ]),

            // 12 – Appartement Amsterdam-Zuid
            Viewing(id: UUID(uuidString: "00000000-0000-0000-0000-000000000012")!,
                    name: "Appartement Amsterdam-Zuid", type: .appartement, tenure: .koop,
                    date: fmt.date(from: "5 mrt 2026") ?? Date(),
                    answers: [
                        "bouwkundig-0": .goed, "bouwkundig-1": .goed, "bouwkundig-2": .goed,
                        "bouwkundig-3": .goed, "bouwkundig-4": .goed, "bouwkundig-5": .goed,
                        "vocht-energie-0": .goed, "vocht-energie-1": .goed, "vocht-energie-4": .goed,
                        "vocht-energie-5": .goed, "vocht-energie-7": .goed, "vocht-energie-9": .goed,
                        "installaties-0": .goed, "installaties-1": .goed, "installaties-4": .goed,
                        "installaties-5": .goed, "installaties-6": .goed, "installaties-7": .goed,
                        "installaties-9": .goed, "installaties-10": .goed,
                        "binnen-0": .goed, "binnen-2": .goed, "binnen-4": .goed, "binnen-5": .goed,
                        "binnen-6": .goed, "binnen-8": .goed, "binnen-9": .goed, "binnen-10": .goed,
                        "locatie-0": .goed, "locatie-1": .goed, "locatie-4": .goed, "locatie-6": .goed,
                        "locatie-8": .goed,
                        "verkoper-0": .goed, "verkoper-2": .goed, "verkoper-4": .goed, "verkoper-5": .goed,
                        "historie-0": .goed, "historie-4": .goed, "historie-5": .goed,
                        "historie-7": .goed, "historie-8": .goed,
                        "kosten-0": .goed, "kosten-1": .goed, "kosten-2": .goed, "kosten-4": .goed,
                        "kosten-5": .goed, "kosten-6": .goed, "kosten-7": .niet,
                        "gevoel-0": .goed, "gevoel-1": .goed, "gevoel-2": .goed, "gevoel-4": .goed,
                        "gevoel-7": .niet, "gevoel-8": .goed,
                        "gemeenschappelijk-0": .goed, "gemeenschappelijk-1": .goed,
                        "gemeenschappelijk-3": .goed, "gemeenschappelijk-6": .goed,
                        "gemeenschappelijk-7": .goed, "gemeenschappelijk-8": .goed,
                        "hal-0": .goed, "hal-3": .goed, "hal-4": .goed,
                        "woonkamer-0": .goed, "woonkamer-2": .goed, "woonkamer-7": .goed, "woonkamer-9": .goed,
                        "keuken-0": .goed, "keuken-1": .goed, "keuken-3": .goed, "keuken-7": .goed,
                        "badkamer-0": .goed, "badkamer-2": .goed, "badkamer-5": .goed, "badkamer-8": .goed,
                        "slaapkamer-0": .goed, "slaapkamer-1": .goed, "slaapkamer-3": .goed,
                        "balkon-0": .goed, "balkon-3": .goed, "balkon-4": .goed,
                        "berging-0": .goed, "berging-1": .goed, "berging-2": .goed,
                    ],
                    notes: [
                        "kosten": "VvE bijdrage €220/mnd; ruim reservefonds. Erfpacht afgekocht tot 2047 – herziening kan fors zijn. Navragen bij gemeente.",
                        "gevoel": "Prachtig appartement, maar de vraagprijs overstijgt ons budget comfortabel. Lastige afweging.",
                        "gemeenschappelijk": "Gehele gevel recent gerenoveerd. VvE actief en financieel gezond, MJOP aanwezig.",
                    ]),

            // 13 – Appartement Rotterdam Kop van Zuid
            Viewing(id: UUID(uuidString: "00000000-0000-0000-0000-000000000013")!,
                    name: "Appartement Rotterdam Kop van Zuid", type: .appartement, tenure: .koop,
                    date: fmt.date(from: "26 feb 2026") ?? Date(),
                    answers: [
                        "bouwkundig-0": .goed, "bouwkundig-1": .goed, "bouwkundig-2": .goed,
                        "bouwkundig-3": .goed, "bouwkundig-4": .goed, "bouwkundig-5": .niet,
                        "vocht-energie-0": .goed, "vocht-energie-1": .goed, "vocht-energie-2": .niet,
                        "vocht-energie-4": .goed, "vocht-energie-7": .goed, "vocht-energie-8": .niet,
                        "installaties-0": .goed, "installaties-1": .goed, "installaties-2": .goed,
                        "installaties-5": .goed, "installaties-6": .goed, "installaties-9": .goed,
                        "installaties-10": .goed,
                        "binnen-0": .goed, "binnen-2": .goed, "binnen-4": .goed,
                        "binnen-6": .niet, "binnen-8": .goed,
                        "locatie-0": .goed, "locatie-1": .goed, "locatie-4": .goed, "locatie-6": .goed,
                        "verkoper-0": .goed, "verkoper-2": .goed, "verkoper-5": .goed,
                        "historie-0": .goed, "historie-4": .niet, "historie-5": .niet, "historie-8": .goed,
                        "kosten-0": .goed, "kosten-1": .goed, "kosten-2": .goed,
                        "kosten-5": .goed, "kosten-6": .niet,
                        "gevoel-0": .goed, "gevoel-1": .goed, "gevoel-2": .goed, "gevoel-7": .goed,
                        "gemeenschappelijk-0": .goed, "gemeenschappelijk-1": .goed,
                        "gemeenschappelijk-3": .goed, "gemeenschappelijk-4": .goed,
                        "gemeenschappelijk-6": .niet, "gemeenschappelijk-8": .niet,
                        "hal-0": .goed, "hal-3": .goed, "hal-6": .goed,
                        "woonkamer-0": .goed, "woonkamer-2": .goed, "woonkamer-7": .goed,
                        "keuken-0": .goed, "keuken-7": .goed,
                        "badkamer-0": .goed, "badkamer-2": .niet, "badkamer-5": .goed,
                        "slaapkamer-0": .goed, "slaapkamer-1": .goed,
                        "balkon-0": .goed, "balkon-3": .goed, "balkon-4": .goed,
                        "berging-0": .goed, "berging-1": .goed,
                    ],
                    notes: [
                        "bouwkundig": "Bouwkundig keuringsrapport ontbreekt. Gebouw uit 2003 – VvE loopt achter met groot onderhoud.",
                        "kosten": "VvE bijdrage laag (€95/mnd) maar reservefonds onvoldoende. Risico op bijdrageverhoging op korte termijn.",
                        "badkamer": "Badkamer gedateerd, kitwerk verouderd, schimmel in hoek douche. Renovatie ±€8k.",
                        "gemeenschappelijk": "Buitenschilderwerk niet recent uitgevoerd. MJOP ontbreekt – VvE bestuur gevraagd naar planning.",
                    ]),
        ]
    }()
}
