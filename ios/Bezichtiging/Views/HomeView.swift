import SwiftUI

struct HomeView: View {
    @Environment(ViewingStore.self) var store
    @State private var path = NavigationPath()
    @State private var showNew = false
    @State private var showSettings = false
    @State private var pendingDelete: Viewing?
    @State private var pendingViewingId: UUID?
    @State private var contextViewing: Viewing?
    @State private var exportViewing: Viewing?
    @State private var longPressConsumed = false

    var body: some View {
        NavigationStack(path: $path) {
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    heroSection
                    ctaButton
                    pastViewings
                }
                .padding(.bottom, 40)
            }
            .background(Color.bzBg)
            .navigationBarHidden(true)
            .navigationDestination(for: UUID.self) { id in
                RoomsView(viewingId: id)
            }
        }
        .sheet(isPresented: $showNew, onDismiss: {
            if let id = pendingViewingId {
                path.append(id)
                pendingViewingId = nil
            }
        }) {
            NewViewingSheet(isPresented: $showNew) { id in
                pendingViewingId = id
            }
        }
        .sheet(isPresented: $showSettings) { SettingsView() }
        .sheet(item: $exportViewing) { v in ExportView(viewing: v) }
        .confirmationDialog(
            contextViewing?.name ?? "",
            isPresented: Binding(get: { contextViewing != nil }, set: { if !$0 { contextViewing = nil } }),
            titleVisibility: .visible
        ) {
            if let v = contextViewing {
                Button {
                    exportViewing = v
                    contextViewing = nil
                } label: {
                    Label(L.exportAction(store.market), systemImage: "square.and.arrow.up")
                }
                Button(L.deleteAction(v.name, market: store.market), role: .destructive) {
                    store.delete(viewingId: v.id)
                    contextViewing = nil
                }
            }
            Button(L.cancel(store.market), role: .cancel) { contextViewing = nil }
        }
        .confirmationDialog(
            L.deleteConfirmTitle(store.market),
            isPresented: Binding(get: { pendingDelete != nil }, set: { if !$0 { pendingDelete = nil } }),
            titleVisibility: .visible
        ) {
            if let v = pendingDelete {
                Button(L.deleteAction(v.name, market: store.market), role: .destructive) {
                    store.delete(viewingId: v.id)
                    pendingDelete = nil
                }
            }
            Button(L.cancel(store.market), role: .cancel) { pendingDelete = nil }
        } message: {
            Text(L.deleteConfirmMsg(store.market))
        }
    }

    // MARK: – Hero
    private var heroSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(alignment: .top, spacing: 12) {
                (Text(L.homeTagline(store.market) + " ")
                    .font(.system(size: 32, weight: .bold))
                 + Text(Image(systemName: "house.fill"))
                    .font(.system(size: 26, weight: .bold)))
                    .foregroundStyle(Color.bzFg)
                    .fixedSize(horizontal: false, vertical: true)
                    .frame(maxWidth: .infinity, alignment: .leading)

                Button { showSettings = true } label: {
                    Image(systemName: "gearshape")
                        .font(.system(size: 19, weight: .medium))
                        .foregroundStyle(Color.bzFg)
                        .frame(width: 40, height: 40)
                        .background(Color.bzSurface)
                        .clipShape(Circle())
                        .shadow(color: .black.opacity(0.06), radius: 8, x: 0, y: 2)
                }
            }

            Text(L.homeDescription(store.market))
                .font(.system(size: 15))
                .foregroundStyle(Color.bzMuted)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(.horizontal, 20)
        .padding(.top, 12)
    }

    // MARK: – CTA
    private var ctaButton: some View {
        Button { showNew = true } label: {
            HStack(spacing: 14) {
                Image(systemName: "plus")
                    .font(.system(size: 22, weight: .semibold))
                    .foregroundStyle(.white)
                    .frame(width: 44, height: 44)
                    .background(Color.bzAccent)
                    .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))

                VStack(alignment: .leading, spacing: 2) {
                    Text(L.newViewingCTA(store.market))
                        .font(.system(size: 17, weight: .semibold))
                    Text(L.newViewingCTASub(store.market))
                        .font(.system(size: 13))
                        .opacity(0.72)
                }
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .semibold))
                    .opacity(0.6)
            }
            .foregroundStyle(.white)
            .padding(20)
            .background(Color.bzFg)
            .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
            .shadow(color: Color.bzFg.opacity(0.25), radius: 20, x: 0, y: 8)
        }
        .buttonStyle(.plain)
        .padding(.horizontal, 20)
        .padding(.top, 20)
    }

    // MARK: – Past viewings
    private var pastViewings: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .firstTextBaseline) {
                Text(L.pastViewings(store.market))
                    .font(.system(size: 14, weight: .semibold))
                    .kerning(0.5)
                    .textCase(.uppercase)
                    .foregroundStyle(Color.bzMuted)
                Spacer()
                Text("\(store.viewings.count)")
                    .font(.subheadline.monospacedDigit())
                    .foregroundStyle(Color.bzMuted)
            }
            .padding(.horizontal, 20)
            .padding(.top, 28)

            if store.viewings.isEmpty {
                Text(L.noPastViewings(store.market))
                    .multilineTextAlignment(.center)
                    .foregroundStyle(Color.bzMuted)
                    .frame(maxWidth: .infinity)
                    .padding(28)
            } else {
                BZCard {
                    VStack(spacing: 0) {
                        ForEach(Array(store.viewings.enumerated()), id: \.element.id) { idx, v in
                            Button {
                                guard !longPressConsumed else { longPressConsumed = false; return }
                                path.append(v.id)
                            } label: {
                                ViewingRow(viewing: v)
                            }
                            .buttonStyle(.plain)
                            .simultaneousGesture(
                                LongPressGesture(minimumDuration: 0.4).onEnded { _ in
                                    longPressConsumed = true
                                    contextViewing = v
                                }
                            )
                            .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                                Button(role: .destructive) {
                                    pendingDelete = v
                                } label: {
                                    Label("Verwijder", systemImage: "trash")
                                }
                            }
                            if idx < store.viewings.count - 1 { BZDivider().padding(.leading, 68) }
                        }
                    }
                }
                .padding(.horizontal, 20)
            }
        }
    }
}

struct ViewingRow: View {
    let viewing: Viewing
    var body: some View {
        HStack(spacing: 12) {
            TypeBadge(type: viewing.type)
            VStack(alignment: .leading, spacing: 3) {
                Text(viewing.name)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(Color.bzFg)
                Text(viewing.type.label(for: viewing.market))
                    .font(.system(size: 13))
                    .foregroundStyle(Color.bzMuted)
            }
            Spacer()
            ScorePill(viewing: viewing)
            BZChevron()
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .contentShape(Rectangle())
    }
}
