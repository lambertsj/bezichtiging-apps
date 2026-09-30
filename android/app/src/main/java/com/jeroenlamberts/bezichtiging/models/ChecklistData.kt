package com.jeroenlamberts.bezichtiging.models

data class Room(val id: String, val label: String, val sub: String, val types: List<ViewingType>?) {
    fun visible(type: ViewingType) = types == null || types.contains(type)
}

data class Theme(val id: String, val label: String, val sub: String, val featured: Boolean, val icon: String)

data class ChecklistGroup(val category: String, val items: List<ChecklistItem>)

data class ChecklistItem(
    val label: String,
    val hint: String? = null,
    val onlyType: ViewingType? = null,
    val onlyTenure: Tenure? = null,
    val onlyMarket: Market? = null
)

data class FlatItem(val item: ChecklistItem, val category: String, val flatIndex: Int, val key: String)

object ChecklistData {

    // MARK: – Dutch themes
    val themes = listOf(
        Theme("locatie",       "Locatie en omgeving",        "Buurt, voorzieningen, geluid",      true,  "Park"),
        Theme("gevoel",        "Gevoel en geschiktheid",     "Eerste indruk, toekomst",            false, "SentimentSatisfied"),
        Theme("bouwkundig",    "Bouwkundige staat",          "Fundering, dak, scheuren",           false, "Construction"),
        Theme("binnen",        "Binnenkant en afwerking",    "Vloeren, wanden, keuken, sanitair",  false, "Brush"),
        Theme("installaties",  "Installaties en techniek",   "CV, elektra, water, ventilatie",     false, "Power"),
        Theme("vocht-energie", "Vocht, isolatie en energie", "Vocht, isolatie, energielabel",      false, "AcUnit"),
        Theme("kosten",        "Kosten en verplichtingen",   "Prijs, lasten, VvE, erfpacht",       false, "Euro"),
        Theme("historie",      "Verbouwingen en historie",   "Aanbouw, vergunningen, onderhoud",   false, "Build"),
        Theme("verkoper",      "Verkoper en verkoopproces",  "Reden, contact, voorbehoud",         false, "Description")
    )

    // MARK: – Dutch rooms
    val rooms = listOf(
        Room("gemeenschappelijk", "Gemeenschappelijk",  "Trappenhuis, lift, entree",    listOf(ViewingType.APPARTEMENT)),
        Room("gevel",             "Gevel & buitenkant", "Voegwerk, kozijnen, dak",      listOf(ViewingType.WONING)),
        Room("hal",               "Hal / entree",       "Voordeur, meterkast",           null),
        Room("woonkamer",         "Woonkamer",          "Vloer, wanden, ramen",          null),
        Room("keuken",            "Keuken",             "Apparatuur, leidingen",         null),
        Room("badkamer",          "Badkamer",           "Tegelwerk, ventilatie",         null),
        Room("toilet",            "Toilet",             "Stortbak, afvoer",              null),
        Room("slaapkamer",        "Slaapkamer(s)",      "Per slaapkamer",                null),
        Room("balkon",            "Balkon",             "Hekwerk, afvoer, ligging",      listOf(ViewingType.APPARTEMENT)),
        Room("berging",           "Berging",            "Toegang, droog, bereikbaar",    listOf(ViewingType.APPARTEMENT)),
        Room("zolder",            "Zolder",             "Isolatie, dakbeschot",          listOf(ViewingType.WONING)),
        Room("kelder",            "Kelder / berging",   "Vocht, ventilatie",             listOf(ViewingType.WONING)),
        Room("garage",            "Garage",             "Deur, bekabeling",              listOf(ViewingType.WONING)),
        Room("tuin",              "Tuin / buiten",      "Schutting, bestrating",         listOf(ViewingType.WONING))
    )

