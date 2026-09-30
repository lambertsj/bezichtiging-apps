import Foundation

// MARK: – Market-aware model labels
// Language (Dutch vs English) comes from the device system language.
// The market parameter is kept only where the UK/US distinction matters (e.g. "Flat" vs "Apartment").

extension ViewingType {
    func label(for market: Market) -> String {
        if Market.isDeviceLanguageDutch { return self == .woning ? "Woning" : "Appartement" }
        if self == .woning { return "House" }
        return market == .uk ? "Flat" : "Apartment"
    }
    func sub(for market: Market) -> String {
        if Market.isDeviceLanguageDutch {
            return self == .woning ? "Eengezins, hoek, vrijstaand" : "Onderdeel van een VvE"
        }
        return self == .woning ? "Terraced, semi-detached, detached" : "Part of a building or block"
    }
}

extension Tenure {
    func label(for market: Market) -> String {
        if Market.isDeviceLanguageDutch { return self == .koop ? "Koop" : "Huur" }
        return self == .koop ? "Purchase" : "Rental"
    }
    func longLabel(for market: Market) -> String {
        if Market.isDeviceLanguageDutch { return self == .koop ? "Te koop" : "Te huur" }
        if self == .koop { return "For Sale" }
        return market == .uk ? "To Let" : "For Rent"
    }
}

// MARK: – UI strings

enum L {

    private static var isDutch: Bool { Market.isDeviceLanguageDutch }

    // MARK: Home
    static func homeTagline(_ m: Market) -> String {
        isDutch ? "Klaar voor de volgende bezichtiging." : "Ready for your next viewing."
    }
    static func homeDescription(_ m: Market) -> String {
        isDutch
            ? "Loop per ruimte alle aandachtspunten na. Markeer of iets in orde is of niet."
            : "Work through each room and mark what's in good condition or needs attention."
    }
    static func newViewingCTA(_ m: Market) -> String {
        isDutch ? "Start nieuwe bezichtiging" : "Start new viewing"
    }
    static func newViewingCTASub(_ m: Market) -> String {
        if isDutch { return "Woning of appartement · checklist" }
        return m == .uk ? "House or flat · checklist" : "House or apartment · checklist"
    }
    static func pastViewings(_ m: Market) -> String {
        isDutch ? "Eerdere bezichtigingen" : "Previous viewings"
    }
    static func noPastViewings(_ m: Market) -> String {
        isDutch ? "Nog geen bezichtigingen.\nBegin met een nieuwe." : "No viewings yet.\nStart a new one."
    }

