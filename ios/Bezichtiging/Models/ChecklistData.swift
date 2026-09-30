import Foundation

struct Room: Identifiable, Sendable {
    let id: String; let label: String; let sub: String; let types: [ViewingType]?
    func visible(for type: ViewingType) -> Bool { types == nil || types!.contains(type) }
}

struct Theme: Identifiable, Sendable {
    let id: String; let label: String; let sub: String; let featured: Bool; let icon: String
}

struct ChecklistGroup: Sendable {
    let category: String; let items: [ChecklistItem]
}

struct ChecklistItem: Identifiable, Sendable {
    let id = UUID()
    let label: String; let hint: String?
    let onlyType: ViewingType?; let onlyTenure: Tenure?; let onlyMarket: Market?
    init(_ label: String, hint: String? = nil, only type: ViewingType? = nil, tenure: Tenure? = nil, market: Market? = nil) {
        self.label = label; self.hint = hint; onlyType = type; onlyTenure = tenure; onlyMarket = market
    }
}

struct FlatItem: Identifiable, Sendable {
    let id = UUID()
    let item: ChecklistItem; let category: String; let flatIndex: Int; let key: String
}

enum ChecklistData {
    // MARK: – Themes
    static let themes: [Theme] = [
        .init(id: "locatie",       label: "Locatie en omgeving",        sub: "Buurt, voorzieningen, geluid",      featured: true,  icon: "tree"),
        .init(id: "gevoel",        label: "Gevoel en geschiktheid",     sub: "Eerste indruk, toekomst",           featured: false, icon: "face.smiling"),
        .init(id: "bouwkundig",    label: "Bouwkundige staat",          sub: "Fundering, dak, scheuren",          featured: false, icon: "hammer"),
        .init(id: "binnen",        label: "Binnenkant en afwerking",    sub: "Vloeren, wanden, keuken, sanitair", featured: false, icon: "paintbrush"),
        .init(id: "installaties",  label: "Installaties en techniek",   sub: "CV, elektra, water, ventilatie",   featured: false, icon: "powerplug"),
        .init(id: "vocht-energie", label: "Vocht, isolatie en energie", sub: "Vocht, isolatie, energielabel",    featured: false, icon: "snowflake"),
        .init(id: "kosten",        label: "Kosten en verplichtingen",   sub: "Prijs, lasten, VvE, erfpacht",     featured: false, icon: "eurosign.circle"),
        .init(id: "historie",      label: "Verbouwingen en historie",   sub: "Aanbouw, vergunningen, onderhoud", featured: false, icon: "wrench.and.screwdriver"),
        .init(id: "verkoper",      label: "Verkoper en verkoopproces",  sub: "Reden, contact, voorbehoud",       featured: false, icon: "doc.text"),
    ]

    // MARK: – Rooms
    static let rooms: [Room] = [
        .init(id: "gemeenschappelijk", label: "Gemeenschappelijk",  sub: "Trappenhuis, lift, entree",    types: [.appartement]),
        .init(id: "gevel",             label: "Gevel & buitenkant", sub: "Voegwerk, kozijnen, dak",      types: [.woning]),
        .init(id: "hal",               label: "Hal / entree",       sub: "Voordeur, meterkast",          types: nil),
        .init(id: "woonkamer",         label: "Woonkamer",          sub: "Vloer, wanden, ramen",         types: nil),
        .init(id: "keuken",            label: "Keuken",             sub: "Apparatuur, leidingen",        types: nil),
        .init(id: "badkamer",          label: "Badkamer",           sub: "Tegelwerk, ventilatie",        types: nil),
        .init(id: "toilet",            label: "Toilet",             sub: "Stortbak, afvoer",             types: nil),
        .init(id: "slaapkamer",        label: "Slaapkamer(s)",      sub: "Per slaapkamer",               types: nil),
        .init(id: "balkon",            label: "Balkon",             sub: "Hekwerk, afvoer, ligging",     types: [.appartement]),
        .init(id: "berging",           label: "Berging",            sub: "Toegang, droog, bereikbaar",   types: [.appartement]),
        .init(id: "zolder",            label: "Zolder",             sub: "Isolatie, dakbeschot",         types: [.woning]),
        .init(id: "kelder",            label: "Kelder / berging",   sub: "Vocht, ventilatie",            types: [.woning]),
        .init(id: "garage",            label: "Garage",             sub: "Deur, bekabeling",             types: [.woning]),
        .init(id: "tuin",              label: "Tuin / buiten",      sub: "Schutting, bestrating",        types: [.woning]),
    ]

