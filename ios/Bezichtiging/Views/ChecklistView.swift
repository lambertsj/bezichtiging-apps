import SwiftUI

struct ChecklistView: View {
    let viewingId: UUID
    let entryId: String
    var isRoom: Bool = false
    @Environment(ViewingStore.self) var store
    @Environment(\.dismiss) var dismiss

    private var viewing: Viewing? { store.viewings.first { $0.id == viewingId } }
    private var entryLabel: String {
        guard let v = viewing else { return entryId }
        return ChecklistData.themes(for: v.type, market: v.market).first { $0.id == entryId }?.label
            ?? ChecklistData.rooms(for: v.type, market: v.market).first { $0.id == entryId }?.label
            ?? entryId
    }

    var body: some View {
        Group {
            if let v = viewing {
                content(v)
            }
        }
        .background(Color.bzBg)
        .navigationTitle(entryLabel)
        .navigationBarTitleDisplayMode(.inline)
    }

    @ViewBuilder
    private func content(_ v: Viewing) -> some View {
        let vType = v.type; let vTenure = v.tenure
        let groups = ChecklistData.groups(entryId: entryId, type: vType, tenure: vTenure, market: v.market)
        let flat = ChecklistData.flatItems(entryId: entryId, type: vType, tenure: vTenure, market: v.market)
        let answered = flat.filter { v.answers[$0.key] != nil }.count
        let note = v.notes[entryId] ?? ""

        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                // Header
                VStack(alignment: .leading, spacing: 6) {
                    Text(entryLabel)
                        .font(.system(size: 32, weight: .bold))
                        .foregroundStyle(Color.bzFg)
                    Text(L.answeredOf(answered, flat.count, market: v.market))
                        .font(.system(size: 15))
                        .foregroundStyle(Color.bzMuted)
                }
                .padding(.horizontal, 20)
                .padding(.top, 8)
                .padding(.bottom, 20)

                // Photo strip
                PhotoStrip(viewingId: viewingId, entryId: entryId,
                           photoIds: v.photoIds[entryId] ?? [], market: v.market)

                // Checklist grouped by category
                VStack(alignment: .leading, spacing: 18) {
                    ForEach(groups, id: \.category) { group in
                        VStack(alignment: .leading, spacing: 8) {
                            CatHeader(label: group.category).padding(.horizontal, 20)
                            BZCard {
                                VStack(spacing: 0) {
                                    ForEach(Array(group.items.enumerated()), id: \.element.id) { idx, item in
                                        // Find the flat index for this item
                                        let flatItem = flat.first { $0.item.id == item.id }
                                        if let fi = flatItem {
                                            ItemRow(viewingId: viewingId,
                                                    item: item, key: fi.key,
                                                    value: v.answers[fi.key],
                                                    market: v.market,
                                                    itemNote: v.itemNotes[fi.key],
                                                    itemPhotoIds: v.itemPhotoIds[fi.key] ?? []) { rating in
                                                store.setAnswer(viewingId: viewingId, key: fi.key, rating: rating)
                                            }
                                            if idx < group.items.count - 1 { BZDivider().padding(.leading, 16) }
                                        }
                                    }
                                }
                            }
                            .padding(.horizontal, 20)
                        }
                    }
                }
                .padding(.top, 24)

                // Note field
                VStack(alignment: .leading, spacing: 8) {
                    CatHeader(label: L.note(v.market)).padding(.horizontal, 20)
                    BZCard {
                        let placeholder = isRoom
                            ? L.notePlaceholder(v.market)
                            : L.notePlaceholderSection(v.market)
                        NoteField(text: note, placeholder: placeholder) { text in
                            store.setNote(viewingId: viewingId, entryId: entryId, text: text)
                        }
                    }
                    .padding(.horizontal, 20)
                }
                .padding(.top, 24)

                Button { dismiss() } label: {
                    Text(L.doneWith(entryLabel, market: v.market))
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 18)
                        .background(Color.bzFg)
                        .clipShape(Capsule())
                }
                .padding(.horizontal, 20)
                .padding(.top, 20)

                Spacer(minLength: 40)
            }
        }
        .dismissKeyboardOnTap()
    }
}

// MARK: – Single checklist item row
private struct ItemRow: View {
    let viewingId: UUID
    let item: ChecklistItem
    let key: String
    let value: Rating?
    let market: Market
    let itemNote: String?
    let itemPhotoIds: [String]
    let onChange: (Rating?) -> Void

    @State private var showDetail = false

    private var hasItemDetail: Bool { !itemPhotoIds.isEmpty || !(itemNote ?? "").isEmpty }

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            VStack(alignment: .leading, spacing: 4) {
                Text(item.label)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(Color.bzFg)
                    .fixedSize(horizontal: false, vertical: true)
                if let hint = item.hint {
                    Text(hint)
                        .font(.system(size: 13))
                        .foregroundStyle(Color.bzMuted)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
            RatingControl(value: value, market: market) { rating in
                onChange(rating)
                if rating == .niet { showDetail = true }
            }
            if hasItemDetail {
                ItemDetailBadge(photoCount: itemPhotoIds.count,
                                hasNote: !(itemNote ?? "").isEmpty,
                                market: market) {
                    showDetail = true
                }
            }
        }
        .padding(16)
        .sheet(isPresented: $showDetail) {
            ItemDetailSheet(viewingId: viewingId, itemKey: key,
                            item: item, market: market)
        }
    }
}

