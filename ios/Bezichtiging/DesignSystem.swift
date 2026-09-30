import SwiftUI
import UIKit

// MARK: – Colours (matching the HTML prototype palette)
extension Color {
    static let bzBg      = Color(red: 0.957, green: 0.945, blue: 0.925)   // #f4f1ec
    static let bzSurface = Color.white
    static let bzFg      = Color(red: 0.110, green: 0.098, blue: 0.090)   // #1c1917
    static let bzMuted   = Color(red: 0.471, green: 0.443, blue: 0.424)   // #78716c
    static let bzLine    = Color(red: 0.110, green: 0.098, blue: 0.090).opacity(0.07)
    static let bzAccent     = Color(red: 0.761, green: 0.255, blue: 0.047) // #c2410c
    static let bzAccentSoft = Color(red: 0.992, green: 0.843, blue: 0.667) // #fed7aa
    static let bzGood       = Color(red: 0.086, green: 0.639, blue: 0.290) // #16a34a
    static let bzGoodSoft   = Color(red: 0.863, green: 0.988, blue: 0.906) // #dcfce7
    static let bzGoodInk    = Color(red: 0.082, green: 0.502, blue: 0.239) // #15803d
    static let bzBad        = Color(red: 0.863, green: 0.149, blue: 0.149) // #dc2626
    static let bzBadSoft    = Color(red: 0.996, green: 0.886, blue: 0.886) // #fee2e2
    static let bzBadInk     = Color(red: 0.725, green: 0.110, blue: 0.110) // #b91c1c
}

// MARK: – Card
struct BZCard<Content: View>: View {
    let content: Content
    init(@ViewBuilder _ content: () -> Content) { self.content = content() }
    var body: some View {
        content
            .background(Color.bzSurface)
            .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
            .shadow(color: .black.opacity(0.04), radius: 12, x: 0, y: 4)
    }
}

// MARK: – Category header
struct CatHeader: View {
    let label: String
    var body: some View {
        Text(label.uppercased())
            .font(.system(size: 12, weight: .semibold))
            .kerning(0.8)
            .foregroundStyle(Color.bzMuted)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.leading, 4)
    }
}

// MARK: – Row divider
struct BZDivider: View {
    var body: some View { Divider().overlay(Color.bzLine) }
}

// MARK: – Score pill
struct ScorePill: View {
    let viewing: Viewing
    var body: some View {
        let s = viewing.score
        if s.total == 0 {
            Text("—").font(.subheadline).foregroundStyle(Color.bzMuted)
        } else {
            HStack(spacing: 2) {
                Text("\(s.goed)").fontWeight(.semibold).foregroundStyle(Color.bzGoodInk)
                Text("/\(s.total)").foregroundStyle(Color.bzMuted)
            }
            .font(.subheadline.monospacedDigit())
            .padding(.horizontal, 10).padding(.vertical, 5)
            .background(Color.bzBg)
            .clipShape(Capsule())
        }
    }
}

// MARK: – Type badge (house / building icon in a rounded square)
struct TypeBadge: View {
    let type: ViewingType
    var body: some View {
        Image(systemName: type.systemImage)
            .font(.system(size: 17, weight: .medium))
            .foregroundStyle(Color.bzAccent)
            .frame(width: 38, height: 38)
            .background(Color.bzAccentSoft)
            .clipShape(RoundedRectangle(cornerRadius: 11, style: .continuous))
    }
}

// MARK: – Note badge (shown when a note exists on a room)
struct NoteBadge: View {
    var body: some View {
        Image(systemName: "note.text")
            .font(.system(size: 11, weight: .semibold))
            .foregroundStyle(Color.bzAccent)
            .frame(width: 22, height: 22)
            .background(Color.bzAccentSoft)
            .clipShape(RoundedRectangle(cornerRadius: 7, style: .continuous))
    }
}

// MARK: – Room marker (shows first letter or check when complete)
struct RoomMarker: View {
    let answered: Int; let total: Int; let firstLetter: String
    private var state: MarkerState {
        if answered == 0 { .idle }
        else if answered == total { .done }
        else { .partial }
    }
    enum MarkerState { case idle, partial, done }
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(state == .done ? Color.bzGoodSoft : state == .partial ? Color.bzAccentSoft : Color.bzBg)
                .frame(width: 36, height: 36)
            if state == .done {
                Image(systemName: "checkmark")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(Color.bzGoodInk)
            } else {
                Text(firstLetter)
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(state == .partial ? Color.bzAccent : Color.bzFg)
            }
        }
    }
}

// MARK: – Keyboard dismiss
extension View {
    func dismissKeyboardOnTap() -> some View {
        onTapGesture {
            UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
        }
    }
}

// MARK: – Chevron
struct BZChevron: View {
    var body: some View {
        Image(systemName: "chevron.right")
            .font(.system(size: 13, weight: .semibold))
            .foregroundStyle(Color.bzMuted)
    }
}
