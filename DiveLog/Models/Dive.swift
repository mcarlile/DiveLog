import Foundation
import CoreLocation

struct Dive: Identifiable, Codable {
    var id: UUID = UUID()
    var title: String
    var date: Date
    var location: String
    var latitude: Double?
    var longitude: Double?
    var maxDepth: Double        // meters
    var duration: TimeInterval  // seconds
    var waterTemperature: Double? // Celsius
    var visibility: Double?    // meters
    var notes: String
    var buddyIDs: [UUID]
    var depthProfile: [DepthSample]
    var diveSite: String?
    var airTemperature: Double?  // Celsius
    var tankPressureStart: Double? // bar
    var tankPressureEnd: Double?   // bar
    var gasMix: String?

    init(
        title: String = "",
        date: Date = Date(),
        location: String = "",
        latitude: Double? = nil,
        longitude: Double? = nil,
        maxDepth: Double = 0,
        duration: TimeInterval = 0,
        waterTemperature: Double? = nil,
        visibility: Double? = nil,
        notes: String = "",
        buddyIDs: [UUID] = [],
        depthProfile: [DepthSample] = [],
        diveSite: String? = nil,
        airTemperature: Double? = nil,
        tankPressureStart: Double? = nil,
        tankPressureEnd: Double? = nil,
        gasMix: String? = nil
    ) {
        self.title = title
        self.date = date
        self.location = location
        self.latitude = latitude
        self.longitude = longitude
        self.maxDepth = maxDepth
        self.duration = duration
        self.waterTemperature = waterTemperature
        self.visibility = visibility
        self.notes = notes
        self.buddyIDs = buddyIDs
        self.depthProfile = depthProfile
        self.diveSite = diveSite
        self.airTemperature = airTemperature
        self.tankPressureStart = tankPressureStart
        self.tankPressureEnd = tankPressureEnd
        self.gasMix = gasMix
    }

    var coordinate: CLLocationCoordinate2D? {
        guard let lat = latitude, let lon = longitude else { return nil }
        return CLLocationCoordinate2D(latitude: lat, longitude: lon)
    }

    var formattedDuration: String {
        let minutes = Int(duration) / 60
        let seconds = Int(duration) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
}

struct DepthSample: Identifiable, Codable {
    var id: UUID = UUID()
    var time: TimeInterval  // seconds from dive start
    var depth: Double       // meters
}

extension Dive {
    static var sampleDives: [Dive] = [
        Dive(
            title: "Great Barrier Reef",
            date: Calendar.current.date(byAdding: .day, value: -14, to: Date())!,
            location: "Cairns, Australia",
            latitude: -16.9186,
            longitude: 145.7781,
            maxDepth: 18.5,
            duration: 3240,
            waterTemperature: 27.0,
            visibility: 20.0,
            notes: "Incredible visibility. Saw a sea turtle and a reef shark.",
            depthProfile: DepthSample.sampleProfile(maxDepth: 18.5, duration: 3240)
        ),
        Dive(
            title: "Blue Hole",
            date: Calendar.current.date(byAdding: .day, value: -7, to: Date())!,
            location: "Dahab, Egypt",
            latitude: 28.5708,
            longitude: 34.5186,
            maxDepth: 32.0,
            duration: 2700,
            waterTemperature: 24.0,
            visibility: 30.0,
            notes: "Deep dive into the famous Blue Hole. Stunning arch at 55m.",
            depthProfile: DepthSample.sampleProfile(maxDepth: 32.0, duration: 2700)
        ),
        Dive(
            title: "Manta Ray Night Dive",
            date: Calendar.current.date(byAdding: .day, value: -2, to: Date())!,
            location: "Kona, Hawaii",
            latitude: 19.6400,
            longitude: -155.9969,
            maxDepth: 12.0,
            duration: 2880,
            waterTemperature: 26.0,
            visibility: 15.0,
            notes: "Night dive with manta rays. Magical experience.",
            depthProfile: DepthSample.sampleProfile(maxDepth: 12.0, duration: 2880)
        )
    ]
}

extension DepthSample {
    static func sampleProfile(maxDepth: Double, duration: TimeInterval) -> [DepthSample] {
        var samples: [DepthSample] = []
        let count = 60
        for i in 0...count {
            let t = duration * Double(i) / Double(count)
            let progress = Double(i) / Double(count)
            let depth: Double
            if progress < 0.15 {
                depth = maxDepth * (progress / 0.15)
            } else if progress < 0.8 {
                let variation = sin(progress * 10) * maxDepth * 0.1
                depth = maxDepth * 0.85 + variation
            } else {
                depth = maxDepth * 0.85 * (1.0 - (progress - 0.8) / 0.2)
            }
            samples.append(DepthSample(time: t, depth: max(0, depth)))
        }
        return samples
    }
}