    // MARK: – Dutch checklist items
    val items: Map<String, List<ChecklistGroup>> = mapOf(
        "bouwkundig" to listOf(
            ChecklistGroup("Constructie", listOf(
                ChecklistItem("Bouwjaar en grote renovaties", "Vraag jaartal en laatste verbouwingen op."),
                ChecklistItem("Funderingsrapport aanwezig", "Bij vooroorlogse woning altijd opvragen.", ViewingType.WONING, Tenure.KOOP),
                ChecklistItem("Scheuren in muren of plafond", "Haarscheurtjes (krimp) of doorlopende scheuren?"),
                ChecklistItem("Verzakkingen of scheefstand vloeren", "Leg een knikker neer of gebruik een waterpas.")
            )),
            ChecklistGroup("Dak & gevel", listOf(
                ChecklistItem("Staat dakpannen en dakgoten", "Verzakte pannen, mos, lekkagesporen.", ViewingType.WONING),
                ChecklistItem("Voegwerk en metselwerk", "Uitgesleten voegen, doorslag, scheuren.", ViewingType.WONING),
                ChecklistItem("Kozijnen houtrot of beschadigd", "Prik onderaan het kozijn met een sleutel."),
                ChecklistItem("Schoorsteen recht en intact", "Loszittend voegwerk = lekkagerisico.", ViewingType.WONING)
            )),
            ChecklistGroup("Risicomaterialen", listOf(
                ChecklistItem("Asbestverdachte materialen", "Daken, golfplaten, leidingisolatie, vinyl."),
                ChecklistItem("Bouwkundig keuringsrapport beschikbaar", "Recent rapport scheelt een eigen keuring.", null, Tenure.KOOP)
            ))
        ),
        "vocht-energie" to listOf(
            ChecklistGroup("Vocht", listOf(
                ChecklistItem("Vochtplekken op muren of plafond", "Vooral in hoeken, bij ramen en plafonds."),
                ChecklistItem("Schimmelvorming op koude muren", "Kijk achter kasten en in hoeken."),
                ChecklistItem("Optrekkend vocht onderaan muren", "Zoutuitslag en verkleuring aan de onderkant."),
                ChecklistItem("Muffe geur (kelder, kruipruimte)", "Wijst op onvoldoende ventilatie.")
            )),
            ChecklistGroup("Isolatie", listOf(
                ChecklistItem("Energielabel definitief", "Niet voorlopig. Geldigheid 10 jaar."),
                ChecklistItem("Dakisolatie aanwezig", "Vraag de isolatiewaarde (Rc) op."),
                ChecklistItem("Vloerisolatie aanwezig", "Cruciaal bij de begane grond."),
                ChecklistItem("Spouwmuurisolatie aanwezig", "Vooral bij woningen vóór 1990.", ViewingType.WONING),
                ChecklistItem("Dubbel glas of HR++", "Check alle ramen — vaak niet overal.")
            )),
            ChecklistGroup("Energie", listOf(
                ChecklistItem("Tochtklachten bij ramen en deuren", "Houd je hand langs de naden tijdens bezichtiging."),
                ChecklistItem("Zonnepanelen: aantal en eigendom", "Gehuurd of gekocht, leeftijd, opbrengst."),
                ChecklistItem("Aansluiting laadpaal mogelijk", "Krachtstroom en plek in meterkast.")
            ))
        ),
        "installaties" to listOf(
            ChecklistGroup("Verwarming", listOf(
                ChecklistItem("Type warmtebron", "Gas, hybride, warmtepomp, stadsverwarming."),
                ChecklistItem("CV-ketel: bouwjaar en onderhoud", "Ouder dan 15 jaar = vervanging plannen."),
                ChecklistItem("Stadsverwarming of blokverwarming", "Gebonden aan vaste leverancier en tarief.", ViewingType.APPARTEMENT),
                ChecklistItem("Vloerverwarming aanwezig", "In welke ruimtes; aparte verdeler?"),
                ChecklistItem("Radiatoren werken en zijn ontlucht", "Voel of ze gelijkmatig warm worden.")
            )),
            ChecklistGroup("Elektra", listOf(
                ChecklistItem("Meterkast: aantal groepen", "Minimaal 3, liever meer voor moderne apparatuur."),
                ChecklistItem("Aardlekschakelaar aanwezig", "Verplicht in natte ruimtes sinds 1975."),
                ChecklistItem("Slimme meter aanwezig", "Nodig voor saldering zonnepanelen.")
            )),
            ChecklistGroup("Water & ventilatie", listOf(
                ChecklistItem("Loden waterleidingen", "Komt voor in woningen vóór 1960."),
                ChecklistItem("Mechanische ventilatie of WTW", "WTW = warmteterugwin, energiezuiniger."),
                ChecklistItem("Riolering aansluiting", "Gemeentelijk riool of IBA?", ViewingType.WONING),
                ChecklistItem("Internet en data-aansluiting", "CAI of glasvezel beschikbaar in de straat?")
            ))
        ),
        "binnen" to listOf(
            ChecklistGroup("Vloeren & wanden", listOf(
                ChecklistItem("Vloer waterpas en zonder kraken", "Loop het hele oppervlak af."),
                ChecklistItem("Type vloer (zwevend, vast)", "Zwevend = eenvoudiger te vervangen."),
                ChecklistItem("Wanden en plafonds zonder scheuren", "Haarscheurtjes door krimp zijn normaal."),
                ChecklistItem("Plinten en aansluitingen netjes", "Verraadt vakwerk van vorige eigenaar.")
            )),
            ChecklistGroup("Keuken & badkamer", listOf(
                ChecklistItem("Keuken: leeftijd en staat", "Volledige vervanging kost € 8 – 25 k."),
                ChecklistItem("Apparatuur compleet en functioneel", "Vraag wat achterblijft."),
                ChecklistItem("Badkamer: leeftijd en staat", "Renovatie kost € 8 – 15 k."),
                ChecklistItem("Sanitair compleet en zonder lekkage", "Toilet, douche, wastafel, kitwerk.")
            )),
            ChecklistGroup("Indeling & afwerking", listOf(
                ChecklistItem("Voldoende stopcontacten en lichtpunten", "Op logische plek bij meubels."),
                ChecklistItem("Inbouwkasten en opbergruimte", "Wat blijft achter, wat gaat mee?"),
                ChecklistItem("Lijst van roerende zaken duidelijk", "Officieel formulier bij de makelaar.", null, Tenure.KOOP),
                ChecklistItem("Inboedel — wat blijft achter", "Maak foto's; voorkomt discussie later.", null, Tenure.HUUR)
            ))
        ),
        "locatie" to listOf(
            ChecklistGroup("Buurt", listOf(
                ChecklistItem("Buurt: rustig of druk", "Bezoek ook op een ander tijdstip."),
                ChecklistItem("Geluidsoverlast (verkeer, horeca, buren)", "Open ramen even tijdens de bezichtiging."),
                ChecklistItem("Veiligheid en sociale controle", "Verlichting, fietsen, hangplekken."),
                ChecklistItem("Toekomstige bouwplannen in de buurt", "Check de gemeentewebsite voor projecten.")
            )),
            ChecklistGroup("Voorzieningen", listOf(
                ChecklistItem("Winkels op loopafstand", "Supermarkt, bakker, apotheek."),
                ChecklistItem("Scholen en kinderopvang in de buurt", "Indien van toepassing."),
                ChecklistItem("OV-verbindingen (bus, tram, station)", "Loopafstand en frequentie."),
                ChecklistItem("Parkeren (vergunning, eigen plek)", "Vergunningskosten en wachtlijst.")
            )),
            ChecklistGroup("Ligging", listOf(
                ChecklistItem("Groen, parken en speelmogelijkheden", "Belangrijk met kinderen of hond."),
                ChecklistItem("Ligging en zon (woonkamer / tuin)", "Oost / west / zuid? Wanneer schaduw?")
            ))
        ),
        "verkoper" to listOf(
            ChecklistGroup("Verkoper", listOf(
                ChecklistItem("Reden van verkoop", "Verhuizen, scheiden, financieel?"),
                ChecklistItem("Hoe lang in bezit", "Korter dan 2 jaar = extra op letten."),
                ChecklistItem("Eerlijk over gebreken", "Wijst zelf op punten = goed teken."),
                ChecklistItem("Bewoner of belegger", "Belegger kent vaak minder details.")
            )),
            ChecklistGroup("Proces", listOf(
                ChecklistItem("Makelaar: prettig contact", "Reageert snel, eerlijk over biedingen."),
                ChecklistItem("Biedingsprocedure helder", "Gesloten of open biedingen?", null, Tenure.KOOP),
                ChecklistItem("Voorbehoud financiering mogelijk", "Standaard 4 – 6 weken; check duur.", null, Tenure.KOOP),
                ChecklistItem("Voorbehoud bouwkundige keuring", "Belangrijk bij oudere woningen.", null, Tenure.KOOP),
                ChecklistItem("Gewenste opleverdatum", "Past dit bij jullie planning?"),
                ChecklistItem("Borg en huurcontract toegelicht", "Borg max. 2 maanden kale huur (sinds 2023).", null, Tenure.HUUR)
            ))
        ),
        "historie" to listOf(
            ChecklistGroup("Verbouwingen", listOf(
                ChecklistItem("Uitgevoerde verbouwingen (overzicht)", "Vraag om bonnen en garantiebewijzen."),
                ChecklistItem("Met vergunning verbouwd", "Aanbouw, dakkapel, dakopbouw."),
                ChecklistItem("Wijzigingen aan dragende constructie", "Met constructieberekening?"),
                ChecklistItem("Eigen werk vorige eigenaar", "Doe-het-zelf = vaker verborgen gebreken.")
            )),
            ChecklistGroup("Onderhoud", listOf(
                ChecklistItem("Recente schilder- of voegbeurt", "Wanneer voor het laatst gedaan?", ViewingType.WONING),
                ChecklistItem("Leeftijd dak en laatste vernieuwing", "Plat dak 25–30 jr, pannen 50+ jr.", ViewingType.WONING),
                ChecklistItem("Onderhoudslogboek aanwezig", "Vorige eigenaar bijgehouden?"),
                ChecklistItem("MJOP van de VvE inzichtelijk", "Meerjarenonderhoudsplan.", ViewingType.APPARTEMENT, Tenure.KOOP)
            )),
            ChecklistGroup("Juridisch", listOf(
                ChecklistItem("Bestemmingsplan klopt met gebruik", "Geen woon-werk-conflict?"),
                ChecklistItem("Erfdienstbaarheden / kettingbeding", "Recht van overpad, kwalitatieve verplichting.", null, Tenure.KOOP),
                ChecklistItem("Splitsingsakte ingezien", "Wat mag wel/niet binnen de VvE.", ViewingType.APPARTEMENT, Tenure.KOOP)
            ))
        ),
        "kosten" to listOf(
            ChecklistGroup("Aankoopkosten", listOf(
                ChecklistItem("Vraagprijs marktconform", "Vergelijk met de buurt (Funda, NVM).", null, Tenure.KOOP),
                ChecklistItem("Kosten koper ingeschat", "Overdrachtsbelasting + notaris + advies.", null, Tenure.KOOP),
                ChecklistItem("Hypotheek-mogelijkheid getoetst", "Maximale lening, NHG-grens.", null, Tenure.KOOP),
                ChecklistItem("Geschatte verbouwingskosten", "Reserveer ~10% extra buffer.", null, Tenure.KOOP)
            )),
            ChecklistGroup("Maandlasten", listOf(
                ChecklistItem("WOZ-waarde en OZB", "Bepaalt gemeentelijke belastingen."),
                ChecklistItem("Energiekosten gemiddeld", "Vraag jaaroverzicht (gas, stroom)."),
                ChecklistItem("VvE-bijdrage per maand", "Vraag specificatie en MJOP.", ViewingType.APPARTEMENT),
                ChecklistItem("Erfpacht canon en einddatum", "Eeuwigdurend of tijdelijk afgekocht?", null, Tenure.KOOP)
            )),
            ChecklistGroup("Huurspecifiek", listOf(
                ChecklistItem("Kale huurprijs per maand", "Zonder service en G/W/L.", null, Tenure.HUUR),
                ChecklistItem("Servicekosten en specificatie", "Uitsplitsing + jaarafrekening.", null, Tenure.HUUR),
                ChecklistItem("Energie inclusief of exclusief", "Voorschot of vast bedrag?", null, Tenure.HUUR),
                ChecklistItem("Sociale huur of vrije sector", "WWS-puntensysteem bepaalt huurprijs.", null, Tenure.HUUR)
            ))
        ),
        "gevoel" to listOf(
            ChecklistGroup("Eerste indruk", listOf(
                ChecklistItem("Eerste indruk klopt nog steeds", "Vergelijk met je gevoel bij binnenkomst."),
                ChecklistItem("Voldoende daglicht", "In meerdere kamers, niet alleen woonkamer."),
                ChecklistItem("Indeling werkt voor jullie", "Kook-, eet-, werkplek."),
                ChecklistItem("Sfeer en uitstraling", "Voelt het thuis of moet je veel veranderen?")
            )),
            ChecklistGroup("Toekomst", listOf(
                ChecklistItem("Aantal kamers past", "Nu en over 5 jaar."),
                ChecklistItem("Toekomstbestendig (kinderen, thuiswerken)", "Werkplek, slaapkamers, uitbreiding."),
                ChecklistItem("Tuin of buitenruimte voldoet", "Grootte, ligging, onderhoud."),
                ChecklistItem("Past in budget zonder zorgen", "Geen maandelijkse stress."),
                ChecklistItem("Buurt past bij jullie levensstijl", "Rustig vs. levendig, gezinnen vs. jong.")
            ))
        ),
        "gemeenschappelijk" to listOf(
            ChecklistGroup("Entree & toegang", listOf(
                ChecklistItem("Entree schoon en verzorgd"),
                ChecklistItem("Bellentableau en intercom werken"),
                ChecklistItem("Brievenbussen op orde")
            )),
            ChecklistGroup("Trappenhuis & lift", listOf(
                ChecklistItem("Trappenhuis: staat schilderwerk"),
                ChecklistItem("Lift aanwezig en gekeurd"),
                ChecklistItem("Geluidsoverlast op galerij / trap")
            )),
            ChecklistGroup("Onderhoud", listOf(
                ChecklistItem("Recente schilderbeurt buitenzijde"),
                ChecklistItem("Dak: laatste vernieuwing"),
                ChecklistItem("MJOP voorziet in komende posten")
            ))
        ),
        "gevel" to listOf(
            ChecklistGroup("Metselwerk & voegen", listOf(
                ChecklistItem("Scheuren in metselwerk"),
                ChecklistItem("Voegwerk intact en strak"),
                ChecklistItem("Verkleuring of doorslag"),
                ChecklistItem("Spouwmuurisolatie aanwezig")
            )),
            ChecklistGroup("Dak & schoorsteen", listOf(
                ChecklistItem("Dakpannen op zicht"),
                ChecklistItem("Dakgoten en hemelwaterafvoer"),
                ChecklistItem("Schoorsteen recht en intact"),
                ChecklistItem("Dakdoorvoeren en boeidelen")
            )),
            ChecklistGroup("Kozijnen & glas", listOf(
                ChecklistItem("Kozijnen: houtrot of beschadiging"),
                ChecklistItem("Dubbel glas of HR++"),
                ChecklistItem("Schilderwerk buiten"),
                ChecklistItem("Hang- en sluitwerk ramen")
            ))
        ),
        "hal" to listOf(
            ChecklistGroup("Voordeur & sluitwerk", listOf(
                ChecklistItem("Voordeur sluit goed"),
                ChecklistItem("Hang- en sluitwerk SKG-keurmerk"),
                ChecklistItem("Tochtstrip en kierdichting"),
                ChecklistItem("Brievenbus en kijkgat", null, ViewingType.WONING)
            )),
            ChecklistGroup("Meterkast & techniek", listOf(
                ChecklistItem("Meterkast bereikbaar en geordend"),
                ChecklistItem("Slimme meter aanwezig"),
                ChecklistItem("Internet-aansluiting (CAI / glas)")
            )),
            ChecklistGroup("Trap & vloer", listOf(
                ChecklistItem("Trap stevig, leuning vast", null, ViewingType.WONING),
                ChecklistItem("Trap voldoet aan maatvoering", null, ViewingType.WONING),
                ChecklistItem("Vloer vlak, geen scheuren")
            ))
        ),
        "woonkamer" to listOf(
            ChecklistGroup("Vloer & wanden", listOf(
                ChecklistItem("Vloer waterpas"),
                ChecklistItem("Type vloer (zwevend, vast)"),
                ChecklistItem("Scheuren in plafond of wanden"),
                ChecklistItem("Vochtplekken"),
                ChecklistItem("Geluidsisolatie van buren")
            )),
            ChecklistGroup("Ramen & klimaat", listOf(
                ChecklistItem("Ramen openen en sluiten"),
                ChecklistItem("Ventilatieroosters aanwezig"),
                ChecklistItem("Radiatoren werken"),
                ChecklistItem("Vloerverwarming aanwezig")
            )),
            ChecklistGroup("Elektra & data", listOf(
                ChecklistItem("Voldoende stopcontacten"),
                ChecklistItem("TV / data-aansluiting"),
                ChecklistItem("Lichtpunten op logische plek")
            ))
        ),
        "keuken" to listOf(
            ChecklistGroup("Apparatuur", listOf(
                ChecklistItem("Apparatuur blijft achter"),
                ChecklistItem("Leeftijd en staat apparatuur"),
                ChecklistItem("Inductie of gas")
            )),
            ChecklistGroup("Aansluitingen & afzuiging", listOf(
                ChecklistItem("Afzuigkap afvoer naar buiten"),
                ChecklistItem("Aansluiting vaatwasser aanwezig"),
                ChecklistItem("Aansluiting wasmachine in keuken?"),
                ChecklistItem("Geen lekkage onder gootsteen")
            )),
            ChecklistGroup("Afwerking", listOf(
                ChecklistItem("Tegels en kitwerk intact"),
                ChecklistItem("Voldoende werkbladruimte"),
                ChecklistItem("Verlichting boven werkblad")
            ))
        ),
        "badkamer" to listOf(
            ChecklistGroup("Tegelwerk & afwerking", listOf(
                ChecklistItem("Tegelwerk zonder scheuren"),
                ChecklistItem("Kitwerk schoon en heel"),
                ChecklistItem("Geen schimmel of vocht"),
                ChecklistItem("Leeftijd badkamer")
            )),
            ChecklistGroup("Sanitair & water", listOf(
                ChecklistItem("Douche / bad: afvoer en lekkage"),
                ChecklistItem("Warmwater drukvol"),
                ChecklistItem("Wastafel kraan en afvoer"),
                ChecklistItem("Toilet in badkamer (indien aanwezig)")
            )),
            ChecklistGroup("Ventilatie & elektra", listOf(
                ChecklistItem("Mechanische ventilatie aanwezig"),
                ChecklistItem("Stopcontact (geaard, spatwater)"),
                ChecklistItem("Vloerverwarming of radiator")
            ))
        ),
        "toilet" to listOf(
            ChecklistGroup("Sanitair", listOf(
                ChecklistItem("Stortbak werkt en sluit af"),
                ChecklistItem("Afvoer geen geur"),
                ChecklistItem("Fonteintje / kraan werkt")
            )),
            ChecklistGroup("Afwerking & ventilatie", listOf(
                ChecklistItem("Tegelwerk en kit"),
                ChecklistItem("Ventilatierooster aanwezig"),
                ChecklistItem("Verlichting werkt")
            ))
        ),
        "slaapkamer" to listOf(
            ChecklistGroup("Indeling & licht", listOf(
                ChecklistItem("Aantal slaapkamers klopt"),
                ChecklistItem("Daglicht en raamoppervlak"),
                ChecklistItem("Verduistering mogelijk"),
                ChecklistItem("Kastruimte / inbouw")
            )),
            ChecklistGroup("Afwerking", listOf(
                ChecklistItem("Vochtplekken op buitenmuur"),
                ChecklistItem("Vloer en plinten"),
                ChecklistItem("Geluidsisolatie")
            )),
            ChecklistGroup("Aansluitingen", listOf(
                ChecklistItem("Stopcontacten en TV/data"),
                ChecklistItem("Radiator of verwarming")
            ))
        ),
        "balkon" to listOf(
            ChecklistGroup("Constructie", listOf(
                ChecklistItem("Balkonvloer en hekwerk vast"),
                ChecklistItem("Geen scheuren in betonrand"),
                ChecklistItem("Afvoer hemelwater werkt")
            )),
            ChecklistGroup("Gebruik", listOf(
                ChecklistItem("Ligging en zon (ochtend / middag)"),
                ChecklistItem("Privacy ten opzichte van buren"),
                ChecklistItem("Buitenkraan of stopcontact")
            ))
        ),
        "berging" to listOf(
            ChecklistGroup("Toegang & staat", listOf(
                ChecklistItem("Bereikbaarheid berging"),
                ChecklistItem("Droog en geen schimmel"),
                ChecklistItem("Slot en sleutel aanwezig"),
                ChecklistItem("Verlichting en stopcontact")
            ))
        ),
        "zolder" to listOf(
            ChecklistGroup("Toegang", listOf(
                ChecklistItem("Vaste trap of vlizotrap"),
                ChecklistItem("Stahoogte voldoende")
            )),
            ChecklistGroup("Dakconstructie", listOf(
                ChecklistItem("Dakbeschot droog en heel"),
                ChecklistItem("Spanten zichtbaar en intact"),
                ChecklistItem("Vochtplekken bij dakkapel")
            )),
            ChecklistGroup("Klimaat", listOf(
                ChecklistItem("Isolatiepakket zichtbaar"),
                ChecklistItem("Dakraam of ventilatie"),
                ChecklistItem("Temperatuur in zomer")
            ))
        ),
        "kelder" to listOf(
            ChecklistGroup("Vocht & geur", listOf(
                ChecklistItem("Vochtplekken op muren of vloer"),
                ChecklistItem("Geur (muf / schimmel)"),
                ChecklistItem("Zoutuitslag op muren")
            )),
            ChecklistGroup("Toegang & gebruik", listOf(
                ChecklistItem("Ventilatie aanwezig"),
                ChecklistItem("Stahoogte"),
                ChecklistItem("Toegang en trap"),
                ChecklistItem("Bruikbaar als wasruimte / opslag")
            ))
        ),
        "garage" to listOf(
            ChecklistGroup("Constructie & deur", listOf(
                ChecklistItem("Garagedeur werkt elektrisch"),
                ChecklistItem("Dichting onder deur"),
                ChecklistItem("Vocht of lekkage plafond"),
                ChecklistItem("Inpandig of vrijstaand")
            )),
            ChecklistGroup("Aansluitingen", listOf(
                ChecklistItem("Aparte groep in meterkast"),
                ChecklistItem("Aansluiting laadpaal mogelijk"),
                ChecklistItem("Verlichting en stopcontacten")
            ))
        ),
        "tuin" to listOf(
            ChecklistGroup("Erfgrens", listOf(
                ChecklistItem("Erfgrens en schutting"),
                ChecklistItem("Bomen: eigendom en onderhoud"),
                ChecklistItem("Erfdienstbaarheden voor / achter")
            )),
            ChecklistGroup("Onderhoud & gebruik", listOf(
                ChecklistItem("Bestrating vlak"),
                ChecklistItem("Schuur of berging"),
                ChecklistItem("Buitenkraan"),
                ChecklistItem("Ligging en zon (ochtend / middag)"),
                ChecklistItem("Achterom of poort")
            ))
        )
    )

