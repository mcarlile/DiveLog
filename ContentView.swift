import SwiftUI

struct ContentView: View {
    @EnvironmentObject var diveStore: DiveStore

    var body: some View {
        TabView {
            GlobeContainerView()
                .tabItem {
                    Label("Globe", systemImage: "globe")
                }

            DiveListView()
                .tabItem {
                    Label("Dives", systemImage: "water.waves")
                }

            BuddyListView()
                .tabItem {
                    Label("Buddies", systemImage: "person.2")
                }
        }
        .tint(.cyan)
    }
}

#Preview {
    ContentView()
        .environmentObject(DiveStore())
}
