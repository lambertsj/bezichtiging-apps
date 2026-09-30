import SwiftUI

@MainActor @Observable
final class RiskScanModel {
    enum Phase {
        case idle
        case scanning(ScanAddress)
        case done(RiskScanResult)
        case failed(String)
    }

    var query = ""
    var suggestions: [ScanAddress] = []
    var phase: Phase = .idle
    private(set) var lastAddress: ScanAddress?

    private let client: RiskScanClient
    private var suggestTask: Task<Void, Never>?

    init(client: RiskScanClient = RiskScanClient()) { self.client = client }

    func queryChanged() {
        suggestTask?.cancel()
        let q = query.trimmingCharacters(in: .whitespaces)
        // Picking a suggestion writes its label into the field; don't search for it again.
        guard q.count >= 3, q != lastAddress?.label else { suggestions = []; return }
        suggestTask = Task {
            try? await Task.sleep(for: .milliseconds(150))
            guard !Task.isCancelled else { return }
            let found = (try? await client.suggestions(for: q)) ?? []
            guard !Task.isCancelled else { return }
            suggestions = found
        }
    }

    func scan(_ address: ScanAddress) async {
        suggestTask?.cancel()
        suggestions = []
        query = address.label
        lastAddress = address
        phase = .scanning(address)
        do {
            phase = .done(try await client.scan(address))
        } catch {
            phase = .failed(error.localizedDescription)
        }
    }
}

struct RiskScanView: View {
    let market: Market
    @State private var model = RiskScanModel()
    @FocusState private var searchFocused: Bool

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                VStack(alignment: .leading, spacing: 6) {
                    Text(L.riskScan(market))
                        .font(.system(size: 32, weight: .bold))
                        .foregroundStyle(Color.bzFg)
                    Text(L.riskScanSub(market))
                        .font(.system(size: 15))
                        .foregroundStyle(Color.bzMuted)
                }
                .padding(.horizontal, 20)
                .padding(.top, 8)
                .padding(.bottom, 20)

                searchField
                    .padding(.horizontal, 20)

                if !model.suggestions.isEmpty {
                    suggestionList
                        .padding(.horizontal, 20)
                        .padding(.top, 8)
                }

                content
                    .padding(.top, 24)