    // MARK: – English themes
    val themesEN = listOf(
        Theme("locatie",       "Location & Surroundings",       "Neighbourhood, amenities, transport",    true,  "Park"),
        Theme("gevoel",        "Feel & Lifestyle Fit",          "First impression, future suitability",   false, "SentimentSatisfied"),
        Theme("bouwkundig",    "Structural Condition",          "Foundation, roof, cracks",               false, "Construction"),
        Theme("binnen",        "Interior & Finishes",           "Floors, walls, kitchen, bathroom",       false, "Brush"),
        Theme("installaties",  "Utilities & Technical Systems", "Heating, electrics, water, ventilation", false, "Power"),
        Theme("vocht-energie", "Moisture, Insulation & Energy", "Damp, insulation, energy rating",        false, "AcUnit"),
        Theme("kosten",        "Financial Obligations",         "Price, taxes, charges, fees",            false, "Euro"),
        Theme("historie",      "Renovations & History",         "Works done, permits, maintenance",       false, "Build"),
        Theme("verkoper",      "Vendor & Sale Process",         "Reason for sale, process, contracts",    false, "Description")
    )

    // MARK: – English rooms
    val roomsEN = listOf(
        Room("gemeenschappelijk", "Common Areas",         "Stairwell, lift, entrance",   listOf(ViewingType.APPARTEMENT)),
        Room("gevel",             "Exterior & Facade",    "Pointing, frames, roof",       listOf(ViewingType.WONING)),
        Room("hal",               "Hallway / Entry",      "Front door, meter cupboard",   null),
        Room("woonkamer",         "Living Room",          "Floor, walls, windows",        null),
        Room("keuken",            "Kitchen",              "Appliances, plumbing",         null),
        Room("badkamer",          "Bathroom",             "Tiling, ventilation",          null),
        Room("toilet",            "WC / Toilet",          "Cistern, drainage",            null),
        Room("slaapkamer",        "Bedroom(s)",           "Per bedroom",                  null),
        Room("balkon",            "Balcony",              "Railings, drainage, aspect",   listOf(ViewingType.APPARTEMENT)),
        Room("berging",           "Storage / Utility",    "Access, dry, secure",          listOf(ViewingType.APPARTEMENT)),
        Room("zolder",            "Loft / Attic",         "Insulation, roof boarding",    listOf(ViewingType.WONING)),
        Room("kelder",            "Basement / Cellar",    "Damp, ventilation",            listOf(ViewingType.WONING)),
        Room("garage",            "Garage",               "Door, wiring",                 listOf(ViewingType.WONING)),
        Room("tuin",              "Garden / Yard",        "Fencing, paving",              listOf(ViewingType.WONING))
    )

