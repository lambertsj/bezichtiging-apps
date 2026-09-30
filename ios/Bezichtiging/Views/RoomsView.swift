import SwiftUI

struct RoomsView: View {
    let viewingId: UUID
    @Environment(ViewingStore.self) var store
    @State private var showExport = false
    @State private var showInfo = false

    private var viewing: Viewing? { store.viewings.first { $0.id == viewingId } }

    var body: some View {
        Group {
            if let v = viewing {
                content(v)
            }
        }
        .background(Color.bzBg)
        .navigationBarTitleDisplayMode(.inline)
    }

    @ViewBuilder
    private func content(_ v: Viewing) -> some View {
        let vType = v.type; let vTenure = v.tenure
        let allThemes = ChecklistData.themes(for: vType, market: v.market)
        let featured = allThemes.first { $0.featured }
        let rest = allThemes.filter { !$0.featured }
        let rooms = ChecklistData.rooms(for: vType, market: v.market)
        let roomsAnswered = rooms.filter {
            ChecklistData.answeredCount(entryId: $0.id, answers: v.answers, type: vType, tenure: vTenure, market: v.market) > 0
        }.count

        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                // Header
                VStack(alignment: .leading, spacing: 8) {
                    Text(v.name)
                        .font(.system(size: 32, weight: .bold))
                        .foregroundStyle(Color.bzFg)
                    Text(L.roomsSubtitle(v.market))
                        .font(.system(size: 15))
                        .foregroundStyle(Color.bzMuted)
                }
                .padding(.horizontal, 20)
                .padding(.top, 8)
                .padding(.bottom, 4)

                // Featured theme
                if let f = featured {
                    NavigationLink(destination: ChecklistView(viewingId: viewingId, entryId: f.id)) {
                        FeaturedCard(theme: f, viewing: v)
                    }
                    .buttonStyle(.plain)
                    .padding(.horizontal, 20)
                    .padding(.top, 20)
                }

                // Category list
                VStack(alignment: .leading, spacing: 12) {
                    HStack(alignment: .firstTextBaseline) {
                        Text(L.categories(v.market))
                            .font(.system(size: 14, weight: .semibold)).kerning(0.5).textCase(.uppercase)
                            .foregroundStyle(Color.bzMuted)
                        Spacer()
                        Text("\(rest.count)").font(.subheadline.monospacedDigit()).foregroundStyle(Color.bzMuted)
                    }
                    .padding(.horizontal, 20)

                    BZCard {
                        VStack(spacing: 0) {
                            ForEach(Array(rest.enumerated()), id: \.element.id) { idx, theme in
                                NavigationLink(destination: ChecklistView(viewingId: viewingId, entryId: theme.id)) {
                                    EntryRow(entryId: theme.id, label: theme.label, sub: theme.sub,
                                             viewing: v, vType: vType, vTenure: vTenure, icon: theme.icon)
                                }
                                .buttonStyle(.plain)
                                if idx < rest.count - 1 { BZDivider().padding(.leading, 56) }
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                }
                .padding(.top, 24)

                // Individual rooms button
                VStack(spacing: 0) {
                    NavigationLink(destination: IndividualRoomsView(viewingId: viewingId)) {
                        HStack(spacing: 12) {
                            Image(systemName: "list.bullet")
                                .font(.system(size: 17, weight: .medium))
                                .foregroundStyle(Color.bzFg)
                                .frame(width: 36, height: 36)
                                .background(Color.bzBg)
                                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                            VStack(alignment: .leading, spacing: 2) {
                                Text(L.individualRooms(v.market))
                                    .font(.system(size: 16, weight: .semibold)).foregroundStyle(Color.bzFg)
                                Text(L.individualRoomsSub(v.market))
                                    .font(.system(size: 13)).foregroundStyle(Color.bzMuted)
                            }
                            Spacer()
                            Text("\(roomsAnswered)/\(rooms.count)")
                                .font(.subheadline.monospacedDigit()).foregroundStyle(Color.bzMuted)
                            BZChevron()
                        }
                        .padding(16)
                    }
                    .buttonStyle(.plain)
                }
                .background(Color.bzSurface)
                .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                .overlay(RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .strokeBorder(Color.bzLine, lineWidth: 1))
                .padding(.horizontal, 20)
                .padding(.top, 16)

                // Risk scan (Dutch public data, so NL market only)
                if v.market == .nl {
                    NavigationLink(destination: RiskScanView(market: v.market)) {
                        HStack(spacing: 12) {
                            Image(systemName: "exclamationmark.shield")
                                .font(.system(size: 17, weight: .medium))
                                .foregroundStyle(Color.bzFg)
                                .frame(width: 36, height: 36)
                                .background(Color.bzBg)
                                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                            VStack(alignment: .leading, spacing: 2) {
                                Text(L.riskScan(v.market))
                                    .font(.system(size: 16, weight: .semibold)).foregroundStyle(Color.bzFg)
                                Text(L.riskScanSub(v.market))
                                    .font(.system(size: 13)).foregroundStyle(Color.bzMuted)
                                    .lineLimit(2)
                            }
                            Spacer()
                            BZChevron()
                        }
                        .padding(16)
                    }
                    .buttonStyle(.plain)
                    .background(Color.bzSurface)
                    .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                    .overlay(RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .strokeBorder(Color.bzLine, lineWidth: 1))
                    .padding(.horizontal, 20)
                    .padding(.top, 10)
                }

                // Export button
                Button { showExport = true } label: {
                    HStack(spacing: 12) {
                        Image(systemName: "square.and.arrow.up")
                            .font(.system(size: 17, weight: .medium))
                            .foregroundStyle(Color.bzFg)
                            .frame(width: 36, height: 36)
                            .background(Color.bzBg)
                            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                        VStack(alignment: .leading, spacing: 2) {
                            Text(L.exportPDF(v.market))
                                .font(.system(size: 16, weight: .semibold)).foregroundStyle(Color.bzFg)
                            Text(L.exportPDFSub(v.market))
                                .font(.system(size: 13)).foregroundStyle(Color.bzMuted)
                        }
                        Spacer()
                        BZChevron()
                    }
                    .padding(16)
                }
                .buttonStyle(.plain)
                .background(Color.bzSurface)
                .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                .overlay(RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .strokeBorder(Color.bzLine, lineWidth: 1))
                .padding(.horizontal, 20)
                .padding(.top, 10)
                .padding(.bottom, 32)
            }
        }
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button { showInfo = true } label: {
                    Image(systemName: "info.circle")
                }
            }
            ToolbarItem(placement: .topBarTrailing) {
                Button { showExport = true } label: {
                    Image(systemName: "square.and.arrow.up")
                }
            }
        }
        .sheet(isPresented: $showExport) {
            if let v = viewing { ExportView(viewing: v) }
        }
        .sheet(isPresented: $showInfo) {
            if let v = viewing { ViewingInfoSheet(viewing: v) }
        }
    }
}

