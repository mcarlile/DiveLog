import Foundation
import Combine

class DiveStore: ObservableObject {
    @Published var dives: [Dive] = []
    @Published var buddies: [Buddy] = []

    private let divesKey = "saved_dives"
    private let buddiesKey = "saved_buddies"

    init() {
        loadDives()
        loadBuddies()
        if dives.isEmpty {
            dives = Dive.sampleDives
            saveDives()
        }
        if buddies.isEmpty {
            buddies = Buddy.sampleBuddies
            saveBuddies()
        }
    }

    // MARK: - Dives

    func addDive(_ dive: Dive) {
        dives.insert(dive, at: 0)
        saveDives()
    }

    func updateDive(_ dive: Dive) {
        if let index = dives.firstIndex(where: { $0.id == dive.id }) {
            dives[index] = dive
            saveDives()
        }
    }

    func deleteDive(at offsets: IndexSet) {
        dives.remove(atOffsets: offsets)
        saveDives()
    }

    func deleteDive(_ dive: Dive) {
        dives.removeAll { $0.id == dive.id }
        saveDives()
    }

    func buddies(for dive: Dive) -> [Buddy] {
        buddies.filter { dive.buddyIDs.contains($0.id) }
    }

    var totalDives: Int { dives.count }

    var totalDepthMeters: Double {
        dives.reduce(0) { $0 + $1.maxDepth }
    }

    var totalDiveTime: TimeInterval {
        dives.reduce(0) { $0 + $1.duration }
    }

    var deepestDive: Dive? {
        dives.max(by: { $0.maxDepth < $1.maxDepth })
    }

    var longestDive: Dive? {
        dives.max(by: { $0.duration < $1.duration })
    }

    // MARK: - Buddies

    func addBuddy(_ buddy: Buddy) {
        buddies.append(buddy)
        saveBuddies()
    }

    func updateBuddy(_ buddy: Buddy) {
        if let index = buddies.firstIndex(where: { $0.id == buddy.id }) {
            buddies[index] = buddy
            saveBuddies()
        }
    }

    func deleteBuddy(at offsets: IndexSet) {
        buddies.remove(atOffsets: offsets)
        saveBuddies()
    }

    func dives(for buddy: Buddy) -> [Dive] {
        dives.filter { $0.buddyIDs.contains(buddy.id) }
    }

    // MARK: - Persistence

    private func saveDives() {
        if let encoded = try? JSONEncoder().encode(dives) {
            UserDefaults.standard.set(encoded, forKey: divesKey)
        }
    }

    private func loadDives() {
        guard let data = UserDefaults.standard.data(forKey: divesKey),
              let decoded = try? JSONDecoder().decode([Dive].self, from: data) else { return }
        dives = decoded
    }

    private func saveBuddies() {
        if let encoded = try? JSONEncoder().encode(buddies) {
            UserDefaults.standard.set(encoded, forKey: buddiesKey)
        }
    }

    private func loadBuddies() {
        guard let data = UserDefaults.standard.data(forKey: buddiesKey),
              let decoded = try? JSONDecoder().decode([Buddy].self, from: data) else { return }
        buddies = decoded
    }
}