// MARK: – Small badge showing item-level photo/note indicator
private struct ItemDetailBadge: View {
    let photoCount: Int
    let hasNote: Bool
    let market: Market
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 6) {
                if photoCount > 0 {
                    HStack(spacing: 3) {
                        Image(systemName: "camera.fill")
                            .font(.system(size: 11, weight: .medium))
                        Text("\(photoCount)")
                            .font(.system(size: 12, weight: .semibold))
                    }
                }
                if hasNote {
                    Image(systemName: "text.quote")
                        .font(.system(size: 11, weight: .medium))
                }
                Image(systemName: "chevron.right")
                    .font(.system(size: 10, weight: .semibold))
                    .opacity(0.6)
            }
            .foregroundStyle(Color.bzBadInk)
            .padding(.horizontal, 10)
            .padding(.vertical, 5)
            .background(Color.bzBadSoft)
            .clipShape(Capsule())
        }
        .buttonStyle(.plain)
    }
}

// MARK: – Rating control (pill style + N.v.t.)
private struct RatingControl: View {
    let value: Rating?
    let market: Market
    let onChange: (Rating?) -> Void

    var body: some View {
        HStack(spacing: 8) {
            RatingPill(label: L.ratingGood(market), icon: "checkmark", rating: .goed,
                       current: value, onChange: onChange)
            RatingPill(label: L.ratingBad(market), icon: "exclamationmark", rating: .niet,
                       current: value, onChange: onChange)
            Button {
                onChange(value == .na ? nil : .na)
            } label: {
                Text(L.ratingNA(market))
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(value == .na ? Color.bzFg : Color.bzMuted)
                    .padding(.horizontal, 10)
                    .frame(height: 32)
                    .background(value == .na ? Color.bzBg : Color.clear)
                    .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                    .overlay(
                        RoundedRectangle(cornerRadius: 10, style: .continuous)
                            .strokeBorder(
                                value == .na ? Color.bzFg.opacity(0.18) : Color.bzLine,
                                style: StrokeStyle(lineWidth: 1, dash: value == .na ? [] : [4, 3])
                            )
                    )
            }
            .buttonStyle(.plain)
        }
    }
}

private struct RatingPill: View {
    let label: String; let icon: String; let rating: Rating
    let current: Rating?
    let onChange: (Rating?) -> Void

    private var active: Bool { current == rating }
    private var bg: Color { rating == .goed ? (active ? Color.bzGoodSoft : .clear) : (active ? Color.bzBadSoft : .clear) }
    private var border: Color { rating == .goed ? (active ? Color.bzGood : Color.bzLine) : (active ? Color.bzBad : Color.bzLine) }
    private var fg: Color { rating == .goed ? (active ? Color.bzGoodInk : Color.bzMuted) : (active ? Color.bzBadInk : Color.bzMuted) }
    private var markBg: Color { rating == .goed ? (active ? Color.bzGood : Color.bzLine.opacity(0.5)) : (active ? Color.bzBad : Color.bzLine.opacity(0.5)) }

    var body: some View {
        Button {
            onChange(active ? nil : rating)
        } label: {
            HStack(spacing: 6) {
                Image(systemName: active ? icon : "circle")
                    .font(.system(size: active ? 11 : 10, weight: .semibold))
                    .foregroundStyle(active ? .white : Color.bzMuted)
                    .frame(width: 18, height: 18)
                    .background(active ? markBg : Color.clear)
                    .clipShape(Circle())
                Text(label)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(fg)
            }
            .padding(.horizontal, 12).padding(.vertical, 10)
            .frame(maxWidth: .infinity)
            .background(bg)
            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
            .overlay(RoundedRectangle(cornerRadius: 12, style: .continuous)
                .strokeBorder(border, lineWidth: 1.5))
        }
        .buttonStyle(.plain)
    }
}

// MARK: – Note text field
private struct NoteField: View {
    let text: String
    let placeholder: String
    let onChange: (String) -> Void
    @State private var local: String

    init(text: String, placeholder: String, onChange: @escaping (String) -> Void) {
        self.text = text; self.placeholder = placeholder; self.onChange = onChange
        _local = State(initialValue: text)
    }

    var body: some View {
        VStack(alignment: .trailing, spacing: 4) {
            TextEditor(text: Binding(
                get: { local },
                set: { v in local = v; onChange(v) }
            ))
            .font(.system(size: 15))
            .foregroundStyle(Color.bzFg)
            .frame(minHeight: 64)
            .scrollContentBackground(.hidden)
            .overlay(alignment: .topLeading) {
                if local.isEmpty {
                    Text(placeholder)
                        .font(.system(size: 15))
                        .foregroundStyle(Color.bzMuted)
                        .allowsHitTesting(false)
                        .padding(.top, 8).padding(.leading, 4)
                }
            }
            Text("\(local.count)/240")
                .font(.system(size: 12).monospacedDigit())
                .foregroundStyle(Color.bzMuted)
        }
        .padding(16)
        .onChange(of: text) { _, new in if local != new { local = new } }
    }
}