    // MARK: – English checklist items
    val itemsEN: Map<String, List<ChecklistGroup>> = mapOf(
        "bouwkundig" to listOf(
            ChecklistGroup("Structure", listOf(
                ChecklistItem("Visible cracks in foundation or walls?", "Diagonal or horizontal cracks are more serious than hairline settlement cracks."),
                ChecklistItem("Signs of subsidence or structural movement?", "Sloping floors or sticking doors can indicate movement. Try the marble test.", null, null, Market.UK),
                ChecklistItem("Signs of settling or structural movement?", "Sloping floors or sticking doors can indicate movement. Check door frames for racking.", null, null, Market.US),
                ChecklistItem("Has the property been professionally surveyed?", "RICS Level 2 or Level 3 building survey. Essential for older properties.", null, null, Market.UK),
                ChecklistItem("Has the property been professionally inspected?", "Licensed home inspector report. Check inspector is ASHI or InterNACHI certified.", null, null, Market.US)
            )),
            ChecklistGroup("Roof & Exterior", listOf(
                ChecklistItem("When was the roof last replaced or inspected?", "Tiles or slates: 50+ years; flat roofs: 20–25 years. Ask for receipts.", null, null, Market.UK),
                ChecklistItem("When was the roof last replaced or inspected?", "Asphalt shingles: 20–30 years. Ask for receipts and any insurance claims history.", null, null, Market.US),
                ChecklistItem("Condition of gutters and downpipes?", "Check for blockages, rust, or leaks — especially at joints."),
                ChecklistItem("Any asbestos-containing materials?", "Common in pre-1980 properties. Roofing, floor tiles, insulation. Requires specialist removal.")
            )),
            ChecklistGroup("Risk Materials", listOf(
                ChecklistItem("Japanese knotweed or invasive plants on site?", "Mortgage lenders may refuse to lend on affected properties. Check garden borders.", null, null, Market.UK),
                ChecklistItem("Lead paint in pre-1978 property?", "Legally required disclosure in most US states. Test kits available at hardware stores.", null, null, Market.US),
                ChecklistItem("Building survey or home inspection report available?", "A recent professional report can highlight hidden defects and save on your own.")
            ))
        ),
        "vocht-energie" to listOf(
            ChecklistGroup("Damp & Mould", listOf(
                ChecklistItem("Evidence of dampness, mould, or water damage?", "Check corners, behind furniture, under windowsills and inside cupboards."),
                ChecklistItem("Rising damp at base of walls?", "Look for salt deposits (efflorescence), peeling paint, or tide marks near floor level."),
                ChecklistItem("Condensation issues on windows or walls?", "Can cause mould. Ask about ventilation and heating habits.")
            )),
            ChecklistGroup("Insulation", listOf(
                ChecklistItem("What insulation is in the loft or attic?", "≥270 mm mineral wool is the recommended standard. Ask for the installer certificate.", null, null, Market.UK),
                ChecklistItem("What insulation is in the attic?", "R-30 to R-60 depending on climate zone. Ask for the installer documentation.", null, null, Market.US),
                ChecklistItem("Is there cavity wall insulation?", "UK-relevant for pre-1990 properties. Ask for installation certificate.", null, null, Market.UK),
                ChecklistItem("Are windows double or triple-glazed?", "Double-glazed as a minimum (FENSA certificate). Single glazing = poor energy performance.", null, null, Market.UK),
                ChecklistItem("Are windows double or triple-pane?", "Double or triple-pane as a minimum. Single-pane windows indicate poor energy performance.", null, null, Market.US)
            )),
            ChecklistGroup("Energy Rating", listOf(
                ChecklistItem("EPC rating available and current?", "UK: legally required for sale/rental. A–G scale; aim for C or above.", null, null, Market.UK),
                ChecklistItem("ENERGY STAR certification or home energy audit available?", "US: optional but indicates efficient systems. Ask for 12 months of utility bills.", null, null, Market.US),
                ChecklistItem("Annual energy bills available?", "Ask for 12 months of gas and electricity bills to understand running costs."),
                ChecklistItem("Solar panels — owned or leased?", "Owned panels add value; leased panels transfer a financial obligation to the buyer.")
            ))
        ),
        "installaties" to listOf(
            ChecklistGroup("Heating", listOf(
                ChecklistItem("Central heating type?", "Gas boiler, oil, heat pump, biomass, or district heating.", null, null, Market.UK),
                ChecklistItem("When was the boiler last serviced?", "Should be annually. Ask to see the service record.", null, null, Market.UK),
                ChecklistItem("Gas and electrical safety certificate?", "UK: Gas Safe certificate and EICR required for rentals.", null, null, Market.UK),
                ChecklistItem("HVAC system age and condition?", "US: typical lifespan 15–20 years. Ask for service history.", null, null, Market.US),
                ChecklistItem("When was the furnace or AC unit last serviced?", "US: should be annually. Budget \$3–12k for full replacement.", null, null, Market.US)
            )),
            ChecklistGroup("Plumbing & Water", listOf(
                ChecklistItem("Septic tank or mains drainage?", "Septic tanks need regular emptying and are the buyer's responsibility.", null, null, Market.UK),
                ChecklistItem("Well or municipal water supply?", "US: rural properties may have private wells. Ask for recent water quality test results.", null, null, Market.US),
                ChecklistItem("Any lead or old galvanised pipes?", "Common in pre-1970 properties. Full replacement can run thousands of pounds.", null, null, Market.UK),
                ChecklistItem("Any lead or old galvanised pipes?", "Common in pre-1970 properties. Full replacement can run thousands of dollars.", null, null, Market.US),
                ChecklistItem("Water pressure good throughout the property?", "Run hot and cold taps simultaneously on different floors to test.")
            )),
            ChecklistGroup("Electrics", listOf(
                ChecklistItem("Consumer unit / fuse board age and condition?", "UK: should have RCDs fitted. Old-style fuse wire boards need replacing.", null, null, Market.UK),
                ChecklistItem("Electrical panel capacity and age?", "US: 200-amp panel is standard for modern homes. Knob-and-tube wiring is a red flag.", null, null, Market.US),
                ChecklistItem("Smart meter fitted?", "Required for monitoring energy use and time-of-use tariffs."),
                ChecklistItem("Broadband type available?", "Full-fibre (FTTP), cable, or telephone line only?")
            ))
        ),
        "binnen" to listOf(
            ChecklistGroup("Floors & Walls", listOf(
                ChecklistItem("Floors level and free from creaking?", "Walk the full surface. Creaking can indicate loose boards or structural movement."),
                ChecklistItem("Carpeting or hard flooring — any water damage?", "Stains, buckling, or soft spots can indicate previous leaks."),
                ChecklistItem("Walls and ceilings free from cracks?", "Hairline cracks from settling are normal; diagonal or wide cracks need investigation."),
                ChecklistItem("Paint condition — recently redecorated?", "Fresh paint over the whole house can sometimes be used to hide damp or defects.")
            )),
            ChecklistGroup("Kitchen & Bathroom", listOf(
                ChecklistItem("Kitchen appliances — included and working?", "Confirm what stays. Free-standing or integrated? Ask for manuals and warranties."),
                ChecklistItem("Kitchen and bathroom age and condition?", "Full replacement: kitchen £10–30k; bathroom £5–15k.", null, null, Market.UK),
                ChecklistItem("Kitchen and bathroom age and condition?", "Full replacement: kitchen \$15–50k; bathroom \$10–25k.", null, null, Market.US),
                ChecklistItem("Tiling, grouting, and sealant intact?", "Cracked tiles or failing sealant around the bath/shower can hide damp behind the wall."),
                ChecklistItem("No leaks under sinks or around plumbing?", "Open all cupboard doors under sinks; check for water staining or mould on base panel.")
            )),
            ChecklistGroup("Layout & Fittings", listOf(
                ChecklistItem("Enough power sockets in all rooms?", "In useful locations near furniture, worktops, and desk space."),
                ChecklistItem("Storage and built-in wardrobes?", "Confirm what's included and what the seller plans to take."),
                ChecklistItem("Fixtures and fittings list agreed?", "Fittings list should be attached to the sale contract.", null, Tenure.KOOP),
                ChecklistItem("Any asbestos concerns in older property?", "Artex ceilings, vinyl floor tiles, lagging on pipes (pre-1980). Professional survey recommended.")
            ))
        ),
        "locatie" to listOf(
            ChecklistGroup("Neighbourhood", listOf(
                ChecklistItem("Character of the area — quiet or busy?", "Visit at different times of day and on a weekday to get an honest picture."),
                ChecklistItem("Noise issues — traffic, neighbours, transport?", "Open windows during the viewing. Note proximity to main roads or railway lines."),
                ChecklistItem("Future development plans nearby?", "Check the council planning portal for nearby applications.", null, null, Market.UK),
                ChecklistItem("Future development plans nearby?", "Check the city or county planning department for nearby applications.", null, null, Market.US)
            )),
            ChecklistGroup("Amenities", listOf(
                ChecklistItem("School district quality?", "US: major factor in property values. Check state ratings.", null, null, Market.US),
                ChecklistItem("Good local schools nearby?", "UK: check Ofsted reports at ofsted.gov.uk.", null, null, Market.UK),
                ChecklistItem("Proximity to shops, healthcare, and essentials?", "Supermarket, GP/doctor, pharmacy within comfortable distance."),
                ChecklistItem("Transport links — rail, bus, motorway?", "Walking distance to station? Realistic commute time to work?"),
                ChecklistItem("Parking — permit, private, or on-street?", "Check permit zone costs and waiting lists at the council.", null, null, Market.UK),
                ChecklistItem("Parking — garage, driveway, or street?", "HOA rules may restrict on-street parking.", null, null, Market.US)
            )),
            ChecklistGroup("Risk Factors", listOf(
                ChecklistItem("Council tax band and annual cost?", "UK: check on GOV.UK. Higher bands = significantly higher annual charges.", null, null, Market.UK),
                ChecklistItem("Annual property tax rate?", "US: varies widely by state and county. Check county assessor records.", null, null, Market.US),
                ChecklistItem("Flood zone designation?", "Check the Environment Agency flood map.", null, null, Market.UK),
                ChecklistItem("Flood zone designation?", "Check FEMA flood zone maps. Properties in Zone AE may require flood insurance.", null, null, Market.US),
                ChecklistItem("Green belt or conservation area designation?", "UK: limits future extensions. Check local authority.", null, null, Market.UK),
                ChecklistItem("HOA fees, rules, and restrictions?", "US: understand what's covered, review CC&Rs, and check for pending special assessments.", null, null, Market.US)
            ))
        ),
        "verkoper" to listOf(
            ChecklistGroup("Vendor", listOf(
                ChecklistItem("Reason for selling?", "Moving, downsizing, financial difficulty? Short ownership period warrants closer inspection."),
                ChecklistItem("How long has the current owner lived here?", "Less than 2 years — ask why they're moving so soon."),
                ChecklistItem("Open and honest about known defects?", "A seller who volunteers issues is a good sign."),
                ChecklistItem("Any disputes with neighbours?", "Boundary disputes, noise complaints, rights of way. Ask directly."),
                ChecklistItem("Any planning restrictions or covenants?", "UK: restrictive covenants limiting alterations. Ask your solicitor to check the title.", null, null, Market.UK)
            )),
            ChecklistGroup("Sale Process", listOf(
                ChecklistItem("Bidding process clear?", "Sealed bids or best-and-final offers? Ask about gazumping risk.", null, Tenure.KOOP, Market.UK),
                ChecklistItem("Bidding process clear?", "Multiple offers process? Ask about escalation clauses.", null, Tenure.KOOP, Market.US),
                ChecklistItem("Finance or survey contingency available?", "Standard conditions: subject to survey and subject to mortgage.", null, Tenure.KOOP, Market.UK),
                ChecklistItem("Finance or survey contingency available?", "Standard inspection and financing contingencies.", null, Tenure.KOOP, Market.US),
                ChecklistItem("Preferred completion or moving date?", "Does the timeline work with your own situation and any chain above?"),
                ChecklistItem("Deposit and tenancy agreement explained?", "UK: deposit capped at 5 weeks' rent and must be in a government protection scheme.", null, Tenure.HUUR)
            ))
        ),
        "historie" to listOf(
            ChecklistGroup("Renovations", listOf(
                ChecklistItem("What major renovations have been completed?", "Ask for an overview with dates, invoices, and any guarantees or warranties."),
                ChecklistItem("Planning permission obtained?", "Check council planning portal. Confirm extensions or conversions had approval.", null, null, Market.UK),
                ChecklistItem("Building permits obtained?", "Check with local building department. Unpermitted work affects insurance and resale.", null, null, Market.US),
                ChecklistItem("Any unpermitted work carried out?", "Can cause issues with insurance, mortgage, or resale. Buyer may inherit liability."),
                ChecklistItem("Remaining warranties on recent work?", "Roof, boiler, HVAC, windows — ask for paperwork and check transferability.")
            )),
            ChecklistGroup("Maintenance", listOf(
                ChecklistItem("When was the exterior last painted or repointed?", "Every 10–15 years is typical.", ViewingType.WONING),
                ChecklistItem("Age of roof and last renewal?", "Flat roofs: 20–25 years; pitched tiles/slates: 50+ years.", ViewingType.WONING),
                ChecklistItem("Maintenance log or service history available?", "A well-kept log suggests a well-maintained property."),
                ChecklistItem("Service charge accounts and reserve fund?", "Leasehold flat: request last 3 years' accounts, budget, and meeting minutes.", ViewingType.APPARTEMENT, Tenure.KOOP, Market.UK),
                ChecklistItem("HOA reserve fund and accounts?", "Request last 3 years' accounts. Check for pending assessments.", ViewingType.APPARTEMENT, Tenure.KOOP, Market.US)
            )),
            ChecklistGroup("Legal & Tenure", listOf(
                ChecklistItem("Freehold or leasehold? Years remaining on lease?", "UK: below 80 years is harder to mortgage and expensive to extend.", null, Tenure.KOOP, Market.UK),
                ChecklistItem("Any restrictive covenants or easements on the title?", "Can limit what you can do with the property. Ask your solicitor to check."),
                ChecklistItem("HOA documents and meeting minutes reviewed?", "US: CC&Rs, bylaws, minutes. Look for pending assessments or litigation.", ViewingType.APPARTEMENT, Tenure.KOOP, Market.US)
            ))
        ),
        "kosten" to listOf(
            ChecklistGroup("Purchase Costs", listOf(
                ChecklistItem("Is the asking price in line with the market?", "Check Rightmove or Zoopla sold prices for comparable properties nearby.", null, Tenure.KOOP, Market.UK),
                ChecklistItem("Is the asking price in line with the market?", "Check Zillow or Redfin recent comparable sales (comps) within 0.5 miles.", null, Tenure.KOOP, Market.US),
                ChecklistItem("Estimated buying costs?", "Stamp duty, solicitor fees, survey. Budget 2–5% of the purchase price on top.", null, Tenure.KOOP, Market.UK),
                ChecklistItem("Estimated buying costs?", "Closing costs typically 2–5% of the purchase price: title insurance, escrow, lender fees.", null, Tenure.KOOP, Market.US),
                ChecklistItem("Mortgage borrowing capacity confirmed?", "Agreement in principle obtained? Stress-tested at higher interest rates?", null, Tenure.KOOP),
                ChecklistItem("Estimated renovation or repair budget?", "Add a 10–20% contingency buffer on top of any contractor quotes.", null, Tenure.KOOP)
            )),
            ChecklistGroup("Ongoing Costs", listOf(
                ChecklistItem("Annual council tax and typical utility costs?", "UK: council tax band determines the annual charge.", null, null, Market.UK),
                ChecklistItem("Annual property taxes and typical utility costs?", "US: taxes vary widely by state. Ask seller for recent utility bills.", null, null, Market.US),
                ChecklistItem("Service charge and ground rent (leasehold)?", "UK: review last 3 years' accounts. Watch for escalating ground rent clauses.", ViewingType.APPARTEMENT, null, Market.UK),
                ChecklistItem("HOA fees — monthly and annual?", "US: understand what's covered and check reserve fund health.", ViewingType.APPARTEMENT, null, Market.US),
                ChecklistItem("Any outstanding mortgages, liens, or charges?", "Check Land Registry for charges and restrictions on the title.", null, null, Market.UK),
                ChecklistItem("Any outstanding mortgages, liens, or charges?", "A title search will reveal all encumbrances.", null, null, Market.US)
            )),
            ChecklistGroup("Rental-Specific", listOf(
                ChecklistItem("Monthly rent — what's included?", "Get a clear breakdown of rent vs. separately billed items.", null, Tenure.HUUR),
                ChecklistItem("Service charges itemised?", "Confirm breakdown and whether there's an annual reconciliation.", null, Tenure.HUUR),
                ChecklistItem("Energy and bills included or separate?", "Bills-included rents are convenient but check they fairly reflect actual usage.", null, Tenure.HUUR),
                ChecklistItem("Rent charges — are they escalating?", "UK: watch for leasehold rent charges with doubling clauses.", null, Tenure.HUUR, Market.UK)
            ))
        ),
        "gevoel" to listOf(
            ChecklistGroup("First Impression", listOf(
                ChecklistItem("Does the first impression still hold up?", "Compare your gut feeling at the door with what you've found on closer inspection."),
                ChecklistItem("Natural light levels throughout the day?", "Check multiple rooms, not just the living room. Which way do the main rooms face?"),
                ChecklistItem("Does the layout work for your lifestyle?", "Think through daily routines: cooking, eating, working from home, storage."),
                ChecklistItem("Atmosphere and feel of the property?", "Does it feel like home, or would you need major work before it does?")
            )),
            ChecklistGroup("Future Suitability", listOf(
                ChecklistItem("Bedroom count suitable now and in 5 years?", "Consider family growth, home office, or guest room needs."),
                ChecklistItem("Work-from-home space available?", "Dedicated room, quiet alcove, or would you need to convert a space?"),
                ChecklistItem("Garden or outdoor space adequate?", "Size, aspect, privacy, and ongoing maintenance level."),
                ChecklistItem("Parking situation adequate?", "Driveway, garage, permit zone, or competitive street parking?"),
                ChecklistItem("Future development plans in the area?", "Check planning applications locally."),
                ChecklistItem("Fits within budget without financial stress?", "Monthly costs comfortable at current rates? What if rates rise?"),
                ChecklistItem("Neighbourhood suits your lifestyle?", "Quiet vs. lively, walkable, community feel, long-term fit.")
            ))
        ),
        "gemeenschappelijk" to listOf(
            ChecklistGroup("Entry & Access", listOf(
                ChecklistItem("Communal entrance clean and well-maintained?"),
                ChecklistItem("Door entry system and intercom working?"),
                ChecklistItem("Post boxes and letterboxes in order?")
            )),
            ChecklistGroup("Stairwell & Lift", listOf(
                ChecklistItem("Stairwell décor and condition?"),
                ChecklistItem("Lift present and certificate current?"),
                ChecklistItem("Noise from landing or corridors?")
            )),
            ChecklistGroup("Building Maintenance", listOf(
                ChecklistItem("Exterior last painted or treated?"),
                ChecklistItem("Roof condition and last renewal?"),
                ChecklistItem("Long-term maintenance plan in place?")
            ))
        ),
        "gevel" to listOf(
            ChecklistGroup("Brickwork & Pointing", listOf(
                ChecklistItem("Cracks in brickwork or mortar?"),
                ChecklistItem("Pointing in good condition?"),
                ChecklistItem("Staining or damp penetration marks?"),
                ChecklistItem("Cavity wall insulation present?")
            )),
            ChecklistGroup("Roof & Chimney", listOf(
                ChecklistItem("Roof tiles or slates — visible condition?"),
                ChecklistItem("Gutters and downpipes intact and clear?"),
                ChecklistItem("Chimney stack upright, mortar sound?"),
                ChecklistItem("Roof penetrations and fascia boards?")
            )),
            ChecklistGroup("Windows & Frames", listOf(
                ChecklistItem("Window frames: rot, damage, or failing seals?"),
                ChecklistItem("Double or triple-glazed throughout?"),
                ChecklistItem("External paintwork or cladding condition?"),
                ChecklistItem("Window locks and hardware working?")
            ))
        ),
        "hal" to listOf(
            ChecklistGroup("Front Door & Security", listOf(
                ChecklistItem("Front door closes and seals properly?"),
                ChecklistItem("Multi-point lock or security rating?"),
                ChecklistItem("Draught-proofing strip fitted?"),
                ChecklistItem("Letterbox and spy hole present?", null, ViewingType.WONING)
            )),
            ChecklistGroup("Meter & Services", listOf(
                ChecklistItem("Consumer unit / fuse board accessible and tidy?"),
                ChecklistItem("Smart meter fitted?"),
                ChecklistItem("Broadband connection — fibre or cable?")
            )),
            ChecklistGroup("Stairs & Floor", listOf(
                ChecklistItem("Staircase solid, handrail secure?", null, ViewingType.WONING),
                ChecklistItem("Staircase headroom adequate?", null, ViewingType.WONING),
                ChecklistItem("Floor level and undamaged?")
            ))
        ),
        "woonkamer" to listOf(
            ChecklistGroup("Floor & Walls", listOf(
                ChecklistItem("Floors level and even?"),
                ChecklistItem("Type of flooring — any damage or wear?"),
                ChecklistItem("Cracks in ceiling or walls?"),
                ChecklistItem("Any damp patches visible?"),
                ChecklistItem("Sound insulation from neighbours?")
            )),
            ChecklistGroup("Windows & Heating", listOf(
                ChecklistItem("Windows open, close, and lock properly?"),
                ChecklistItem("Trickle vents or ventilation present?"),
                ChecklistItem("Radiators working and balanced?"),
                ChecklistItem("Underfloor heating fitted?")
            )),
            ChecklistGroup("Electrics & Data", listOf(
                ChecklistItem("Enough power sockets?"),
                ChecklistItem("TV aerial or cable point?"),
                ChecklistItem("Light fittings in practical positions?")
            ))
        ),
        "keuken" to listOf(
            ChecklistGroup("Appliances", listOf(
                ChecklistItem("Appliances staying with the property?"),
                ChecklistItem("Age and condition of appliances?"),
                ChecklistItem("Induction, gas, or electric hob?")
            )),
            ChecklistGroup("Plumbing & Ventilation", listOf(
                ChecklistItem("Extractor ducted to outside?"),
                ChecklistItem("Dishwasher connection available?"),
                ChecklistItem("Washing machine connection in kitchen?"),
                ChecklistItem("No leaks under the sink?")
            )),
            ChecklistGroup("Finishes", listOf(
                ChecklistItem("Tiles and sealant in good condition?"),
                ChecklistItem("Adequate worktop space?"),
                ChecklistItem("Under-cabinet or task lighting?")
            ))
        ),
        "badkamer" to listOf(
            ChecklistGroup("Tiling & Finishes", listOf(
                ChecklistItem("Tiles free from cracks or missing grout?"),
                ChecklistItem("Sealant clean and watertight?"),
                ChecklistItem("No signs of mould or damp?"),
                ChecklistItem("Age and overall condition of bathroom?")
            )),
            ChecklistGroup("Plumbing & Water", listOf(
                ChecklistItem("Shower or bath draining properly?"),
                ChecklistItem("Good hot water pressure?"),
                ChecklistItem("Basin taps and drain working?")
            )),
            ChecklistGroup("Ventilation & Electrics", listOf(
                ChecklistItem("Mechanical extractor fan working?"),
                ChecklistItem("Shaver socket safe for wet area?"),
                ChecklistItem("Towel rail or radiator present?")
            ))
        ),
        "toilet" to listOf(
            ChecklistGroup("Sanitary Ware", listOf(
                ChecklistItem("Cistern fills and shuts off properly?"),
                ChecklistItem("No drain odour?"),
                ChecklistItem("Basin and tap working?")
            )),
            ChecklistGroup("Finishes & Ventilation", listOf(
                ChecklistItem("Tiling and sealant in good condition?"),
                ChecklistItem("Ventilation — window or extractor?"),
                ChecklistItem("Light working?")
            ))
        ),
        "slaapkamer" to listOf(
            ChecklistGroup("Layout & Light", listOf(
                ChecklistItem("Number of bedrooms as described?"),
                ChecklistItem("Good natural light and window size?"),
                ChecklistItem("Blackout blinds or curtains possible?"),
                ChecklistItem("Built-in wardrobes or storage?")
            )),
            ChecklistGroup("Finishes", listOf(
                ChecklistItem("Any damp on external walls?"),
                ChecklistItem("Floors and skirting boards in good order?"),
                ChecklistItem("Sound insulation from neighbours or road?")
            )),
            ChecklistGroup("Services", listOf(
                ChecklistItem("Power sockets and TV / data points?"),
                ChecklistItem("Radiator or heating present?")
            ))
        ),
        "balkon" to listOf(
            ChecklistGroup("Structure", listOf(
                ChecklistItem("Balcony floor and railings secure?"),
                ChecklistItem("No cracks in concrete edge or walls?"),
                ChecklistItem("Rainwater drainage working?")
            )),
            ChecklistGroup("Use & Aspect", listOf(
                ChecklistItem("Sun aspect — morning or afternoon?"),
                ChecklistItem("Privacy from neighbouring properties?"),
                ChecklistItem("External tap or power socket?")
            ))
        ),
        "berging" to listOf(
            ChecklistGroup("Access & Condition", listOf(
                ChecklistItem("Storage easily accessible?"),
                ChecklistItem("Dry and free from mould?"),
                ChecklistItem("Lock and key present?"),
                ChecklistItem("Light and power socket?")
            ))
        ),
        "zolder" to listOf(
            ChecklistGroup("Access", listOf(
                ChecklistItem("Fixed staircase or loft hatch?"),
                ChecklistItem("Adequate headroom throughout?")
            )),
            ChecklistGroup("Roof Structure", listOf(
                ChecklistItem("Roof boards dry and intact?"),
                ChecklistItem("Rafters visible and sound?"),
                ChecklistItem("Any damp at skylights or roof windows?")
            )),
            ChecklistGroup("Insulation & Climate", listOf(
                ChecklistItem("Insulation layer visible and adequate?"),
                ChecklistItem("Roof window or ventilation present?"),
                ChecklistItem("Temperature acceptable in summer?")
            ))
        ),
        "kelder" to listOf(
            ChecklistGroup("Damp & Smell", listOf(
                ChecklistItem("Damp patches on walls or floor?"),
                ChecklistItem("Any musty or mouldy smell?"),
                ChecklistItem("Salt deposits on walls?")
            )),
            ChecklistGroup("Access & Use", listOf(
                ChecklistItem("Ventilation present?"),
                ChecklistItem("Adequate headroom?"),
                ChecklistItem("Safe staircase access?"),
                ChecklistItem("Usable as utility room or storage?")
            ))
        ),
        "garage" to listOf(
            ChecklistGroup("Structure & Door", listOf(
                ChecklistItem("Garage door operates correctly?"),
                ChecklistItem("Draught seal at base of door?"),
                ChecklistItem("No damp or roof leaks?"),
                ChecklistItem("Integral or detached garage?")
            )),
            ChecklistGroup("Services", listOf(
                ChecklistItem("Separate circuit from consumer unit?"),
                ChecklistItem("EV charging point connection possible?"),
                ChecklistItem("Lighting and power sockets?")
            ))
        ),
        "tuin" to listOf(
            ChecklistGroup("Boundaries", listOf(
                ChecklistItem("Boundary fences or walls — ownership clear?"),
                ChecklistItem("Trees: ownership and maintenance responsibility?"),
                ChecklistItem("Any easements or rights of way?")
            )),
            ChecklistGroup("Maintenance & Use", listOf(
                ChecklistItem("Paving or decking level and stable?"),
                ChecklistItem("Garden shed or outbuilding?"),
                ChecklistItem("Outside tap?"),
                ChecklistItem("Sun aspect — morning or afternoon?"),
                ChecklistItem("Side gate or rear access?")
            ))
        )
    )

