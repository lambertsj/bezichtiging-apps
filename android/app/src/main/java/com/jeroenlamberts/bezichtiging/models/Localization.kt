package com.jeroenlamberts.bezichtiging.models

object L {
    private val isDutch get() = Market.isDeviceLanguageDutch

    // Home
    fun homeTagline(m: Market) = if (isDutch) "Klaar voor de volgende bezichtiging." else "Ready for your next viewing."
    fun homeDescription(m: Market) = if (isDutch)
        "Loop per ruimte alle aandachtspunten na. Markeer of iets in orde is of niet."
    else
        "Work through each room and mark what's in good condition or needs attention."
    fun newViewingCTA(m: Market) = if (isDutch) "Start nieuwe bezichtiging" else "Start new viewing"
    fun newViewingCTASub(m: Market): String {
        if (isDutch) return "Woning of appartement · checklist"
        return if (m == Market.UK) "House or flat · checklist" else "House or apartment · checklist"
    }
    fun pastViewings(m: Market) = if (isDutch) "Eerdere bezichtigingen" else "Previous viewings"
    fun noPastViewings(m: Market) = if (isDutch) "Nog geen bezichtigingen.\nBegin met een nieuwe." else "No viewings yet.\nStart a new one."

    // RoomsView
    fun roomsSubtitle(m: Market) = if (isDutch) "Kies een categorie om de checklist te doorlopen." else "Choose a category to work through the checklist."
    fun categories(m: Market) = if (isDutch) "Categorieën" else "Categories"
    fun individualRooms(m: Market) = if (isDutch) "Individuele ruimtes" else "Individual rooms"
    fun individualRoomsSub(m: Market) = if (isDutch) "Loop ruimte voor ruimte na" else "Check room by room"
    fun exportPDF(m: Market) = if (isDutch) "Exporteren als PDF" else "Export as PDF"
    fun exportPDFSub(m: Market) = if (isDutch) "Bekijk het rapport en sla het op" else "View report and save"
    fun beginHere(m: Market) = if (isDutch) "Begin hier" else "Start here"

    // ChecklistView
    fun answeredOf(ans: Int, tot: Int, market: Market) = if (isDutch) "$ans van $tot beoordeeld" else "$ans of $tot assessed"
    fun note(m: Market) = if (isDutch) "Opmerking" else "Note"
    fun notePlaceholder(m: Market) = if (isDutch) "Korte notitie over deze ruimte…" else "Brief note about this room…"
    fun notePlaceholderSection(m: Market) = if (isDutch) "Korte notitie over deze categorie…" else "Brief note about this section…"
    fun doneWith(label: String, market: Market) = if (isDutch) "Klaar met ${label.lowercase()}" else "Done with ${label.lowercase()}"
    fun ratingGood(m: Market) = if (isDutch) "In orde" else "Good"
    fun ratingBad(m: Market) = if (isDutch) "Aandacht" else "Attention"
    fun ratingNA(m: Market) = if (isDutch) "n.v.t." else "n/a"

    // IndividualRoomsView
    fun indivRoomsTitle(m: Market) = if (isDutch) "Individuele ruimtes" else "Individual Rooms"
    fun indivRoomsSub(m: Market) = if (isDutch)
        "Loop ruimte voor ruimte na — apart van de overkoepelende categorieën."
    else
        "Check room by room — separate from the main categories."

    // NewViewingSheet
    fun newViewingSheetTitle(m: Market) = if (isDutch) "Nieuwe bezichtiging" else "New viewing"
    fun newViewingSheetDesc(m: Market) = if (isDutch)
        "Geef een naam en kies het type. Je kunt later altijd aanpassen."
    else
        "Give it a name and choose the property type. You can always change this later."
    fun sectionTenure(m: Market) = if (isDutch) "Vorm" else "Tenure"
    fun sectionName(m: Market) = if (isDutch) "Naam" else "Name"
    fun namePlaceholder(type: ViewingType, market: Market): String {
        if (isDutch) return if (type == ViewingType.APPARTEMENT) "Bijv. Appartement Utrecht" else "Bijv. Huis Utrecht"
        if (type == ViewingType.WONING) return "E.g. House in Bristol"
        return if (market == Market.UK) "E.g. Flat in Bristol" else "E.g. Apartment in Austin"
    }
    fun cancel(m: Market) = if (isDutch) "Annuleren" else "Cancel"
    fun begin(m: Market) = if (isDutch) "Beginnen" else "Start"

    // Photos
    fun photos(m: Market) = if (isDutch) "Foto's" else "Photos"
    fun addPhotoTitle(m: Market) = if (isDutch) "Foto toevoegen" else "Add photo"
    fun photoLibrary(m: Market) = if (isDutch) "Fotobibliotheek" else "Photo library"
    fun photoButtonLabel(m: Market) = if (isDutch) "Foto" else "Photo"