                Spacer(minLength: 40)
            }
        }
        .background(Color.bzBg)
        .scrollDismissesKeyboard(.interactively)
        .navigationTitle(L.riskScan(market))
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            if case .done(let result) = model.phase, !result.questions.isEmpty {
                ToolbarItem(placement: .topBarTrailing) {
                    ShareLink(item: shareText(result)) {
                        Image(systemName: "square.and.arrow.up")
                    }
                }
            }
        }
    }

    private var searchField: some View {
        HStack(spacing: 10) {
            Image(systemName: "magnifyingglass")
                .foregroundStyle(Color.bzMuted)
            TextField(L.riskScanPlaceholder(market), text: $model.query)
                .font(.system(size: 16))
                .textInputAutocapitalization(.characters)
                .autocorrectionDisabled()
                .focused($searchFocused)
                .onChange(of: model.query) { model.queryChanged() }
            if !model.query.isEmpty {
                Button { model.query = ""; model.suggestions = [] } label: {
                    Image(systemName: "xmark.circle.fill").foregroundStyle(Color.bzMuted)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, 16)
        .frame(height: 52)
        .background(Color.bzSurface)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: 16, style: .continuous).strokeBorder(Color.bzLine, lineWidth: 1))
    }

    private var suggestionList: some View {
        BZCard {
            VStack(spacing: 0) {
                ForEach(Array(model.suggestions.enumerated()), id: \.element) { idx, address in
                    Button {
                        searchFocused = false
                        Task { await model.scan(address) }
                    } label: {
                        HStack {
                            Image(systemName: "mappin.and.ellipse")
                                .foregroundStyle(Color.bzMuted)
                            Text(address.label)
                                .font(.system(size: 15))
                                .foregroundStyle(Color.bzFg)
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                        .padding(.horizontal, 16).padding(.vertical, 13)
                        .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)
                    if idx < model.suggestions.count - 1 { BZDivider().padding(.leading, 44) }
                }
            }
        }
    }

    @ViewBuilder
    private var content: some View {
        switch model.phase {
        case .idle:
            EmptyView()
        case .scanning:
            HStack(spacing: 10) {
                ProgressView()
                Text(L.riskScanLoading(market))
                    .font(.system(size: 15))
                    .foregroundStyle(Color.bzMuted)
            }
            .frame(maxWidth: .infinity)
            .padding(.top, 16)
        case .failed(let message):
            BZCard {
                VStack(alignment: .leading, spacing: 12) {
                    Text(message)
                        .font(.system(size: 15))
                        .foregroundStyle(Color.bzFg)
                    if let address = model.lastAddress {
                        Button(L.riskScanRetry(market)) { Task { await model.scan(address) } }
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundStyle(Color.bzAccent)
                    }
                }
                .padding(16)
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding(.horizontal, 20)
        case .done(let result):
            results(result)
        }
    }

    private func results(_ result: RiskScanResult) -> some View {
        VStack(alignment: .leading, spacing: 24) {
            VStack(alignment: .leading, spacing: 4) {
                Text(result.adres.regel)
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundStyle(Color.bzFg)
                Text([result.adres.postcode, result.adres.woonplaats].filter { !$0.isEmpty }.joined(separator: " "))
                    .font(.system(size: 14))
                    .foregroundStyle(Color.bzMuted)
                if !result.adres.woonfunctie {
                    Text(L.riskScanNoResidence(market))
                        .font(.system(size: 13))
                        .foregroundStyle(Color.bzBadInk)
                        .padding(.top, 4)
                }
            }
            .padding(.horizontal, 24)

            ForEach(RiskCard.Section.allCases, id: \.self) { section in
                let cards = result.cards(in: section)
                if !cards.isEmpty {
                    VStack(alignment: .leading, spacing: 8) {
                        CatHeader(label: section.title).padding(.horizontal, 20)
                        VStack(spacing: 10) {
                            ForEach(cards) { RiskCardView(card: $0, market: market) }
                        }
                        .padding(.horizontal, 20)
                    }
                }
            }

            Text(L.riskScanSources(market))
                .font(.system(size: 12))
                .foregroundStyle(Color.bzMuted)
                .padding(.horizontal, 24)
        }
    }

    private func shareText(_ result: RiskScanResult) -> String {
        let lines = result.questions.map { "• \($0)" }.joined(separator: "\n")
        return "\(L.riskScanShareTitle(market)) \(result.adres.regel)\n\n\(lines)"
    }
}

// MARK: – Card

private struct RiskCardView: View {
    let card: RiskCard
    let market: Market
    @State private var copied = false

    var body: some View {
        BZCard {
            VStack(alignment: .leading, spacing: 10) {
                HStack(alignment: .firstTextBaseline) {
                    Text(card.titel)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(Color.bzFg)
                    Spacer()
                    RiskBadge(card: card, market: market)
                }

                if !card.feiten.isEmpty {
                    Text(card.feiten.joined(separator: " · "))
                        .font(.system(size: 13))
                        .foregroundStyle(Color.bzMuted)
                        .fixedSize(horizontal: false, vertical: true)
                }

                if let vraag = card.vraag {
                    Button {
                        UIPasteboard.general.string = vraag
                        copied = true
                        Task { try? await Task.sleep(for: .seconds(1.5)); copied = false }
                    } label: {
                        HStack(alignment: .top, spacing: 10) {
                            Image(systemName: "quote.bubble")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundStyle(Color.bzAccent)
                                .padding(.top, 2)
                            Text(vraag)
                                .font(.system(size: 15, weight: .medium))
                                .foregroundStyle(Color.bzFg)
                                .multilineTextAlignment(.leading)
                                .fixedSize(horizontal: false, vertical: true)
                                .frame(maxWidth: .infinity, alignment: .leading)
                            Image(systemName: copied ? "checkmark" : "doc.on.doc")
                                .font(.system(size: 13, weight: .medium))
                                .foregroundStyle(copied ? Color.bzGoodInk : Color.bzMuted)
                                .padding(.top, 2)
                        }
                        .padding(12)
                        .background(Color.bzAccentSoft.opacity(0.35))
                        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                    }
                    .buttonStyle(.plain)
                    .contextMenu {
                        Button { UIPasteboard.general.string = vraag } label: {
                            Label(L.riskScanCopy(market), systemImage: "doc.on.doc")
                        }
                        ShareLink(item: vraag)
                    }
                    .accessibilityHint(L.riskScanCopy(market))
                }
            }
            .padding(16)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}

private struct RiskBadge: View {
    let card: RiskCard
    let market: Market

    var body: some View {
        Text(label)
            .font(.system(size: 12, weight: .semibold))
            .foregroundStyle(ink)
            .padding(.horizontal, 10).padding(.vertical, 4)
            .background(fill)
            .clipShape(Capsule())
    }

    private var label: String {
        switch card.status {
        case .ok:
            switch card.risico {
            case .laag: return L.riskLow(market)
            case .gemiddeld: return L.riskMedium(market)
            case .hoog: return L.riskHigh(market)
            case nil: return "—"
            }
        case .geenData: return L.riskNoData(market)
        case .onbekend, .mislukt: return L.riskUnknown(market)
        }
    }

    private var ink: Color {
        guard card.status == .ok else { return Color.bzMuted }
        switch card.risico {
        case .laag: return Color.bzGoodInk
        case .gemiddeld: return Color.bzAccent
        case .hoog: return Color.bzBadInk
        case nil: return Color.bzMuted
        }
    }

    private var fill: Color {
        guard card.status == .ok else { return Color.bzBg }
        switch card.risico {
        case .laag: return Color.bzGoodSoft
        case .gemiddeld: return Color.bzAccentSoft
        case .hoog: return Color.bzBadSoft
        case nil: return Color.bzBg
        }
    }
}
