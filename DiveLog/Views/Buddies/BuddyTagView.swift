import SwiftUI

struct BuddyTagView: View {
    let buddy: Buddy
    var compact: Bool = false

    var body: some View {
        HStack(spacing: compact ? 6 : 8) {
            ZStack {
                Circle()
                    .fill(.cyan.opacity(0.2))
                    .frame(width: compact ? 28 : 36, height: compact ? 28 : 36)
                Text(buddy.avatarInitials)
                    .font(compact ? .caption.bold() : .subheadline.bold())
                    .foregroundStyle(.cyan)
            }

            if !compact {
                VStack(alignment: .leading, spacing: 2) {
                    Text(buddy.name)
                        .font(.subheadline)
                        .lineLimit(1)
                    Text(buddy.certificationLevel.rawValue)
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
            } else {
                Text(buddy.name)
                    .font(.caption)
                    .lineLimit(1)
            }
        }
        .padding(.horizontal, compact ? 8 : 10)
        .padding(.vertical, compact ? 4 : 6)
        .background(
            Capsule()
                .fill(.cyan.opacity(0.08))
                .overlay(
                    Capsule()
                        .strokeBorder(.cyan.opacity(0.25), lineWidth: 1)
                )
        )
    }
}

struct BuddyTagsRow: View {
    let buddies: [Buddy]

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(buddies) { buddy in
                    BuddyTagView(buddy: buddy, compact: true)
                }
            }
            .padding(.horizontal, 2)
        }
    }
}

#Preview {
    VStack(spacing: 16) {
        ForEach(Buddy.sampleBuddies) { buddy in
            BuddyTagView(buddy: buddy)
        }
        BuddyTagsRow(buddies: Buddy.sampleBuddies)
    }
    .padding()
}