    // MARK: – Helpers

    private fun useEnglish(_market: Market) = false

    fun themes(type: ViewingType, market: Market = Market.NL): List<Theme> =
        if (useEnglish(market)) themesEN else themes

    fun rooms(type: ViewingType, market: Market = Market.NL): List<Room> {
        val source = if (useEnglish(market)) roomsEN else rooms
        return source.filter { it.visible(type) }
    }

    fun groups(entryId: String, type: ViewingType, tenure: Tenure, market: Market = Market.NL): List<ChecklistGroup> {
        val source = if (useEnglish(market)) itemsEN else items
        return (source[entryId] ?: emptyList()).mapNotNull { g ->
            val filtered = g.items.filter {
                (it.onlyType == null || it.onlyType == type) &&
                (it.onlyTenure == null || it.onlyTenure == tenure) &&
                (it.onlyMarket == null || it.onlyMarket == market)
            }
            if (filtered.isEmpty()) null else ChecklistGroup(g.category, filtered)
        }
    }

    fun flatItems(entryId: String, type: ViewingType, tenure: Tenure, market: Market = Market.NL): List<FlatItem> {
        var idx = 0
        return groups(entryId, type, tenure, market).flatMap { g ->
            g.items.map { item ->
                FlatItem(item, g.category, idx, "$entryId-${idx++}")
            }
        }
    }

    fun totalItems(entryId: String, type: ViewingType, tenure: Tenure, market: Market = Market.NL): Int =
        flatItems(entryId, type, tenure, market).size

    fun answeredCount(entryId: String, answers: Map<String, String>, type: ViewingType, tenure: Tenure, market: Market = Market.NL): Int =
        flatItems(entryId, type, tenure, market).count { answers.containsKey(it.key) }
}
