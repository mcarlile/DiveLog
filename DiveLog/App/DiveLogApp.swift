import SwiftUI

@main
struct DiveLogApp: App {
    @StateObject private var diveStore = DiveStore()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(diveStore)
        }
    }
}