private struct FeaturedCard: View {
    let theme: Theme; let viewing: Viewing
    var body: some View {
        let vType = viewing.type; let vTenure = viewing.tenure
        let ans = ChecklistData.answeredCount(entryId: theme.id, answers: viewing.answers, type: vType, tenure: vTenure, market: viewing.market)
        let tot = ChecklistData.totalItems(entryId: theme.id, type: vType, tenure: vTenure, market: viewing.market)
        let hasNote = !(viewing.notes[theme.id] ?? "").isEmpty
        HStack(spacing: 0) {
            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 6) {
                    Image(systemName: theme.icon)
                        .font(.system(size: 13, weight: .medium))
                        .foregroundStyle(Color.bzMuted)
                    Text(L.beginHere(viewing.market).uppercased())
                        .font(.system(size: 12, weight: .semibold)).kerning(0.8)
                        .foregroundStyle(Color.bzAccent)
                }
                Text(theme.label)
                    .font(.system(size: 22, weight: .semibold))
                    .foregroundStyle(Color.bzFg)
                Text(theme.sub)
                    .font(.system(size: 14))
                    .foregroundStyle(Color.bzMuted)
            }
            Spacer()
            VStack(alignment: .trailing, spacing: 6) {
                if hasNote { NoteBadge() }
                Text("\(ans)/\(tot)")
                    .font(.subheadline.monospacedDigit())
                    .foregroundStyle(Color.bzAccent)
                Image(systemName: "chevron.right")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(Color.bzAccent)
            }
        }
        .padding(22)
        .background(Color.bzSurface)
        .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .strokeBorder(Color.bzAccent.opacity(0.35), lineWidth: 1.5)
        )
        .shadow(color: .black.opacity(0.05), radius: 12, x: 0, y: 4)
    }
}

struct EntryRow: View {
    let entryId: String; let label: String; let sub: String
    let viewing: Viewing; let vType: ViewingType; let vTenure: Tenure
    var icon: String? = nil

    var body: some View {
        let ans = ChecklistData.answeredCount(entryId: entryId, answers: viewing.answers, type: vType, tenure: vTenure, market: viewing.market)
        let tot = ChecklistData.totalItems(entryId: entryId, type: vType, tenure: vTenure, market: viewing.market)
        let hasNote = !(viewing.notes[entryId] ?? "").isEmpty
        HStack(spacing: 12) {
            if let icon {
                Image(systemName: icon)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundStyle(Color.bzMuted)
                    .frame(width: 36, height: 36)
                    .background(Color.bzBg)
                    .clipShape(RoundedRectangle(cornerRadius: 11, style: .continuous))
            } else {
                RoomMarker(answered: ans, total: tot, firstLetter: String(label.prefix(1)))
            }
            VStack(alignment: .leading, spacing: 2) {
                Text(label).font(.system(size: 16, weight: .semibold)).foregroundStyle(Color.bzFg)
                Text(sub).font(.system(size: 13)).foregroundStyle(Color.bzMuted)
            }
            Spacer()
            if hasNote { NoteBadge() }
            Text("\(ans)/\(tot)").font(.subheadline.monospacedDigit()).foregroundStyle(Color.bzMuted)
            BZChevron()
        }
        .padding(.horizontal, 16).padding(.vertical, 14)
    }
}

private struct ViewingInfoSheet: View {
    let viewing: Viewing
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 0) {
                BZCard {
                    VStack(spacing: 0) {
                        infoRow(label: L.labelType(viewing.market), value: viewing.type.label(for: viewing.market),
                                icon: viewing.type.systemImage)
                        BZDivider().padding(.leading, 56)
                        infoRow(label: L.labelTenure(viewing.market), value: viewing.tenure.longLabel(for: viewing.market),
                                icon: viewing.tenure.systemImage)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 24)
                Spacer()
            }
            .background(Color.bzBg)
            .navigationTitle(viewing.name)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button(L.close(viewing.market)) { dismiss() }
                }
            }
        }
        .presentationDetents([.height(220)])
        .presentationDragIndicator(.visible)
    }

    private func infoRow(label: String, value: String, icon: String) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 17, weight: .medium))
                .foregroundStyle(Color.bzFg)
                .frame(width: 36, height: 36)
                .background(Color.bzBg)
                .clipShape(RoundedRectangle(cornerRadius: 11, style: .continuous))
            Text(label)
                .font(.system(size: 16))
                .foregroundStyle(Color.bzMuted)
            Spacer()
            Text(value)
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(Color.bzFg)
        }
        .padding(.horizontal, 16).padding(.vertical, 14)
    }
}