    // MARK: RoomsView
    static func roomsSubtitle(_ m: Market) -> String {
        isDutch ? "Kies een categorie om de checklist te doorlopen." : "Choose a category to work through the checklist."
    }
    static func categories(_ m: Market) -> String { isDutch ? "Categorieën" : "Categories" }
    static func individualRooms(_ m: Market) -> String { isDutch ? "Individuele ruimtes" : "Individual rooms" }
    static func individualRoomsSub(_ m: Market) -> String {
        isDutch ? "Loop ruimte voor ruimte na" : "Check room by room"
    }
    // MARK: Risk scan
    static func riskScan(_ m: Market) -> String { isDutch ? "Risicoscan" : "Risk scan" }
    static func riskScanSub(_ m: Market) -> String {
        isDutch
            ? "Bouwjaar, energielabel, water en monumentstatus, met de vragen voor de makelaar."
            : "Build year, energy label, flooding and listed status, with questions for the agent."
    }
    static func riskScanPlaceholder(_ m: Market) -> String { isDutch ? "Postcode en huisnummer" : "Postcode and house number" }
    static func riskScanLoading(_ m: Market) -> String { isDutch ? "Adres controleren…" : "Checking address…" }
    static func riskScanRetry(_ m: Market) -> String { isDutch ? "Opnieuw proberen" : "Try again" }
    static func riskScanCopy(_ m: Market) -> String { isDutch ? "Kopieer vraag" : "Copy question" }
    static func riskScanShareTitle(_ m: Market) -> String { isDutch ? "Vragen voor de makelaar over" : "Questions for the agent about" }
    static func riskScanNoResidence(_ m: Market) -> String {
        isDutch ? "Let op: dit object staat in de BAG niet als woning geregistreerd." : "Note: this property is not registered as a residence in the BAG."
    }
    static func riskScanSources(_ m: Market) -> String {
        isDutch
            ? "Bronnen: Kadaster (BAG), RVO (EP-Online), Klimaateffectatlas, Rijksdienst voor het Cultureel Erfgoed. Een indicatie, geen bouwkundige keuring."
            : "Sources: Kadaster (BAG), RVO (EP-Online), Klimaateffectatlas, Cultural Heritage Agency. An indication, not a building survey."
    }
    static func riskLow(_ m: Market) -> String { isDutch ? "Laag" : "Low" }
    static func riskMedium(_ m: Market) -> String { isDutch ? "Gemiddeld" : "Medium" }
    static func riskHigh(_ m: Market) -> String { isDutch ? "Hoog" : "High" }
    static func riskNoData(_ m: Market) -> String { isDutch ? "Geen gegevens" : "No data" }
    static func riskUnknown(_ m: Market) -> String { isDutch ? "Onbekend" : "Unknown" }

    static func exportPDF(_ m: Market) -> String { isDutch ? "Exporteren als PDF" : "Export as PDF" }
    static func exportPDFSub(_ m: Market) -> String {
        isDutch ? "Bekijk het rapport en sla het op" : "View report and save"
    }
    static func beginHere(_ m: Market) -> String { isDutch ? "Begin hier" : "Start here" }

    // MARK: ChecklistView
    static func answeredOf(_ ans: Int, _ tot: Int, market: Market) -> String {
        isDutch ? "\(ans) van \(tot) beoordeeld" : "\(ans) of \(tot) assessed"
    }
    static func note(_ m: Market) -> String { isDutch ? "Opmerking" : "Note" }
    static func notePlaceholder(_ m: Market) -> String {
        isDutch ? "Korte notitie over deze ruimte…" : "Brief note about this room…"
    }
    static func notePlaceholderSection(_ m: Market) -> String {
        isDutch ? "Korte notitie over deze categorie…" : "Brief note about this section…"
    }
    static func doneWith(_ label: String, market: Market) -> String {
        isDutch ? "Klaar met \(label.lowercased())" : "Done with \(label.lowercased())"
    }
    static func ratingGood(_ m: Market) -> String { isDutch ? "In orde" : "Good" }
    static func ratingBad(_ m: Market) -> String { isDutch ? "Aandacht" : "Attention" }
    static func ratingNA(_ m: Market) -> String { isDutch ? "n.v.t." : "n/a" }

    // MARK: IndividualRoomsView
    static func indivRoomsTitle(_ m: Market) -> String { isDutch ? "Individuele ruimtes" : "Individual Rooms" }
    static func indivRoomsSub(_ m: Market) -> String {
        isDutch
            ? "Loop ruimte voor ruimte na — apart van de overkoepelende categorieën."
            : "Check room by room — separate from the main categories."
    }

    // MARK: NewViewingSheet
    static func newViewingSheetTitle(_ m: Market) -> String { isDutch ? "Nieuwe bezichtiging" : "New viewing" }
    static func newViewingSheetDesc(_ m: Market) -> String {
        isDutch
            ? "Geef een naam en kies het type. Je kunt later altijd aanpassen."
            : "Give it a name and choose the property type. You can always change this later."
    }
    static func sectionTenure(_ m: Market) -> String { isDutch ? "Vorm" : "Tenure" }
    static func sectionName(_ m: Market) -> String { isDutch ? "Naam" : "Name" }
    static func namePlaceholder(type: ViewingType, market: Market) -> String {
        if isDutch { return type == .appartement ? "Bijv. Appartement Utrecht" : "Bijv. Huis Utrecht" }
        if type == .woning { return "E.g. House in Bristol" }
        return market == .uk ? "E.g. Flat in Bristol" : "E.g. Apartment in Austin"
    }
    static func cancel(_ m: Market) -> String { isDutch ? "Annuleren" : "Cancel" }
    static func begin(_ m: Market) -> String { isDutch ? "Beginnen" : "Start" }