    // MARK: – Items
    static let items: [String: [ChecklistGroup]] = [
        "bouwkundig": [
            .init(category: "Constructie", items: [
                .init("Bouwjaar en grote renovaties",          hint: "Vraag jaartal en laatste verbouwingen op."),
                .init("Funderingsrapport aanwezig",            hint: "Bij vooroorlogse woning altijd opvragen.", only: .woning, tenure: .koop),
                .init("Scheuren in muren of plafond",          hint: "Haarscheurtjes (krimp) of doorlopende scheuren?"),
                .init("Verzakkingen of scheefstand vloeren",   hint: "Leg een knikker neer of gebruik een waterpas."),
            ]),
            .init(category: "Dak & gevel", items: [
                .init("Staat dakpannen en dakgoten",           hint: "Verzakte pannen, mos, lekkagesporen.", only: .woning),
                .init("Voegwerk en metselwerk",                hint: "Uitgesleten voegen, doorslag, scheuren.", only: .woning),
                .init("Kozijnen houtrot of beschadigd",        hint: "Prik onderaan het kozijn met een sleutel."),
                .init("Schoorsteen recht en intact",           hint: "Loszittend voegwerk = lekkagerisico.", only: .woning),
            ]),
            .init(category: "Risicomaterialen", items: [
                .init("Asbestverdachte materialen",            hint: "Daken, golfplaten, leidingisolatie, vinyl."),
                .init("Bouwkundig keuringsrapport beschikbaar", hint: "Recent rapport scheelt een eigen keuring.", tenure: .koop),
            ]),
        ],
        "vocht-energie": [
            .init(category: "Vocht", items: [
                .init("Vochtplekken op muren of plafond",      hint: "Vooral in hoeken, bij ramen en plafonds."),
                .init("Schimmelvorming op koude muren",        hint: "Kijk achter kasten en in hoeken."),
                .init("Optrekkend vocht onderaan muren",       hint: "Zoutuitslag en verkleuring aan de onderkant."),
                .init("Muffe geur (kelder, kruipruimte)",      hint: "Wijst op onvoldoende ventilatie."),
            ]),
            .init(category: "Isolatie", items: [
                .init("Energielabel definitief",               hint: "Niet voorlopig. Geldigheid 10 jaar."),
                .init("Dakisolatie aanwezig",                  hint: "Vraag de isolatiewaarde (Rc) op."),
                .init("Vloerisolatie aanwezig",                hint: "Cruciaal bij de begane grond."),
                .init("Spouwmuurisolatie aanwezig",            hint: "Vooral bij woningen vóór 1990.", only: .woning),
                .init("Dubbel glas of HR++",                   hint: "Check alle ramen — vaak niet overal."),
            ]),
            .init(category: "Energie", items: [
                .init("Tochtklachten bij ramen en deuren",     hint: "Houd je hand langs de naden tijdens bezichtiging."),
                .init("Zonnepanelen: aantal en eigendom",      hint: "Gehuurd of gekocht, leeftijd, opbrengst."),
                .init("Aansluiting laadpaal mogelijk",         hint: "Krachtstroom en plek in meterkast."),
            ]),
        ],
        "installaties": [
            .init(category: "Verwarming", items: [
                .init("Type warmtebron",                       hint: "Gas, hybride, warmtepomp, stadsverwarming."),
                .init("CV-ketel: bouwjaar en onderhoud",       hint: "Ouder dan 15 jaar = vervanging plannen."),
                .init("Stadsverwarming of blokverwarming",     hint: "Gebonden aan vaste leverancier en tarief.", only: .appartement),
                .init("Vloerverwarming aanwezig",              hint: "In welke ruimtes; aparte verdeler?"),
                .init("Radiatoren werken en zijn ontlucht",    hint: "Voel of ze gelijkmatig warm worden."),
            ]),
            .init(category: "Elektra", items: [
                .init("Meterkast: aantal groepen",             hint: "Minimaal 3, liever meer voor moderne apparatuur."),
                .init("Aardlekschakelaar aanwezig",            hint: "Verplicht in natte ruimtes sinds 1975."),
                .init("Slimme meter aanwezig",                 hint: "Nodig voor saldering zonnepanelen."),
            ]),
            .init(category: "Water & ventilatie", items: [
                .init("Loden waterleidingen",                  hint: "Komt voor in woningen vóór 1960."),
                .init("Mechanische ventilatie of WTW",         hint: "WTW = warmteterugwin, energiezuiniger."),
                .init("Riolering aansluiting",                 hint: "Gemeentelijk riool of IBA?", only: .woning),
                .init("Internet en data-aansluiting",          hint: "CAI of glasvezel beschikbaar in de straat?"),
            ]),
        ],
        "binnen": [
            .init(category: "Vloeren & wanden", items: [
                .init("Vloer waterpas en zonder kraken",       hint: "Loop het hele oppervlak af."),
                .init("Type vloer (zwevend, vast)",            hint: "Zwevend = eenvoudiger te vervangen."),
                .init("Wanden en plafonds zonder scheuren",    hint: "Haarscheurtjes door krimp zijn normaal."),
                .init("Plinten en aansluitingen netjes",       hint: "Verraadt vakwerk van vorige eigenaar."),
            ]),
            .init(category: "Keuken & badkamer", items: [
                .init("Keuken: leeftijd en staat",             hint: "Volledige vervanging kost € 8 – 25 k."),
                .init("Apparatuur compleet en functioneel",    hint: "Vraag wat achterblijft."),
                .init("Badkamer: leeftijd en staat",           hint: "Renovatie kost € 8 – 15 k."),
                .init("Sanitair compleet en zonder lekkage",   hint: "Toilet, douche, wastafel, kitwerk."),
            ]),
            .init(category: "Indeling & afwerking", items: [
                .init("Voldoende stopcontacten en lichtpunten", hint: "Op logische plek bij meubels."),
                .init("Inbouwkasten en opbergruimte",          hint: "Wat blijft achter, wat gaat mee?"),
                .init("Lijst van roerende zaken duidelijk",    hint: "Officieel formulier bij de makelaar.", tenure: .koop),
                .init("Inboedel — wat blijft achter",          hint: "Maak foto's; voorkomt discussie later.", tenure: .huur),
            ]),
        ],
        "locatie": [
            .init(category: "Buurt", items: [
                .init("Buurt: rustig of druk",                 hint: "Bezoek ook op een ander tijdstip."),
                .init("Geluidsoverlast (verkeer, horeca, buren)", hint: "Open ramen even tijdens de bezichtiging."),
                .init("Veiligheid en sociale controle",        hint: "Verlichting, fietsen, hangplekken."),
                .init("Toekomstige bouwplannen in de buurt",   hint: "Check de gemeentewebsite voor projecten."),
            ]),
            .init(category: "Voorzieningen", items: [
                .init("Winkels op loopafstand",                hint: "Supermarkt, bakker, apotheek."),
                .init("Scholen en kinderopvang in de buurt",   hint: "Indien van toepassing."),
                .init("OV-verbindingen (bus, tram, station)",  hint: "Loopafstand en frequentie."),
                .init("Parkeren (vergunning, eigen plek)",     hint: "Vergunningskosten en wachtlijst."),
            ]),
            .init(category: "Ligging", items: [
                .init("Groen, parken en speelmogelijkheden",   hint: "Belangrijk met kinderen of hond."),
                .init("Ligging en zon (woonkamer / tuin)",     hint: "Oost / west / zuid? Wanneer schaduw?"),
            ]),
        ],
        "verkoper": [
            .init(category: "Verkoper", items: [
                .init("Reden van verkoop",                     hint: "Verhuizen, scheiden, financieel?"),
                .init("Hoe lang in bezit",                     hint: "Korter dan 2 jaar = extra op letten."),
                .init("Eerlijk over gebreken",                 hint: "Wijst zelf op punten = goed teken."),
                .init("Bewoner of belegger",                   hint: "Belegger kent vaak minder details."),
            ]),
            .init(category: "Proces", items: [
                .init("Makelaar: prettig contact",             hint: "Reageert snel, eerlijk over biedingen."),
                .init("Biedingsprocedure helder",              hint: "Gesloten of open biedingen?", tenure: .koop),
                .init("Voorbehoud financiering mogelijk",      hint: "Standaard 4 – 6 weken; check duur.", tenure: .koop),
                .init("Voorbehoud bouwkundige keuring",        hint: "Belangrijk bij oudere woningen.", tenure: .koop),
                .init("Gewenste opleverdatum",                 hint: "Past dit bij jullie planning?"),
                .init("Borg en huurcontract toegelicht",       hint: "Borg max. 2 maanden kale huur (sinds 2023).", tenure: .huur),
            ]),
        ],
        "historie": [
            .init(category: "Verbouwingen", items: [
                .init("Uitgevoerde verbouwingen (overzicht)",  hint: "Vraag om bonnen en garantiebewijzen."),
                .init("Met vergunning verbouwd",               hint: "Aanbouw, dakkapel, dakopbouw."),
                .init("Wijzigingen aan dragende constructie",  hint: "Met constructieberekening?"),
                .init("Eigen werk vorige eigenaar",            hint: "Doe-het-zelf = vaker verborgen gebreken."),
            ]),
            .init(category: "Onderhoud", items: [
                .init("Recente schilder- of voegbeurt",        hint: "Wanneer voor het laatst gedaan?", only: .woning),
                .init("Leeftijd dak en laatste vernieuwing",   hint: "Plat dak 25–30 jr, pannen 50+ jr.", only: .woning),
                .init("Onderhoudslogboek aanwezig",            hint: "Vorige eigenaar bijgehouden?"),
                .init("MJOP van de VvE inzichtelijk",          hint: "Meerjarenonderhoudsplan.", only: .appartement, tenure: .koop),
            ]),
            .init(category: "Juridisch", items: [
                .init("Bestemmingsplan klopt met gebruik",     hint: "Geen woon-werk-conflict?"),
                .init("Erfdienstbaarheden / kettingbeding",    hint: "Recht van overpad, kwalitatieve verplichting.", tenure: .koop),
                .init("Splitsingsakte ingezien",               hint: "Wat mag wel/niet binnen de VvE.", only: .appartement, tenure: .koop),
            ]),
        ],
        "kosten": [
            .init(category: "Aankoopkosten", items: [
                .init("Vraagprijs marktconform",               hint: "Vergelijk met de buurt (Funda, NVM).", tenure: .koop),
                .init("Kosten koper ingeschat",                hint: "Overdrachtsbelasting + notaris + advies.", tenure: .koop),
                .init("Hypotheek-mogelijkheid getoetst",       hint: "Maximale lening, NHG-grens.", tenure: .koop),
                .init("Geschatte verbouwingskosten",           hint: "Reserveer ~10% extra buffer.", tenure: .koop),
            ]),
            .init(category: "Maandlasten", items: [
                .init("WOZ-waarde en OZB",                     hint: "Bepaalt gemeentelijke belastingen."),
                .init("Energiekosten gemiddeld",               hint: "Vraag jaaroverzicht (gas, stroom)."),
                .init("VvE-bijdrage per maand",                hint: "Vraag specificatie en MJOP.", only: .appartement),
                .init("Erfpacht canon en einddatum",           hint: "Eeuwigdurend of tijdelijk afgekocht?", tenure: .koop),
            ]),
            .init(category: "Huurspecifiek", items: [
                .init("Kale huurprijs per maand",              hint: "Zonder service en G/W/L.", tenure: .huur),
                .init("Servicekosten en specificatie",         hint: "Uitsplitsing + jaarafrekening.", tenure: .huur),
                .init("Energie inclusief of exclusief",        hint: "Voorschot of vast bedrag?", tenure: .huur),
                .init("Sociale huur of vrije sector",          hint: "WWS-puntensysteem bepaalt huurprijs.", tenure: .huur),
            ]),
        ],
        "gevoel": [
            .init(category: "Eerste indruk", items: [
                .init("Eerste indruk klopt nog steeds",        hint: "Vergelijk met je gevoel bij binnenkomst."),
                .init("Voldoende daglicht",                    hint: "In meerdere kamers, niet alleen woonkamer."),
                .init("Indeling werkt voor jullie",            hint: "Kook-, eet-, werkplek."),
                .init("Sfeer en uitstraling",                  hint: "Voelt het thuis of moet je veel veranderen?"),
            ]),
            .init(category: "Toekomst", items: [
                .init("Aantal kamers past",                    hint: "Nu en over 5 jaar."),
                .init("Toekomstbestendig (kinderen, thuiswerken)", hint: "Werkplek, slaapkamers, uitbreiding."),
                .init("Tuin of buitenruimte voldoet",          hint: "Grootte, ligging, onderhoud."),
                .init("Past in budget zonder zorgen",          hint: "Geen maandelijkse stress."),
                .init("Buurt past bij jullie levensstijl",     hint: "Rustig vs. levendig, gezinnen vs. jong."),
            ]),
        ],
        // MARK: Individual rooms
        "gemeenschappelijk": [
            .init(category: "Entree & toegang", items: [
                .init("Entree schoon en verzorgd"),
                .init("Bellentableau en intercom werken"),
                .init("Brievenbussen op orde"),
            ]),
            .init(category: "Trappenhuis & lift", items: [
                .init("Trappenhuis: staat schilderwerk"),
                .init("Lift aanwezig en gekeurd"),
                .init("Geluidsoverlast op galerij / trap"),
            ]),
            .init(category: "Onderhoud", items: [
                .init("Recente schilderbeurt buitenzijde"),
                .init("Dak: laatste vernieuwing"),
                .init("MJOP voorziet in komende posten"),
            ]),
        ],
        "gevel": [
            .init(category: "Metselwerk & voegen", items: [
                .init("Scheuren in metselwerk"),
                .init("Voegwerk intact en strak"),
                .init("Verkleuring of doorslag"),
                .init("Spouwmuurisolatie aanwezig"),
            ]),
            .init(category: "Dak & schoorsteen", items: [
                .init("Dakpannen op zicht"),
                .init("Dakgoten en hemelwaterafvoer"),
                .init("Schoorsteen recht en intact"),
                .init("Dakdoorvoeren en boeidelen"),
            ]),
            .init(category: "Kozijnen & glas", items: [
                .init("Kozijnen: houtrot of beschadiging"),
                .init("Dubbel glas of HR++"),
                .init("Schilderwerk buiten"),
                .init("Hang- en sluitwerk ramen"),
            ]),
        ],
        "hal": [
            .init(category: "Voordeur & sluitwerk", items: [
                .init("Voordeur sluit goed"),
                .init("Hang- en sluitwerk SKG-keurmerk"),
                .init("Tochtstrip en kierdichting"),
                .init("Brievenbus en kijkgat", only: .woning),
            ]),
            .init(category: "Meterkast & techniek", items: [
                .init("Meterkast bereikbaar en geordend"),
                .init("Slimme meter aanwezig"),
                .init("Internet-aansluiting (CAI / glas)"),
            ]),
            .init(category: "Trap & vloer", items: [
                .init("Trap stevig, leuning vast", only: .woning),
                .init("Trap voldoet aan maatvoering", only: .woning),
                .init("Vloer vlak, geen scheuren"),
            ]),
        ],
        "woonkamer": [
            .init(category: "Vloer & wanden", items: [
                .init("Vloer waterpas"),
                .init("Type vloer (zwevend, vast)"),
                .init("Scheuren in plafond of wanden"),
                .init("Vochtplekken"),
                .init("Geluidsisolatie van buren"),
            ]),
            .init(category: "Ramen & klimaat", items: [
                .init("Ramen openen en sluiten"),
                .init("Ventilatieroosters aanwezig"),
                .init("Radiatoren werken"),
                .init("Vloerverwarming aanwezig"),
            ]),
            .init(category: "Elektra & data", items: [
                .init("Voldoende stopcontacten"),
                .init("TV / data-aansluiting"),
                .init("Lichtpunten op logische plek"),
            ]),
        ],
        "keuken": [
            .init(category: "Apparatuur", items: [
                .init("Apparatuur blijft achter"),
                .init("Leeftijd en staat apparatuur"),
                .init("Inductie of gas"),
            ]),
            .init(category: "Aansluitingen & afzuiging", items: [
                .init("Afzuigkap afvoer naar buiten"),
                .init("Aansluiting vaatwasser aanwezig"),
                .init("Aansluiting wasmachine in keuken?"),
                .init("Geen lekkage onder gootsteen"),
            ]),
            .init(category: "Afwerking", items: [
                .init("Tegels en kitwerk intact"),
                .init("Voldoende werkbladruimte"),
                .init("Verlichting boven werkblad"),
            ]),
        ],
        "badkamer": [
            .init(category: "Tegelwerk & afwerking", items: [
                .init("Tegelwerk zonder scheuren"),
                .init("Kitwerk schoon en heel"),
                .init("Geen schimmel of vocht"),
                .init("Leeftijd badkamer"),
            ]),
            .init(category: "Sanitair & water", items: [
                .init("Douche / bad: afvoer en lekkage"),
                .init("Warmwater drukvol"),
                .init("Wastafel kraan en afvoer"),
                .init("Toilet in badkamer (indien aanwezig)"),
            ]),
            .init(category: "Ventilatie & elektra", items: [
                .init("Mechanische ventilatie aanwezig"),
                .init("Stopcontact (geaard, spatwater)"),
                .init("Vloerverwarming of radiator"),
            ]),
        ],
        "toilet": [
            .init(category: "Sanitair", items: [
                .init("Stortbak werkt en sluit af"),
                .init("Afvoer geen geur"),
                .init("Fonteintje / kraan werkt"),
            ]),
            .init(category: "Afwerking & ventilatie", items: [
                .init("Tegelwerk en kit"),
                .init("Ventilatierooster aanwezig"),
                .init("Verlichting werkt"),
            ]),
        ],
        "slaapkamer": [
            .init(category: "Indeling & licht", items: [
                .init("Aantal slaapkamers klopt"),
                .init("Daglicht en raamoppervlak"),
                .init("Verduistering mogelijk"),
                .init("Kastruimte / inbouw"),
            ]),
            .init(category: "Afwerking", items: [
                .init("Vochtplekken op buitenmuur"),
                .init("Vloer en plinten"),
                .init("Geluidsisolatie"),
            ]),
            .init(category: "Aansluitingen", items: [
                .init("Stopcontacten en TV/data"),
                .init("Radiator of verwarming"),
            ]),
        ],
        "balkon": [
            .init(category: "Constructie", items: [
                .init("Balkonvloer en hekwerk vast"),
                .init("Geen scheuren in betonrand"),
                .init("Afvoer hemelwater werkt"),
            ]),
            .init(category: "Gebruik", items: [
                .init("Ligging en zon (ochtend / middag)"),
                .init("Privacy ten opzichte van buren"),
                .init("Buitenkraan of stopcontact"),
            ]),
        ],
        "berging": [
            .init(category: "Toegang & staat", items: [
                .init("Bereikbaarheid berging"),
                .init("Droog en geen schimmel"),
                .init("Slot en sleutel aanwezig"),
                .init("Verlichting en stopcontact"),
            ]),
        ],
        "zolder": [
            .init(category: "Toegang", items: [
                .init("Vaste trap of vlizotrap"),
                .init("Stahoogte voldoende"),
            ]),
            .init(category: "Dakconstructie", items: [
                .init("Dakbeschot droog en heel"),
                .init("Spanten zichtbaar en intact"),
                .init("Vochtplekken bij dakkapel"),
            ]),
            .init(category: "Klimaat", items: [
                .init("Isolatiepakket zichtbaar"),
                .init("Dakraam of ventilatie"),
                .init("Temperatuur in zomer"),
            ]),
        ],
        "kelder": [
            .init(category: "Vocht & geur", items: [
                .init("Vochtplekken op muren of vloer"),
                .init("Geur (muf / schimmel)"),
                .init("Zoutuitslag op muren"),
            ]),
            .init(category: "Toegang & gebruik", items: [
                .init("Ventilatie aanwezig"),
                .init("Stahoogte"),
                .init("Toegang en trap"),
                .init("Bruikbaar als wasruimte / opslag"),
            ]),
        ],
        "garage": [
            .init(category: "Constructie & deur", items: [
                .init("Garagedeur werkt elektrisch"),
                .init("Dichting onder deur"),
                .init("Vocht of lekkage plafond"),
                .init("Inpandig of vrijstaand"),
            ]),
            .init(category: "Aansluitingen", items: [
                .init("Aparte groep in meterkast"),
                .init("Aansluiting laadpaal mogelijk"),
                .init("Verlichting en stopcontacten"),
            ]),
        ],
        "tuin": [
            .init(category: "Erfgrens", items: [
                .init("Erfgrens en schutting"),
                .init("Bomen: eigendom en onderhoud"),
                .init("Erfdienstbaarheden voor / achter"),
            ]),
            .init(category: "Onderhoud & gebruik", items: [
                .init("Bestrating vlak"),
                .init("Schuur of berging"),
                .init("Buitenkraan"),
                .init("Ligging en zon (ochtend / middag)"),
                .init("Achterom of poort"),
            ]),
        ],
    ]

