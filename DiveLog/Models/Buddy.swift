import Foundation

struct Buddy: Identifiable, Codable {
    var id: UUID = UUID()
    var name: String
    var email: String
    var phone: String
    var certificationLevel: CertificationLevel
    var certificationAgency: String
    var notes: String
    var totalDivesTogether: Int
    var avatarInitials: String {
        let parts = name.split(separator: " ")
        let initials = parts.prefix(2).compactMap { $0.first }.map { String($0) }
        return initials.joined().uppercased()
    }

    init(
        name: String = "",
        email: String = "",
        phone: String = "",
        certificationLevel: CertificationLevel = .openWater,
        certificationAgency: String = "",
        notes: String = "",
        totalDivesTogether: Int = 0
    ) {
        self.name = name
        self.email = email
        self.phone = phone
        self.certificationLevel = certificationLevel
        self.certificationAgency = certificationAgency
        self.notes = notes
        self.totalDivesTogether = totalDivesTogether
    }
}

enum CertificationLevel: String, Codable, CaseIterable {
    case openWater = "Open Water"
    case advancedOpenWater = "Advanced Open Water"
    case rescueDiver = "Rescue Diver"
    case diveMaster = "Divemaster"
    case instructor = "Instructor"
    case technical = "Technical Diver"

    var icon: String {
        switch self {
        case .openWater: return "1.circle"
        case .advancedOpenWater: return "2.circle"
        case .rescueDiver: return "cross.circle"
        case .diveMaster: return "star.circle"
        case .instructor: return "star.fill"
        case .technical: return "gearshape.2"
        }
    }
}

extension Buddy {
    static var sampleBuddies: [Buddy] = [
        Buddy(
            name: "Alex Torres",
            email: "alex.torres@example.com",
            phone: "+1 555-0101",
            certificationLevel: .advancedOpenWater,
            certificationAgency: "PADI",
            notes: "Excellent underwater photographer.",
            totalDivesTogether: 24
        ),
        Buddy(
            name: "Mia Chen",
            email: "mia.chen@example.com",
            phone: "+1 555-0102",
            certificationLevel: .rescueDiver,
            certificationAgency: "SSI",
            notes: "Very safety-conscious diver.",
            totalDivesTogether: 15
        ),
        Buddy(
            name: "Jordan Smith",
            email: "jordan.smith@example.com",
            phone: "+1 555-0103",
            certificationLevel: .diveMaster,
            certificationAgency: "NAUI",
            notes: "Local dive guide in Hawaii.",
            totalDivesTogether: 8
        )
    ]
}