    // MARK: Photos
    static func photos(_ m: Market) -> String { isDutch ? "Foto's" : "Photos" }
    static func photoButtonLabel(_ m: Market) -> String { isDutch ? "Foto" : "Photo" }
    static func addPhotoTitle(_ m: Market) -> String { isDutch ? "Foto toevoegen" : "Add photo" }
    static func photoLibrary(_ m: Market) -> String { isDutch ? "Fotobibliotheek" : "Photo library" }
    static func cameraPermissionTitle(_ m: Market) -> String {
        isDutch ? "Cameratoegang vereist" : "Camera access required"
    }
    static func cameraPermissionMsg(_ m: Market) -> String {
        isDutch
            ? "Geef Bezichtiging toegang tot de camera via Instellingen > Privacy > Camera."
            : "Allow access to the camera in Settings > Privacy > Camera."
    }
    static func settings(_ m: Market) -> String { isDutch ? "Instellingen" : "Settings" }

    // MARK: Settings
    static func settingsTitle(_ m: Market) -> String { isDutch ? "Instellingen" : "Settings" }
    static func done(_ m: Market) -> String { isDutch ? "Gereed" : "Done" }
    static func marketSection(_ m: Market) -> String { isDutch ? "Markt & taal" : "Market & Language" }
    static func marketPickerLabel(_ m: Market) -> String { isDutch ? "Land" : "Country" }

    // MARK: Onboarding
    static func onboardingTitle(isDutch: Bool) -> String {
        isDutch ? "Klaar voor je\nbezichtiging?" : "Ready for your\nviewing?"
    }
    static func onboardingSubtitle(isDutch: Bool) -> String {
        isDutch
            ? "Loop per ruimte alle aandachtspunten na\nen mis niets tijdens de bezichtiging."
            : "Work through each room and don't miss\na thing during the viewing."
    }
    static func onboardingCTA(isDutch: Bool) -> String { isDutch ? "Beginnen" : "Start" }

    // MARK: Splash
    static func appName(_ m: Market) -> String { isDutch ? "Bezichtiging" : "Home Viewing" }
    static func splashSubtitle(_ m: Market) -> String {
        isDutch ? "Woningbezichtiging checklist" : "Property viewing checklist"
    }

    // MARK: Language switch confirmation
    static func switchLanguageTitle(_ m: Market) -> String {
        isDutch ? "Van taal wisselen?" : "Switch language?"
    }
    static func switchLanguageMsg(_ m: Market) -> String {
        isDutch
            ? "Alle bestaande bezichtigingen worden verwijderd. Dit kan niet ongedaan worden gemaakt."
            : "All existing viewings will be deleted. This cannot be undone."
    }
    static func switchConfirm(_ m: Market) -> String {
        isDutch ? "Wisselen" : "Switch"
    }

    // MARK: Settings – Privacy & About
    static func privacyStatementTitle(_ m: Market) -> String { "Privacy Statement" }
    static func aboutTitle(_ m: Market) -> String { isDutch ? "Over de app" : "About" }