    // MARK: – English themes
    static let themesEN: [Theme] = [
        .init(id: "locatie",       label: "Location & Surroundings",       sub: "Neighbourhood, amenities, transport",    featured: true,  icon: "tree"),
        .init(id: "gevoel",        label: "Feel & Lifestyle Fit",          sub: "First impression, future suitability",   featured: false, icon: "face.smiling"),
        .init(id: "bouwkundig",    label: "Structural Condition",          sub: "Foundation, roof, cracks",               featured: false, icon: "hammer"),
        .init(id: "binnen",        label: "Interior & Finishes",           sub: "Floors, walls, kitchen, bathroom",       featured: false, icon: "paintbrush"),
        .init(id: "installaties",  label: "Utilities & Technical Systems", sub: "Heating, electrics, water, ventilation", featured: false, icon: "powerplug"),
        .init(id: "vocht-energie", label: "Moisture, Insulation & Energy", sub: "Damp, insulation, energy rating",        featured: false, icon: "snowflake"),
        .init(id: "kosten",        label: "Financial Obligations",         sub: "Price, taxes, charges, fees",            featured: false, icon: "eurosign.circle"),
        .init(id: "historie",      label: "Renovations & History",         sub: "Works done, permits, maintenance",       featured: false, icon: "wrench.and.screwdriver"),
        .init(id: "verkoper",      label: "Vendor & Sale Process",         sub: "Reason for sale, process, contracts",    featured: false, icon: "doc.text"),
    ]

