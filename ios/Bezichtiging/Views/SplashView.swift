import SwiftUI

struct SplashView: View {
    let market: Market
    @State private var appeared = false

    var body: some View {
        ZStack {
            Color.bzBg.ignoresSafeArea()
            VStack(spacing: 18) {
                ZStack {
                    Circle()
                        .fill(Color.bzAccent.opacity(0.10))
                        .frame(width: 96, height: 96)
                    Image(systemName: "house.fill")
                        .font(.system(size: 44, weight: .regular))
                        .foregroundStyle(Color.bzAccent)
                }
                VStack(spacing: 6) {
                    Text(L.appName(market))
                        .font(.system(size: 26, weight: .semibold))
                        .foregroundStyle(Color.bzFg)
                    Text(L.splashSubtitle(market))
                        .font(.system(size: 14))
                        .foregroundStyle(Color.bzMuted)
                }
            }
            .scaleEffect(appeared ? 1 : 0.88)
            .opacity(appeared ? 1 : 0)
            .onAppear {
                withAnimation(.spring(response: 0.5, dampingFraction: 0.75)) {
                    appeared = true
                }
            }
        }
    }
}

#Preview { SplashView(market: .nl) }
