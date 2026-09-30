import SwiftUI
import StoreKit

struct SettingsView: View {
    @Environment(\.dismiss) var dismiss
    @Environment(ViewingStore.self) var store
    @Environment(\.requestReview) private var requestReview

    var body: some View {
        NavigationStack {
            List {
                Section {
                    NavigationLink(L.privacyStatementTitle(store.market)) {
                        PrivacyStatementView(market: store.market)
                    }
                    NavigationLink(L.aboutTitle(store.market)) {
                        AboutView(market: store.market)
                    }
                }
                Section {
                    Button {
                        requestReview()
                    } label: {
                        Label(L.writeReview(store.market), systemImage: "star")
                    }
                }
            }
            .navigationTitle(L.settingsTitle(store.market))
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(L.done(store.market)) { dismiss() }
                }
            }
        }
        .presentationDetents([.medium, .large])
        .presentationDragIndicator(.visible)
    }
}

private struct PrivacyStatementView: View {
    let market: Market

    var body: some View {
        List {
            ForEach(L.privacyItems(market), id: \.0) { item in
                Section(item.0) {
                    Text(item.1)
                        .font(.system(size: 14))
                        .foregroundStyle(Color.bzMuted)
                }
            }
        }
        .navigationTitle(L.privacyStatementTitle(market))
        .navigationBarTitleDisplayMode(.large)
    }
}

private struct AboutView: View {
    let market: Market

    var body: some View {
        List {
            ForEach(L.aboutItems(market), id: \.0) { item in
                Section(item.0) {
                    Text(item.1)
                        .font(.system(size: 14))
                        .foregroundStyle(Color.bzMuted)
                }
            }
        }
        .navigationTitle(L.aboutTitle(market))
        .navigationBarTitleDisplayMode(.large)
    }
}
