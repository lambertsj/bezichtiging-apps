import SwiftUI

struct IndividualRoomsView: View {
    let viewingId: UUID
    @Environment(ViewingStore.self) var store

    private var viewing: Viewing? { store.viewings.first { $0.id == viewingId } }
    private var market: Market { viewing?.market ?? .nl }

    var body: some View {
        Group {
            if let v = viewing {
                content(v)
            }
        }
        .background(Color.bzBg)
        .navigationTitle(L.indivRoomsTitle(market))
        .navigationBarTitleDisplayMode(.inline)
    }

    @ViewBuilder
    private func content(_ v: Viewing) -> some View {
        let vType = v.type; let vTenure = v.tenure
        let rooms = ChecklistData.rooms(for: vType, market: v.market)

        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                VStack(alignment: .leading, spacing: 6) {
                    Text(L.indivRoomsTitle(v.market))
                        .font(.system(size: 32, weight: .bold))
                        .foregroundStyle(Color.bzFg)
                    Text(L.indivRoomsSub(v.market))
                        .font(.system(size: 15))
                        .foregroundStyle(Color.bzMuted)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .padding(.horizontal, 20)
                .padding(.top, 8)
                .padding(.bottom, 20)

                BZCard {
                    VStack(spacing: 0) {
                        ForEach(Array(rooms.enumerated()), id: \.element.id) { idx, room in
                            NavigationLink(destination: ChecklistView(viewingId: viewingId, entryId: room.id, isRoom: true)) {
                                EntryRow(entryId: room.id, label: room.label, sub: room.sub,
                                         viewing: v, vType: vType, vTenure: vTenure)
                            }
                            .buttonStyle(.plain)
                            if idx < rooms.count - 1 { BZDivider().padding(.leading, 56) }
                        }
                    }
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 32)
            }
        }
    }
}