    static func privacyItems(_ m: Market) -> [(String, String)] {
        if isDutch {
            return [
                ("Lokale opslag",
                 "De app slaat alle bezichtigingen lokaal op je toestel op. Er worden geen gegevens naar externe servers verstuurd."),
                ("Geen account",
                 "Je hoeft geen account aan te maken. Er wordt geen e-mailadres of telefoonnummer gevraagd."),
                ("Gegevens verwijderen",
                 "Wanneer je de app verwijdert, verdwijnen ook alle gegevens. Maak vooraf een PDF-export als je iets wilt bewaren."),
                ("Geen tracking",
                 "De app verzamelt geen gebruiksdata, verstuurt geen analytics en gebruikt geen advertentie-tracking."),
                ("Contact",
                 "Vragen over privacy? Neem contact op via info@houseviewing.online"),
            ]
        }
        return [
            ("Local storage",
             "The app stores all viewings locally on your device. No data is sent to external servers."),
            ("No account",
             "No account required. We don't ask for your email address or phone number."),
            ("Deleting data",
             "When you delete the app, all data is deleted with it. Export a PDF first if you want to keep anything."),
            ("No tracking",
             "The app collects no usage data, sends no analytics, and uses no ad tracking."),
            ("Contact",
             "Questions about privacy? Get in touch at info@houseviewing.online"),
        ]
    }

    static func aboutItems(_ m: Market) -> [(String, String)] {
        if isDutch {
            return [
                ("Versie", "Bezichtiging 1.0 — 2026"),
                ("Doel",
                 "Hoi, ik ben Jeroen. Dit is een eenvoudig hulpmiddel om tijdens een bezichtiging niets te vergeten. Per ruimte loop je de aandachtspunten af en markeer je of iets in orde is."),
                ("Voor wie",
                 "Iedereen die een woning gaat bezichtigen — van starter tot doorstromer. Geen bouwkundige kennis vereist."),
                ("Disclaimer",
                 "De checklist is een hulpmiddel. Voor een volledige beoordeling van een woning blijft een bouwkundige keuring nodig."),
                ("Feedback",
                 "Opmerkingen of een tip voor een checklist-item? info@houseviewing.online"),
            ]
        }
        return [
            ("Version", "Home Viewing 1.0 — 2026"),
            ("Purpose",
             "A simple tool to make sure you don't miss anything during a property viewing. Work through the checklist room by room and mark what's in good condition or needs attention."),
            ("Who it's for",
             "Anyone viewing a property — from first-time buyers to those moving up the ladder. No structural knowledge required."),
            ("Disclaimer",
             "The checklist is a tool. For a full assessment of a property, a structural survey is still recommended."),
            ("Feedback",
             "Suggestions or a tip for a checklist item? info@houseviewing.online"),
        ]
    }

    // MARK: App Store review
    static func writeReview(_ m: Market) -> String {
        isDutch ? "Schrijf een recensie" : "Write a Review"
    }

    // MARK: Item detail sheet
    static func itemDetailNoteLabel(_ m: Market) -> String { isDutch ? "Notitie" : "Note" }
    static func itemDetailNotePlaceholder(_ m: Market) -> String {
        isDutch ? "Korte notitie over dit punt…" : "Quick note about this item…"
    }

    // MARK: Info sheet
    static func close(_ m: Market) -> String { isDutch ? "Sluiten" : "Close" }
    static func labelType(_ m: Market) -> String { "Type" }
    static func labelTenure(_ m: Market) -> String { isDutch ? "Vorm" : "Tenure" }

    // MARK: Long-press / context menu
    static func exportAction(_ m: Market) -> String { isDutch ? "Exporteren als PDF" : "Export as PDF" }
    static func deleteAction(_ name: String, market: Market) -> String {
        isDutch ? "Verwijder \"\(name)\"" : "Delete \"\(name)\""
    }
    static func deleteConfirmTitle(_ m: Market) -> String {
        isDutch ? "Bezichtiging verwijderen?" : "Delete viewing?"
    }
    static func deleteConfirmMsg(_ m: Market) -> String {
        isDutch ? "Dit kan niet ongedaan worden gemaakt." : "This cannot be undone."
    }
}
