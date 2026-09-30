import SwiftUI

struct OnboardingView: View {
    @Environment(ViewingStore.self) var store

    private let isDutch = Market.isDeviceLanguageDutch
    @State private var selected: Market = Market.onboardingDefault()

    var body: some View {
        ZStack {
            Color.bzBg.ignoresSafeArea()
            VStack(spacing: 0) {
                Spacer()

                ZStack {
                    Circle()
                        .fill(Color.bzAccent.opacity(0.10))
                        .frame(width: 88, height: 88)
                    Image(systemName: "house.fill")
                        .font(.system(size: 40, weight: .regular))
                        .foregroundStyle(Color.bzAccent)
                }
                .padding(.bottom, 28)

                Text(L.onboardingTitle(isDutch: isDutch))
                    .font(.system(size: 28, weight: .bold))
                    .foregroundStyle(Color.bzFg)
                    .multilineTextAlignment(.center)
                    .padding(.bottom, 8)

                Text(L.onboardingSubtitle(isDutch: isDutch))
                    .font(.system(size: 15))
                    .foregroundStyle(Color.bzMuted)
                    .multilineTextAlignment(.center)
                    .padding(.bottom, 36)

                VStack(spacing: 12) {
                    ForEach(Market.onboardingMarkets, id: \.self) { market in
                        MarketOption(market: market, isSelected: selected == market)
                            .padding(.horizontal, 20)
                            .onTapGesture { selected = market }
                    }
                }

                Spacer()

                Button {
                    withAnimation(.easeOut(duration: 0.35)) {
                        store.completeOnboarding(market: selected)
                    }
                } label: {
                    Text(L.onboardingCTA(isDutch: isDutch))
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(Color.bzFg)
                        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 40)
            }
        }
    }
}

private struct MarketOption: View {
    let market: Market
    let isSelected: Bool

    var body: some View {
        HStack(spacing: 14) {
            Text(market.flag)
                .font(.system(size: 28))
            Text(market.label)
                .font(.system(size: 17, weight: .semibold))
                .foregroundStyle(Color.bzFg)
            Spacer()
            ZStack {
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 22))
                        .foregroundStyle(Color.bzAccent)
                } else {
                    Circle()
                        .strokeBorder(Color.bzMuted.opacity(0.3), lineWidth: 1.5)
                        .frame(width: 22, height: 22)
                }
            }
            .frame(width: 22, height: 22)
        }
        .padding(.horizontal, 18)
        .padding(.vertical, 16)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(Color.bzSurface)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .strokeBorder(isSelected ? Color.bzAccent : Color.clear, lineWidth: 2)
        )
        .shadow(color: .black.opacity(isSelected ? 0.06 : 0.03), radius: 8, x: 0, y: 2)
    }
}

#Preview {
    OnboardingView()
        .environment(ViewingStore())
}
