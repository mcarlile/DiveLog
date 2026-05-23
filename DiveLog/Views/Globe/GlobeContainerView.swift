import SwiftUI

struct GlobeContainerView: View {
    @EnvironmentObject var diveStore: DiveStore
    @State private var selectedDive: Dive?
    @State private var showingDiveDetail = false

    var body: some View {
        NavigationStack {
            ZStack {
                Color(red: 0.02, green: 0.04, blue: 0.12)
                    .ignoresSafeArea()

                GlobeView(dives: diveStore.dives) { dive in
                    selectedDive = dive
                    showingDiveDetail = true
                }
                .ignoresSafeArea()

                VStack {
                    Spacer()
                    statsOverlay
                        .padding(.horizontal)
                        .padding(.bottom, 24)
                }
            }
            .navigationTitle("Dive Globe")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(.ultraThinMaterial, for: .navigationBar)
            .sheet(item: $selectedDive) { dive in
                DiveDetailView(dive: dive)
            }
        }
    }

    private var statsOverlay: some View {
        HStack(spacing: 16) {
            statCard(value: "\(diveStore.totalDives)", label: "Dives")
            statCard(value: String(format: "%.0fm", diveStore.deepestDive?.maxDepth ?? 0), label: "Deepest")
            statCard(
                value: formatHours(diveStore.totalDiveTime),
                label: "Total Time"
            )
        }
    }

    private func statCard(value: String, label: String) -> some View {
        VStack(spacing: 2) {
            Text(value)
                .font(.title3.bold())
                .foregroundStyle(.cyan)
            Text(label)
                .font(.caption2)
                .foregroundStyle(.white.opacity(0.7))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 10)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12))
    }

    private func formatHours(_ interval: TimeInterval) -> String {
        let hours = Int(interval) / 3600
        if hours >= 100 {
            return "\(hours)h"
        }
        let minutes = (Int(interval) % 3600) / 60
        return "\(hours)h \(minutes)m"
    }
}

#Preview {
    GlobeContainerView()
        .environmentObject(DiveStore())
}
