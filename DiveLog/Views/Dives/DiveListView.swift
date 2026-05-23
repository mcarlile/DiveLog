import SwiftUI

struct DiveListView: View {
    @EnvironmentObject var diveStore: DiveStore
    @State private var showingAddDive = false
    @State private var searchText = ""
    @State private var sortOrder: SortOrder = .dateDescending

    enum SortOrder: String, CaseIterable {
        case dateDescending = "Newest First"
        case dateAscending = "Oldest First"
        case depthDescending = "Deepest First"
        case durationDescending = "Longest First"
    }

    var filteredDives: [Dive] {
        let filtered = searchText.isEmpty
            ? diveStore.dives
            : diveStore.dives.filter {
                $0.title.localizedCaseInsensitiveContains(searchText) ||
                $0.location.localizedCaseInsensitiveContains(searchText)
            }

        switch sortOrder {
        case .dateDescending:
            return filtered.sorted { $0.date > $1.date }
        case .dateAscending:
            return filtered.sorted { $0.date < $1.date }
        case .depthDescending:
            return filtered.sorted { $0.maxDepth > $1.maxDepth }
        case .durationDescending:
            return filtered.sorted { $0.duration > $1.duration }
        }
    }

    var body: some View {
        NavigationStack {
            Group {
                if diveStore.dives.isEmpty {
                    emptyState
                } else {
                    diveList
                }
            }
            .navigationTitle("My Dives")
            .searchable(text: $searchText, prompt: "Search dives...")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showingAddDive = true
                    } label: {
                        Image(systemName: "plus")
                    }
                }
                ToolbarItem(placement: .topBarLeading) {
                    Menu {
                        Picker("Sort", selection: $sortOrder) {
                            ForEach(SortOrder.allCases, id: \.self) { order in
                                Text(order.rawValue).tag(order)
                            }
                        }
                    } label: {
                        Image(systemName: "arrow.up.arrow.down")
                    }
                }
            }
            .sheet(isPresented: $showingAddDive) {
                DiveDetailView(dive: nil)
            }
        }
    }

    private var diveList: some View {
        List {
            ForEach(filteredDives) { dive in
                NavigationLink(destination: DiveDetailView(dive: dive)) {
                    DiveRowView(dive: dive)
                }
            }
            .onDelete { offsets in
                let sorted = filteredDives
                let toDelete = offsets.map { sorted[$0] }
                for dive in toDelete {
                    diveStore.deleteDive(dive)
                }
            }
        }
        .listStyle(.insetGrouped)
    }

    private var emptyState: some View {
        VStack(spacing: 16) {
            Image(systemName: "water.waves")
                .font(.system(size: 64))
                .foregroundStyle(.cyan.opacity(0.6))
            Text("No Dives Yet")
                .font(.title2.bold())
            Text("Tap + to log your first dive")
                .foregroundStyle(.secondary)
            Button("Add Dive") {
                showingAddDive = true
            }
            .buttonStyle(.borderedProminent)
            .tint(.cyan)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

struct DiveRowView: View {
    let dive: Dive

    var body: some View {
        HStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(.cyan.opacity(0.15))
                    .frame(width: 44, height: 44)
                Image(systemName: "water.waves")
                    .foregroundStyle(.cyan)
                    .font(.system(size: 20))
            }

            VStack(alignment: .leading, spacing: 3) {
                Text(dive.title.isEmpty ? "Untitled Dive" : dive.title)
                    .font(.headline)
                    .lineLimit(1)
                Text(dive.location.isEmpty ? "Unknown Location" : dive.location)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
                Text(dive.date.formatted(date: .abbreviated, time: .omitted))
                    .font(.caption)
                    .foregroundStyle(.tertiary)
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 3) {
                Text(String(format: "%.1fm", dive.maxDepth))
                    .font(.subheadline.bold())
                    .foregroundStyle(.cyan)
                Text(dive.formattedDuration)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    DiveListView()
        .environmentObject(DiveStore())
}