    // MARK: – English rooms
    static let roomsEN: [Room] = [
        .init(id: "gemeenschappelijk", label: "Common Areas",         sub: "Stairwell, lift, entrance",   types: [.appartement]),
        .init(id: "gevel",             label: "Exterior & Facade",    sub: "Pointing, frames, roof",       types: [.woning]),
        .init(id: "hal",               label: "Hallway / Entry",      sub: "Front door, meter cupboard",   types: nil),
        .init(id: "woonkamer",         label: "Living Room",          sub: "Floor, walls, windows",        types: nil),
        .init(id: "keuken",            label: "Kitchen",              sub: "Appliances, plumbing",         types: nil),
        .init(id: "badkamer",          label: "Bathroom",             sub: "Tiling, ventilation",          types: nil),
        .init(id: "toilet",            label: "WC / Toilet",          sub: "Cistern, drainage",            types: nil),
        .init(id: "slaapkamer",        label: "Bedroom(s)",           sub: "Per bedroom",                  types: nil),
        .init(id: "balkon",            label: "Balcony",              sub: "Railings, drainage, aspect",   types: [.appartement]),
        .init(id: "berging",           label: "Storage / Utility",    sub: "Access, dry, secure",          types: [.appartement]),
        .init(id: "zolder",            label: "Loft / Attic",         sub: "Insulation, roof boarding",    types: [.woning]),
        .init(id: "kelder",            label: "Basement / Cellar",    sub: "Damp, ventilation",            types: [.woning]),
        .init(id: "garage",            label: "Garage",               sub: "Door, wiring",                 types: [.woning]),
        .init(id: "tuin",              label: "Garden / Yard",        sub: "Fencing, paving",              types: [.woning]),
    ]

