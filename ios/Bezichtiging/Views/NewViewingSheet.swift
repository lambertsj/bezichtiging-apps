import SwiftUI

struct NewViewingSheet: View {
    @Binding var isPresented: Bool
    let onCreated: (UUID) -> Void
    @Environment(ViewingStore.self) var store
    @State private var name = ""
    @State private var type: ViewingType = .woning
    @State private var tenure: Tenure = .koop
    @FocusState private var nameFocused: Bool

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {

                    VStack(alignment: .leading, spacing: 6) {
                        Text(L.newViewingSheetTitle(store.market))
                            .font(.system(size: 26, weight: .bold))
                            .foregroundStyle(Color.bzFg)
                        Text(L.newViewingSheetDesc(store.market))
                            .font(.system(size: 15))
                            .foregroundStyle(Color.bzMuted)
                    }
                    .padding(.bottom, 24)

                    // Type
                    sectionLabel("Type")
                    HStack(spacing: 10) {
                        TypeCard(icon: "house",
                                 title: ViewingType.woning.label(for: store.market),
                                 sub: ViewingType.woning.sub(for: store.market),
                                 selected: type == .woning) { type = .woning }
                        TypeCard(icon: "building.2",
                                 title: ViewingType.appartement.label(for: store.market),
                                 sub: ViewingType.appartement.sub(for: store.market),
                                 selected: type == .appartement) { type = .appartement }
                    }
                    .padding(.bottom, 18)

                    // Tenure (Koop/Huur)
                    sectionLabel(L.sectionTenure(store.market))
                    Picker(L.sectionTenure(store.market), selection: $tenure) {
                        ForEach(Tenure.allCases, id: \.self) { t in
                            Label(t.label(for: store.market), systemImage: t.systemImage).tag(t)
                        }
                    }
                    .pickerStyle(.segmented)
                }
                .padding(24)
            }
            .background(Color.bzBg)
            .scrollDismissesKeyboard(.interactively)
            .navigationBarHidden(true)
            .safeAreaInset(edge: .bottom) {
                // Pinned input + actions — SwiftUI lifts this above the keyboard,
                // so the field stays visible on every screen size.
                VStack(alignment: .leading, spacing: 0) {
                    sectionLabel(L.sectionName(store.market))
                    TextField(L.namePlaceholder(type: type, market: store.market), text: $name)
                        .font(.system(size: 17))
                        .padding(16)
                        .background(Color.bzSurface)
                        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                        .focused($nameFocused)
                        .submitLabel(.done)
                        .onSubmit { startViewing() }
                        .padding(.bottom, 14)

                    HStack(spacing: 10) {
                        Button(L.cancel(store.market)) { isPresented = false }
                            .font(.system(size: 16, weight: .semibold))
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(Color.bzSurface)
                            .foregroundStyle(Color.bzFg)
                            .clipShape(Capsule())

                        Button(L.begin(store.market)) { startViewing() }
                            .font(.system(size: 16, weight: .semibold))
                            .frame(maxWidth: .infinity * 2)
                            .padding(.vertical, 16)
                            .background(name.trimmingCharacters(in: .whitespaces).isEmpty ? Color.bzFg.opacity(0.35) : Color.bzFg)
                            .foregroundStyle(.white)
                            .clipShape(Capsule())
                            .disabled(name.trimmingCharacters(in: .whitespaces).isEmpty)
                    }
                }
                .padding(.horizontal, 24)
                .padding(.top, 14)
                .padding(.bottom, 12)
                .background(Color.bzBg)
                .overlay(alignment: .top) {
                    Rectangle()
                        .fill(Color.bzLine)
                        .frame(height: 1)
                }
            }
        }
        .presentationDetents([.large])
        .presentationDragIndicator(.visible)
        .onAppear { nameFocused = true }
    }

    private func sectionLabel(_ text: String) -> some View {
        Text(text)
            .font(.system(size: 13, weight: .semibold))
            .foregroundStyle(Color.bzMuted)
            .kerning(0.3)
            .padding(.bottom, 8)
    }

    private func startViewing() {
        let trimmed = name.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else { return }
        let id = store.create(name: trimmed, type: type, tenure: tenure)
        onCreated(id)
        isPresented = false
    }
}

private struct TypeCard: View {
    let icon: String; let title: String; let sub: String
    let selected: Bool; let action: () -> Void
    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 6) {
                Image(systemName: icon)
                    .font(.system(size: 24, weight: .medium))
                    .foregroundStyle(selected ? Color.bzAccent : Color.bzFg)
                    .frame(width: 40, height: 40)
                    .background(selected ? Color.white : Color.bzBg)
                    .clipShape(RoundedRectangle(cornerRadius: 11, style: .continuous))
                    .padding(.bottom, 4)
                Text(title)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(Color.bzFg)
                Text(sub)
                    .font(.system(size: 12.5))
                    .foregroundStyle(selected ? Color.bzAccent.opacity(0.85) : Color.bzMuted)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(16)
            .background(selected ? Color.bzAccentSoft : Color.bzSurface)
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .strokeBorder(selected ? Color.bzAccent : Color.bzLine, lineWidth: 1.5)
            )
        }
        .buttonStyle(.plain)
    }
}
