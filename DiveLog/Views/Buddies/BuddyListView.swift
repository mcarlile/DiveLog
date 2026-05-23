import SwiftUI

struct BuddyListView: View {
    @EnvironmentObject var diveStore: DiveStore
    @State private var showingAddBuddy = false
    @State private var searchText = ""

    var filteredBuddies: [Buddy] {
        searchText.isEmpty
            ? diveStore.buddies
            : diveStore.buddies.filter {
                $0.name.localizedCaseInsensitiveContains(searchText) ||
                $0.certificationAgency.localizedCaseInsensitiveContains(searchText)
            }
    }

    var body: some View {
        NavigationStack {
            Group {
                if diveStore.buddies.isEmpty {
                    emptyState
                } else {
                    buddyList
                }
            }
            .navigationTitle("Buddies")
            .searchable(text: $searchText, prompt: "Search buddies...")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showingAddBuddy = true
                    } label: {
                        Image(systemName: "person.badge.plus")
                    }
                }
            }
            .sheet(isPresented: $showingAddBuddy) {
                BuddyDetailView(buddy: nil)
            }
        }
    }

    private var buddyList: some View {
        List {
            ForEach(filteredBuddies) { buddy in
                NavigationLink(destination: BuddyDetailView(buddy: buddy)) {
                    BuddyRowView(buddy: buddy, diveCount: diveStore.dives(for: buddy).count)
                }
            }
            .onDelete { offsets in
                diveStore.deleteBuddy(at: offsets)
            }
        }
        .listStyle(.insetGrouped)
    }

    private var emptyState: some View {
        VStack(spacing: 16) {
            Image(systemName: "person.2")
                .font(.system(size: 64))
                .foregroundStyle(.cyan.opacity(0.6))
            Text("No Buddies Yet")
                .font(.title2.bold())
            Text("Tap + to add your first dive buddy")
                .foregroundStyle(.secondary)
            Button("Add Buddy") {
                showingAddBuddy = true
            }
            .buttonStyle(.borderedProminent)
            .tint(.cyan)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

struct BuddyRowView: View {
    let buddy: Buddy
    let diveCount: Int

    var body: some View {
        HStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(.cyan.opacity(0.2))
                    .frame(width: 44, height: 44)
                Text(buddy.avatarInitials)
                    .font(.headline)
                    .foregroundStyle(.cyan)
            }

            VStack(alignment: .leading, spacing: 3) {
                Text(buddy.name.isEmpty ? "Unnamed Buddy" : buddy.name)
                    .font(.headline)
                HStack(spacing: 6) {
                    Image(systemName: buddy.certificationLevel.icon)
                        .font(.caption)
                    Text(buddy.certificationLevel.rawValue)
                        .font(.subheadline)
                    if !buddy.certificationAgency.isEmpty {
                        Text("· \(buddy.certificationAgency)")
                            .font(.subheadline)
                    }
                }
                .foregroundStyle(.secondary)
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 2) {
                Text("\(diveCount)")
                    .font(.title3.bold())
                    .foregroundStyle(.cyan)
                Text("dives")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    BuddyListView()
        .environmentObject(DiveStore())
}
