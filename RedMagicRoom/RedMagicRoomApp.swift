import SwiftUI

@main
struct RedMagicRoomApp: App {
    @State private var appState = AppState()

    var body: some Scene {
        MenuBarExtra {
            ContentView(state: appState)
        } label: {
            Image(systemName: appState.isPlaying
                  ? "lock.shield.fill"
                  : "lock.shield")
                .font(.system(size: 22, weight: .regular))
        }
        .menuBarExtraStyle(.window)
    }
}