    // MARK: – English checklist items
    static let itemsEN: [String: [ChecklistGroup]] = [
        "bouwkundig": [
            .init(category: "Structure", items: [
                .init("Visible cracks in foundation or walls?",        hint: "Diagonal or horizontal cracks are more serious than hairline settlement cracks."),
                .init("Signs of subsidence or structural movement?",   hint: "Sloping floors or sticking doors can indicate movement. Try the marble test.", market: .uk),
                .init("Signs of settling or structural movement?",     hint: "Sloping floors or sticking doors can indicate movement. Check door frames for racking.", market: .us),
                .init("Has the property been professionally surveyed?",   hint: "RICS Level 2 or Level 3 building survey. Essential for older properties.", market: .uk),
                .init("Has the property been professionally inspected?",  hint: "Licensed home inspector report. Check inspector is ASHI or InterNACHI certified.", market: .us),
            ]),
            .init(category: "Roof & Exterior", items: [
                .init("When was the roof last replaced or inspected?", hint: "Tiles or slates: 50+ years; flat roofs: 20–25 years. Ask for receipts.", market: .uk),
                .init("When was the roof last replaced or inspected?", hint: "Asphalt shingles: 20–30 years. Ask for receipts and any insurance claims history.", market: .us),
                .init("Condition of gutters and downpipes?",           hint: "Check for blockages, rust, or leaks — especially at joints."),
                .init("Any asbestos-containing materials?",            hint: "Common in pre-1980 properties. Roofing, floor tiles, insulation. Requires specialist removal."),
            ]),
            .init(category: "Risk Materials", items: [
                .init("Japanese knotweed or invasive plants on site?", hint: "Mortgage lenders may refuse to lend on affected properties. Check garden borders.", market: .uk),
                .init("Lead paint in pre-1978 property?",              hint: "Legally required disclosure in most US states. Test kits available at hardware stores.", market: .us),
                .init("Building survey or home inspection report available?", hint: "A recent professional report can highlight hidden defects and save on your own."),
            ]),
        ],
        "vocht-energie": [
            .init(category: "Damp & Mould", items: [
                .init("Evidence of dampness, mould, or water damage?", hint: "Check corners, behind furniture, under windowsills and inside cupboards."),
                .init("Rising damp at base of walls?",                 hint: "Look for salt deposits (efflorescence), peeling paint, or tide marks near floor level."),
                .init("Condensation issues on windows or walls?",      hint: "Can cause mould. Ask about ventilation and heating habits."),
            ]),
            .init(category: "Insulation", items: [
                .init("What insulation is in the loft or attic?",      hint: "≥270 mm mineral wool is the recommended standard. Ask for the installer certificate.", market: .uk),
                .init("What insulation is in the attic?",              hint: "R-30 to R-60 depending on climate zone. Ask for the installer documentation.", market: .us),
                .init("Is there cavity wall insulation?",              hint: "UK-relevant for pre-1990 properties. Ask for installation certificate.", market: .uk),
                .init("Are windows double or triple-glazed?",          hint: "Double-glazed as a minimum (FENSA certificate). Single glazing = poor energy performance.", market: .uk),
                .init("Are windows double or triple-pane?",            hint: "Double or triple-pane as a minimum. Single-pane windows indicate poor energy performance.", market: .us),
            ]),
            .init(category: "Energy Rating", items: [
                .init("EPC rating available and current?",             hint: "UK: legally required for sale/rental. A–G scale; aim for C or above.", market: .uk),
                .init("ENERGY STAR certification or home energy audit available?", hint: "US: optional but indicates efficient systems. Ask for 12 months of utility bills.", market: .us),
                .init("Annual energy bills available?",                hint: "Ask for 12 months of gas and electricity bills to understand running costs."),
                .init("Solar panels — owned or leased?",               hint: "Owned panels add value; leased panels transfer a financial obligation to the buyer."),
            ]),
        ],
        "installaties": [
            .init(category: "Heating", items: [
                .init("Central heating type?",                         hint: "Gas boiler, oil, heat pump, biomass, or district heating.", market: .uk),
                .init("When was the boiler last serviced?",            hint: "Should be annually. Ask to see the service record.", market: .uk),
                .init("Gas and electrical safety certificate?",        hint: "UK: Gas Safe certificate and EICR (electrical condition report) required for rentals.", market: .uk),
                .init("HVAC system age and condition?",                hint: "US: typical lifespan 15–20 years. Ask for service history. Replacement costs $5–15k.", market: .us),
                .init("When was the furnace or AC unit last serviced?", hint: "US: should be annually. Budget $3–12k for full replacement.", market: .us),
            ]),
            .init(category: "Plumbing & Water", items: [
                .init("Septic tank or mains drainage?",                hint: "Septic tanks need regular emptying (every 1–3 years) and are the buyer's responsibility.", market: .uk),
                .init("Well or municipal water supply?",               hint: "US: rural properties may have private wells. Ask for recent water quality test results.", market: .us),
                .init("Any lead or old galvanised pipes?",             hint: "Common in pre-1970 properties. Full replacement can run thousands of pounds.", market: .uk),
                .init("Any lead or old galvanised pipes?",             hint: "Common in pre-1970 properties. Full replacement can run thousands of dollars.", market: .us),
                .init("Water pressure good throughout the property?",  hint: "Run hot and cold taps simultaneously on different floors to test."),
            ]),
            .init(category: "Electrics", items: [
                .init("Consumer unit / fuse board age and condition?", hint: "UK: should have RCDs fitted. Old-style fuse wire boards need replacing.", market: .uk),
                .init("Electrical panel capacity and age?",            hint: "US: 200-amp panel is standard for modern homes. Knob-and-tube or aluminium wiring is a red flag.", market: .us),
                .init("Smart meter fitted?",                           hint: "Required for monitoring energy use and time-of-use tariffs."),
                .init("Broadband type available?",                     hint: "Full-fibre (FTTP), cable, or telephone line only? Check postcode/address on provider sites."),
            ]),
        ],
        "binnen": [
            .init(category: "Floors & Walls", items: [
                .init("Floors level and free from creaking?",          hint: "Walk the full surface. Creaking can indicate loose boards or structural movement."),
                .init("Carpeting or hard flooring — any water damage?", hint: "Stains, buckling, or soft spots can indicate previous leaks."),
                .init("Walls and ceilings free from cracks?",          hint: "Hairline cracks from settling are normal; diagonal or wide cracks need investigation."),
                .init("Paint condition — recently redecorated?",       hint: "Fresh paint over the whole house can sometimes be used to hide damp or defects."),
            ]),
            .init(category: "Kitchen & Bathroom", items: [
                .init("Kitchen appliances — included and working?",    hint: "Confirm what stays. Free-standing or integrated? Ask for manuals and warranties."),
                .init("Kitchen and bathroom age and condition?",       hint: "Full replacement: kitchen £10–30k; bathroom £5–15k.", market: .uk),
                .init("Kitchen and bathroom age and condition?",       hint: "Full replacement: kitchen $15–50k; bathroom $10–25k.", market: .us),
                .init("Tiling, grouting, and sealant intact?",         hint: "Cracked tiles or failing sealant around the bath/shower can hide damp behind the wall."),
                .init("No leaks under sinks or around plumbing?",      hint: "Open all cupboard doors under sinks; check for water staining or mould on base panel."),
                .init("Lead paint concerns in pre-1978 property?",     hint: "US: required disclosure. Disturbance during renovation creates health hazard.", market: .us),
            ]),
            .init(category: "Layout & Fittings", items: [
                .init("Enough power sockets in all rooms?",            hint: "In useful locations near furniture, worktops, and desk space."),
                .init("Storage and built-in wardrobes?",               hint: "Confirm what's included and what the seller plans to take."),
                .init("Fixtures and fittings list agreed?",            hint: "Fittings list should be attached to the sale contract.", tenure: .koop),
                .init("Any asbestos concerns in older property?",      hint: "Artex ceilings, vinyl floor tiles, lagging on pipes (pre-1980). Professional survey recommended."),
            ]),
        ],
        "locatie": [
            .init(category: "Neighbourhood", items: [
                .init("Character of the area — quiet or busy?",        hint: "Visit at different times of day and on a weekday to get an honest picture."),
                .init("Noise issues — traffic, neighbours, transport?", hint: "Open windows during the viewing. Note proximity to main roads or railway lines."),
                .init("Future development plans nearby?",              hint: "Check the council planning portal for nearby applications.", market: .uk),
                .init("Future development plans nearby?",              hint: "Check the city or county planning department for nearby applications.", market: .us),
            ]),
            .init(category: "Amenities", items: [
                .init("School district quality?",                      hint: "US: major factor in property values. Check state ratings.", market: .us),
                .init("Good local schools nearby?",                    hint: "UK: check Ofsted reports at ofsted.gov.uk.", market: .uk),
                .init("Proximity to shops, healthcare, and essentials?", hint: "Supermarket, GP/doctor, pharmacy within comfortable distance."),
                .init("Transport links — rail, bus, motorway?",        hint: "Walking distance to station? Realistic commute time to work?"),
                .init("Parking — permit, private, or on-street?",      hint: "Check permit zone costs and waiting lists at the council.", market: .uk),
                .init("Parking — garage, driveway, or street?",        hint: "HOA rules may restrict on-street parking. Check what's allocated to the property.", market: .us),
                .init("Proximity to hospitals, schools, and shopping?", hint: "Important for daily life and future resale value.", market: .us),
            ]),
            .init(category: "Risk Factors", items: [
                .init("Council tax band and annual cost?",             hint: "UK: check on GOV.UK. Higher bands = significantly higher annual charges.", market: .uk),
                .init("Annual property tax rate?",                     hint: "US: varies widely by state and county. Check county assessor records.", market: .us),
                .init("Flood zone designation?",                       hint: "Check the Environment Agency flood map. Flood risk can affect insurance and mortgage.", market: .uk),
                .init("Flood zone designation?",                       hint: "Check FEMA flood zone maps. Properties in Zone AE may require flood insurance.", market: .us),
                .init("Green belt or conservation area designation?",  hint: "UK: limits future extensions, outbuildings, or change of use. Check local authority.", market: .uk),
                .init("HOA fees, rules, and restrictions?",            hint: "US: understand what's covered, review CC&Rs, and check for pending special assessments.", market: .us),
            ]),
        ],
        "verkoper": [
            .init(category: "Vendor", items: [
                .init("Reason for selling?",                           hint: "Moving, downsizing, financial difficulty? Short ownership period warrants closer inspection."),
                .init("How long has the current owner lived here?",    hint: "Less than 2 years — ask why they're moving so soon."),
                .init("Open and honest about known defects?",          hint: "A seller who volunteers issues is a good sign. Concealing known defects can be a legal issue."),
                .init("Any disputes with neighbours?",                 hint: "Boundary disputes, noise complaints, rights of way. Ask directly."),
                .init("Any planning restrictions or covenants?",       hint: "UK: restrictive covenants limiting alterations. Ask your solicitor to check the title.", market: .uk),
            ]),
            .init(category: "Sale Process", items: [
                .init("Bidding process clear?",                        hint: "Sealed bids or best-and-final offers? Ask about gazumping risk.", tenure: .koop, market: .uk),
                .init("Bidding process clear?",                        hint: "Multiple offers process? Ask about escalation clauses and contingency waivers.", tenure: .koop, market: .us),
                .init("Finance or survey contingency available?",      hint: "Standard conditions: subject to survey and subject to mortgage.", tenure: .koop, market: .uk),
                .init("Finance or survey contingency available?",      hint: "Standard inspection and financing contingencies. Confirm timescales with your agent.", tenure: .koop, market: .us),
                .init("Seller's disclosure statement reviewed?",       hint: "TA6 Property Information Form — review all disclosures carefully with your solicitor.", tenure: .koop, market: .uk),
                .init("Seller's disclosure statement reviewed?",       hint: "Legally required in most states. Review carefully and follow up on any flagged issues.", tenure: .koop, market: .us),
                .init("Preferred completion or moving date?",          hint: "Does the timeline work with your own situation and any chain above?"),
                .init("Deposit and tenancy agreement explained?",      hint: "UK: deposit capped at 5 weeks' rent and must be in a government protection scheme.", tenure: .huur),
            ]),
            .init(category: "Disclosures", items: [
                .init("Previous insurance claims on the property?",    hint: "US: indicates past issues with flooding, fire, or other damage. Request claims history.", market: .us),
                .init("Natural disasters in the area?",                hint: "US: hurricanes, earthquakes, wildfires, tornadoes — check local hazard maps.", market: .us),
                .init("Sex offender registry check done?",             hint: "US: public registry. Check the National Sex Offender Public Website (NSOPW).", market: .us),
            ]),
        ],
        "historie": [
            .init(category: "Renovations", items: [
                .init("What major renovations have been completed?",   hint: "Ask for an overview with dates, invoices, and any guarantees or warranties."),
                .init("Planning permission obtained?",                  hint: "Check council planning portal. Confirm extensions or conversions had approval.", market: .uk),
                .init("Building permits obtained?",                    hint: "Check with local building department. Unpermitted work affects insurance and resale.", market: .us),
                .init("Electrical and plumbing work certified?",       hint: "Part P certificate for electrics; Gas Safe certificate for gas. Ask for originals.", market: .uk),
                .init("Electrical and plumbing work certified?",       hint: "Permitted work signed off by local building inspector. Ask for inspection records.", market: .us),
                .init("Any unpermitted work carried out?",             hint: "Can cause issues with insurance, mortgage, or resale. Buyer may inherit liability."),
                .init("Remaining warranties on recent work?",          hint: "Roof, boiler, HVAC, windows — ask for paperwork and check transferability."),
            ]),
            .init(category: "Maintenance", items: [
                .init("When was the exterior last painted or repointed?", hint: "Every 10–15 years is typical. Overdue maintenance can accelerate deterioration.", only: .woning),
                .init("Age of roof and last renewal?",                 hint: "Flat roofs: 20–25 years; pitched tiles/slates: 50+ years. Ask for receipts.", only: .woning),
                .init("Maintenance log or service history available?", hint: "A well-kept log suggests a well-maintained property. Ask for boiler/HVAC records."),
                .init("Service charge accounts and reserve fund?",     hint: "Leasehold flat: request last 3 years' accounts, budget, and meeting minutes.", only: .appartement, tenure: .koop, market: .uk),
                .init("HOA reserve fund and accounts?",               hint: "Request last 3 years' accounts, budget, and meeting minutes. Check for pending assessments.", only: .appartement, tenure: .koop, market: .us),
            ]),
            .init(category: "Legal & Tenure", items: [
                .init("Freehold or leasehold? Years remaining on lease?", hint: "UK: below 80 years is harder to mortgage and expensive to extend. Check now.", tenure: .koop, market: .uk),
                .init("Any restrictive covenants or easements on the title?", hint: "Can limit what you can do with the property. Ask your solicitor to check."),
                .init("HOA documents and meeting minutes reviewed?",   hint: "US: CC&Rs, bylaws, minutes. Look for pending assessments, litigation, or deferred maintenance.", only: .appartement, tenure: .koop, market: .us),
            ]),
        ],
        "kosten": [
            .init(category: "Purchase Costs", items: [
                .init("Is the asking price in line with the market?",  hint: "Check Rightmove or Zoopla sold prices for comparable properties nearby.", tenure: .koop, market: .uk),
                .init("Is the asking price in line with the market?",  hint: "Check Zillow or Redfin recent comparable sales (comps) within 0.5 miles.", tenure: .koop, market: .us),
                .init("Estimated buying costs?",                       hint: "Stamp duty, solicitor fees, survey. Budget 2–5% of the purchase price on top.", tenure: .koop, market: .uk),
                .init("Estimated buying costs?",                       hint: "Closing costs typically 2–5% of the purchase price: title insurance, escrow, lender fees.", tenure: .koop, market: .us),
                .init("Mortgage borrowing capacity confirmed?",        hint: "Agreement in principle obtained? Stress-tested at higher interest rates?", tenure: .koop),
                .init("Estimated renovation or repair budget?",        hint: "Add a 10–20% contingency buffer on top of any contractor quotes.", tenure: .koop),
            ]),
            .init(category: "Ongoing Costs", items: [
                .init("Annual council tax and typical utility costs?", hint: "UK: council tax band determines the annual charge. Ask for 12 months of utility bills.", market: .uk),
                .init("Annual property taxes and typical utility costs?", hint: "US: taxes vary widely by state. Ask seller for recent utility bills.", market: .us),
                .init("Service charge and ground rent (leasehold)?",   hint: "UK: review last 3 years' accounts. Watch for escalating ground rent clauses.", only: .appartement, market: .uk),
                .init("HOA fees — monthly and annual?",                hint: "US: understand what's covered (insurance, maintenance) and check reserve fund health.", only: .appartement, market: .us),
                .init("Any outstanding mortgages, liens, or charges?", hint: "Check Land Registry for charges and restrictions on the title.", market: .uk),
                .init("Any outstanding mortgages, liens, or charges?", hint: "A title search will reveal all encumbrances. Review with your attorney before closing.", market: .us),
            ]),
            .init(category: "Rental-Specific", items: [
                .init("Monthly rent — what's included?",               hint: "Get a clear breakdown of rent vs. separately billed items.", tenure: .huur),
                .init("Service charges itemised?",                     hint: "Confirm breakdown and whether there's an annual reconciliation.", tenure: .huur),
                .init("Energy and bills included or separate?",        hint: "Bills-included rents are convenient but check they fairly reflect actual usage.", tenure: .huur),
                .init("Rent charges — are they escalating?",           hint: "UK: watch for leasehold rent charges with doubling clauses.", tenure: .huur, market: .uk),
            ]),
        ],
        "gevoel": [
            .init(category: "First Impression", items: [
                .init("Does the first impression still hold up?",      hint: "Compare your gut feeling at the door with what you've found on closer inspection."),
                .init("Natural light levels throughout the day?",      hint: "Check multiple rooms, not just the living room. Which way do the main rooms face?"),
                .init("Does the layout work for your lifestyle?",      hint: "Think through daily routines: cooking, eating, working from home, storage."),
                .init("Atmosphere and feel of the property?",          hint: "Does it feel like home, or would you need major work before it does?"),
            ]),
            .init(category: "Future Suitability", items: [
                .init("Bedroom count suitable now and in 5 years?",    hint: "Consider family growth, home office, or guest room needs."),
                .init("Work-from-home space available?",               hint: "Dedicated room, quiet alcove, or would you need to convert a space?"),
                .init("Garden or outdoor space adequate?",             hint: "Size, aspect, privacy, and ongoing maintenance level."),
                .init("Parking situation adequate?",                   hint: "Driveway, garage, permit zone, or competitive street parking?"),
                .init("Future development plans in the area?",         hint: "Check planning applications locally — expansion or decline can affect value."),
                .init("Fits within budget without financial stress?",  hint: "Monthly costs comfortable at current rates? What if rates rise?"),
                .init("Neighbourhood suits your lifestyle?",           hint: "Quiet vs. lively, walkable, community feel, long-term fit."),
            ]),
        ],
        // MARK: Individual rooms (English)
        "gemeenschappelijk": [
            .init(category: "Entry & Access", items: [
                .init("Communal entrance clean and well-maintained?"),
                .init("Door entry system and intercom working?"),
                .init("Post boxes and letterboxes in order?"),
            ]),
            .init(category: "Stairwell & Lift", items: [
                .init("Stairwell décor and condition?"),
                .init("Lift present and certificate current?"),
                .init("Noise from landing or corridors?"),
            ]),
            .init(category: "Building Maintenance", items: [
                .init("Exterior last painted or treated?"),
                .init("Roof condition and last renewal?"),
                .init("Long-term maintenance plan in place?"),
            ]),
        ],
        "gevel": [
            .init(category: "Brickwork & Pointing", items: [
                .init("Cracks in brickwork or mortar?"),
                .init("Pointing in good condition?"),
                .init("Staining or damp penetration marks?"),
                .init("Cavity wall insulation present?"),
            ]),
            .init(category: "Roof & Chimney", items: [
                .init("Roof tiles or slates — visible condition?"),
                .init("Gutters and downpipes intact and clear?"),
                .init("Chimney stack upright, mortar sound?"),
                .init("Roof penetrations and fascia boards?"),
            ]),
            .init(category: "Windows & Frames", items: [
                .init("Window frames: rot, damage, or failing seals?"),
                .init("Double or triple-glazed throughout?"),
                .init("External paintwork or cladding condition?"),
                .init("Window locks and hardware working?"),
            ]),
        ],
        "hal": [
            .init(category: "Front Door & Security", items: [
                .init("Front door closes and seals properly?"),
                .init("Multi-point lock or security rating?"),
                .init("Draught-proofing strip fitted?"),
                .init("Letterbox and spy hole present?", only: .woning),
            ]),
            .init(category: "Meter & Services", items: [
                .init("Consumer unit / fuse board accessible and tidy?"),
                .init("Smart meter fitted?"),
                .init("Broadband connection — fibre or cable?"),
            ]),
            .init(category: "Stairs & Floor", items: [
                .init("Staircase solid, handrail secure?", only: .woning),
                .init("Staircase headroom adequate?",      only: .woning),
                .init("Floor level and undamaged?"),
            ]),
        ],
        "woonkamer": [
            .init(category: "Floor & Walls", items: [
                .init("Floors level and even?"),
                .init("Type of flooring — any damage or wear?"),
                .init("Cracks in ceiling or walls?"),
                .init("Any damp patches visible?"),
                .init("Sound insulation from neighbours?"),
            ]),
            .init(category: "Windows & Heating", items: [
                .init("Windows open, close, and lock properly?"),
                .init("Trickle vents or ventilation present?"),
                .init("Radiators working and balanced?"),
                .init("Underfloor heating fitted?"),
            ]),
            .init(category: "Electrics & Data", items: [
                .init("Enough power sockets?"),
                .init("TV aerial or cable point?"),
                .init("Light fittings in practical positions?"),
            ]),
        ],
        "keuken": [
            .init(category: "Appliances", items: [
                .init("Appliances staying with the property?"),
                .init("Age and condition of appliances?"),
                .init("Induction, gas, or electric hob?"),
            ]),
            .init(category: "Plumbing & Ventilation", items: [
                .init("Extractor ducted to outside?"),
                .init("Dishwasher connection available?"),
                .init("Washing machine connection in kitchen?"),
                .init("No leaks under the sink?"),
            ]),
            .init(category: "Finishes", items: [
                .init("Tiles and sealant in good condition?"),
                .init("Adequate worktop space?"),
                .init("Under-cabinet or task lighting?"),
            ]),
        ],
        "badkamer": [
            .init(category: "Tiling & Finishes", items: [
                .init("Tiles free from cracks or missing grout?"),
                .init("Sealant clean and watertight?"),
                .init("No signs of mould or damp?"),
                .init("Age and overall condition of bathroom?"),
            ]),
            .init(category: "Plumbing & Water", items: [
                .init("Shower or bath draining properly?"),
                .init("Good hot water pressure?"),
                .init("Basin taps and drain working?"),
            ]),
            .init(category: "Ventilation & Electrics", items: [
                .init("Mechanical extractor fan working?"),
                .init("Shaver socket safe for wet area?"),
                .init("Towel rail or radiator present?"),
            ]),
        ],
        "toilet": [
            .init(category: "Sanitary Ware", items: [
                .init("Cistern fills and shuts off properly?"),
                .init("No drain odour?"),
                .init("Basin and tap working?"),
            ]),
            .init(category: "Finishes & Ventilation", items: [
                .init("Tiling and sealant in good condition?"),
                .init("Ventilation — window or extractor?"),
                .init("Light working?"),
            ]),
        ],
        "slaapkamer": [
            .init(category: "Layout & Light", items: [
                .init("Number of bedrooms as described?"),
                .init("Good natural light and window size?"),
                .init("Blackout blinds or curtains possible?"),
                .init("Built-in wardrobes or storage?"),
            ]),
            .init(category: "Finishes", items: [
                .init("Any damp on external walls?"),
                .init("Floors and skirting boards in good order?"),
                .init("Sound insulation from neighbours or road?"),
            ]),
            .init(category: "Services", items: [
                .init("Power sockets and TV / data points?"),
                .init("Radiator or heating present?"),
            ]),
        ],
        "balkon": [
            .init(category: "Structure", items: [
                .init("Balcony floor and railings secure?"),
                .init("No cracks in concrete edge or walls?"),
                .init("Rainwater drainage working?"),
            ]),
            .init(category: "Use & Aspect", items: [
                .init("Sun aspect — morning or afternoon?"),
                .init("Privacy from neighbouring properties?"),
                .init("External tap or power socket?"),
            ]),
        ],
        "berging": [
            .init(category: "Access & Condition", items: [
                .init("Storage easily accessible?"),
                .init("Dry and free from mould?"),
                .init("Lock and key present?"),
                .init("Light and power socket?"),
            ]),
        ],
        "zolder": [
            .init(category: "Access", items: [
                .init("Fixed staircase or loft hatch?"),
                .init("Adequate headroom throughout?"),
            ]),
            .init(category: "Roof Structure", items: [
                .init("Roof boards dry and intact?"),
                .init("Rafters visible and sound?"),
                .init("Any damp at skylights or roof windows?"),
            ]),
            .init(category: "Insulation & Climate", items: [
                .init("Insulation layer visible and adequate?"),
                .init("Roof window or ventilation present?"),
                .init("Temperature acceptable in summer?"),
            ]),
        ],
        "kelder": [
            .init(category: "Damp & Smell", items: [
                .init("Damp patches on walls or floor?"),
                .init("Any musty or mouldy smell?"),
                .init("Salt deposits on walls?"),
            ]),
            .init(category: "Access & Use", items: [
                .init("Ventilation present?"),
                .init("Adequate headroom?"),
                .init("Safe staircase access?"),
                .init("Usable as utility room or storage?"),
            ]),
        ],
        "garage": [
            .init(category: "Structure & Door", items: [
                .init("Garage door operates correctly?"),
                .init("Draught seal at base of door?"),
                .init("No damp or roof leaks?"),
                .init("Integral or detached garage?"),
            ]),
            .init(category: "Services", items: [
                .init("Separate circuit from consumer unit?"),
                .init("EV charging point connection possible?"),
                .init("Lighting and power sockets?"),
            ]),
        ],
        "tuin": [
            .init(category: "Boundaries", items: [
                .init("Boundary fences or walls — ownership clear?"),
                .init("Trees: ownership and maintenance responsibility?"),
                .init("Any easements or rights of way?"),
            ]),
            .init(category: "Maintenance & Use", items: [
                .init("Paving or decking level and stable?"),
                .init("Garden shed or outbuilding?"),
                .init("Outside tap?"),
                .init("Sun aspect — morning or afternoon?"),
                .init("Side gate or rear access?"),
            ]),
        ],
    ]

