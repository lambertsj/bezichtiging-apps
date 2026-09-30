import SwiftUI

@main
struct BezichtigingApp: App {
    @State private var store = ViewingStore()
    @State private var showSplash = true
    // Captured once at launch: true only for returning users, not after fresh onboarding.
    @State private var splashEnabled = false

    var body: some Scene {
        WindowGroup {
            ZStack {
                HomeView()
                    .environment(store)
                if showSplash && splashEnabled {
                    SplashView(market: store.market)
                        .transition(.opacity)
                        .zIndex(1)
                }
                if !store.hasCompletedOnboarding {
                    OnboardingView()
                        .environment(store)
                        .transition(.opacity)
                        .zIndex(2)
                }
            }
            .onAppear {
                splashEnabled = store.hasCompletedOnboarding
                guard store.hasCompletedOnboarding else { return }
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.4) {
                    withAnimation(.easeOut(duration: 0.35)) { showSplash = false }
                }
            }
        }
    }
}