    // Settings
    fun settingsTitle(m: Market) = if (isDutch) "Instellingen" else "Settings"
    fun done(m: Market) = if (isDutch) "Gereed" else "Done"
    fun close(m: Market) = if (isDutch) "Sluiten" else "Close"

    // Onboarding
    fun onboardingTitle(isDutch: Boolean) = if (isDutch) "Klaar voor je\nbezichtiging?" else "Ready for your\nviewing?"
    fun onboardingSubtitle(isDutch: Boolean) = if (isDutch)
        "Loop per ruimte alle aandachtspunten na\nen mis niets tijdens de bezichtiging."
    else
        "Work through each room and don't miss\na thing during the viewing."
    fun onboardingCTA(isDutch: Boolean) = if (isDutch) "Beginnen" else "Start"

    // Splash
    fun appName(m: Market) = if (isDutch) "Bezichtiging" else "Home Viewing"
    fun splashSubtitle(m: Market) = if (isDutch) "Woningbezichtiging checklist" else "Property viewing checklist"

    // Delete / context
    fun exportAction(m: Market) = if (isDutch) "Exporteren als PDF" else "Export as PDF"
    fun deleteAction(name: String, market: Market) = if (isDutch) "Verwijder \"$name\"" else "Delete \"$name\""
    fun deleteConfirmTitle(m: Market) = if (isDutch) "Bezichtiging verwijderen?" else "Delete viewing?"
    fun deleteConfirmMsg(m: Market) = if (isDutch) "Dit kan niet ongedaan worden gemaakt." else "This cannot be undone."

    // Info sheet
    fun labelType(m: Market) = "Type"
    fun labelTenure(m: Market) = if (isDutch) "Vorm" else "Tenure"

    // Settings – Privacy & About
    fun privacyStatementTitle(m: Market) = "Privacy Statement"
    fun aboutTitle(m: Market) = if (isDutch) "Over de app" else "About"
    fun writeReview(m: Market) = if (isDutch) "Schrijf een recensie" else "Write a Review"

    // Item detail
    fun itemDetailNoteLabel(m: Market) = if (isDutch) "Notitie" else "Note"
    fun itemDetailNotePlaceholder(m: Market) = if (isDutch) "Korte notitie over dit punt…" else "Quick note about this item…"

    // Sections
    fun sectionType(m: Market) = "Type"

    fun privacyItems(m: Market): List<Pair<String, String>> {
        if (isDutch) return listOf(
            "Lokale opslag" to "De app slaat alle bezichtigingen lokaal op je toestel op. Er worden geen gegevens naar externe servers verstuurd.",
            "Geen account" to "Je hoeft geen account aan te maken. Er wordt geen e-mailadres of telefoonnummer gevraagd.",
            "Gegevens verwijderen" to "Wanneer je de app verwijdert, verdwijnen ook alle gegevens. Maak vooraf een PDF-export als je iets wilt bewaren.",
            "Geen tracking" to "De app verzamelt geen gebruiksdata, verstuurt geen analytics en gebruikt geen advertentie-tracking.",
            "Contact" to "Vragen over privacy? Neem contact op via info@bezichtiging.app"
        )
        return listOf(
            "Local storage" to "The app stores all viewings locally on your device. No data is sent to external servers.",
            "No account" to "No account required. We don't ask for your email address or phone number.",
            "Deleting data" to "When you delete the app, all data is deleted with it. Export a PDF first if you want to keep anything.",
            "No tracking" to "The app collects no usage data, sends no analytics, and uses no ad tracking.",
            "Contact" to "Questions about privacy? Get in touch at info@bezichtiging.app"
        )
    }

    fun aboutItems(m: Market): List<Pair<String, String>> {
        if (isDutch) return listOf(
            "Versie" to "Bezichtiging 1.0 — 2026",
            "Website" to "www.bezichtiging.app",
            "Doel" to "Een eenvoudig hulpmiddel om tijdens een bezichtiging niets te vergeten. Per ruimte loop je de aandachtspunten af en markeer je of iets in orde is.",
            "Voor wie" to "Iedereen die een woning gaat bezichtigen — van starter tot doorstromer. Geen bouwkundige kennis vereist.",
            "Disclaimer" to "De checklist is een hulpmiddel. Voor een volledige beoordeling van een woning blijft een bouwkundige keuring nodig.",
            "Feedback" to "Opmerkingen of een tip voor een checklist-item? info@bezichtiging.app"
        )
        return listOf(
            "Version" to "Home Viewing 1.0 — 2026",
            "Website" to "www.bezichtiging.app",
            "Purpose" to "A simple tool to make sure you don't miss anything during a property viewing. Work through the checklist room by room.",
            "Who it's for" to "Anyone viewing a property — from first-time buyers to those moving up the ladder. No structural knowledge required.",
            "Disclaimer" to "The checklist is a tool. For a full assessment of a property, a structural survey is still recommended.",
            "Feedback" to "Suggestions or a tip for a checklist item? info@bezichtiging.app"
        )
    }
}