    // MARK: – Helpers
    private static func useEnglish(market: Market) -> Bool {
        market.isEnglish || !Market.isDeviceLanguageDutch
    }

    static func themes(for type: ViewingType, market: Market = .nl) -> [Theme] {
        useEnglish(market: market) ? themesEN : themes
    }
    static func rooms(for type: ViewingType, market: Market = .nl) -> [Room] {
        let source = useEnglish(market: market) ? roomsEN : rooms
        return source.filter { $0.visible(for: type) }
    }

    static func groups(entryId: String, type: ViewingType, tenure: Tenure, market: Market = .nl) -> [ChecklistGroup] {
        let source = useEnglish(market: market) ? itemsEN : items
        return (source[entryId] ?? []).compactMap { g in
            let filtered = g.items.filter {
                ($0.onlyType   == nil || $0.onlyType   == type) &&
                ($0.onlyTenure == nil || $0.onlyTenure == tenure) &&
                ($0.onlyMarket == nil || $0.onlyMarket == market)
            }
            return filtered.isEmpty ? nil : ChecklistGroup(category: g.category, items: filtered)
        }
    }

    static func flatItems(entryId: String, type: ViewingType, tenure: Tenure, market: Market = .nl) -> [FlatItem] {
        var out: [FlatItem] = []; var idx = 0
        for g in groups(entryId: entryId, type: type, tenure: tenure, market: market) {
            for it in g.items {
                out.append(FlatItem(item: it, category: g.category, flatIndex: idx, key: "\(entryId)-\(idx)"))
                idx += 1
            }
        }
        return out
    }

    static func totalItems(entryId: String, type: ViewingType, tenure: Tenure, market: Market = .nl) -> Int {
        flatItems(entryId: entryId, type: type, tenure: tenure, market: market).count
    }

    static func answeredCount(entryId: String, answers: [String: Rating], type: ViewingType, tenure: Tenure, market: Market = .nl) -> Int {
        flatItems(entryId: entryId, type: type, tenure: tenure, market: market).filter { answers[$0.key] != nil }.count
    }
}
