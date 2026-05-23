import SwiftUI

struct BuddyDetailView: View {
    @EnvironmentObject var diveStore: DiveStore
    @Environment(\.dismiss) private var dismiss

    let existingBuddy: Buddy?

    @State private var name: String
    @State private var email: String
    @State private var phone: String
    @State private var certificationLevel: CertificationLevel
    @State private var certificationAgency: String
    @State private var notes: String

    @State private var isEditing: Bool
    @State private var showingDeleteAlert = false

    init(buddy: Buddy?) {
        self.existingBuddy = buddy
        let b = buddy ?? Buddy()
        _name = State(initialValue: b.name)
        _email = State(initialValue: b.email)
        _phone = State(initialValue: b.phone)
        _certificationLevel = State(initialValue: b.certificationLevel)
        _certificationAgency = State(initialValue: b.certificationAgency)
        _notes = State(initialValue: b.notes)
        _isEditing = State(initialValue: buddy == nil)
    }

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    buddyAvatarHeader
                }
                .listRowBackground(Color.clear)

                Section("Contact") {
                    if isEditing {
                        TextField("Full Name", text: $name)
                        TextField("Email", text: $email)
                            .keyboardType(.emailAddress)
                            .textInputAutocapitalization(.never)
                        TextField("Phone", text: $phone)
                            .keyboardType(.phonePad)
                    } else {
                        LabeledContent("Name", value: name.isEmpty ? "—" : name)
                        if !email.isEmpty {
                            LabeledContent("Email", value: email)
                        }
                        if !phone.isEmpty {
                            LabeledContent("Phone", value: phone)
                        }
                    }
                }

                Section("Certification") {
                    if isEditing {
                        Picker("Level", selection: $certificationLevel) {
                            ForEach(CertificationLevel.allCases, id: \.self) { level in
                                Text(level.rawValue).tag(level)
                            }
                        }
                        TextField("Agency (e.g. PADI, SSI)", text: $certificationAgency)
                    } else {
                        HStack {
                            Image(systemName: certificationLevel.icon)
                                .foregroundStyle(.cyan)
                            Text(certificationLevel.rawValue)
                        }
                        if !certificationAgency.isEmpty {
                            LabeledContent("Agency", value: certificationAgency)
                        }
                    }
                }

                if let buddy = existingBuddy {
                    let sharedDives = diveStore.dives(for: buddy)
                    if !sharedDives.isEmpty {
                        Section("Dives Together (\(sharedDives.count))") {
                            ForEach(sharedDives) { dive in
                                NavigationLink(destination: DiveDetailView(dive: dive)) {
                                    HStack {
                                        VStack(alignment: .leading, spacing: 2) {
                                            Text(dive.title.isEmpty ? "Untitled Dive" : dive.title)
                                                .font(.subheadline)
                                            Text(dive.date.formatted(date: .abbreviated, time: .omitted))
                                                .font(.caption)
                                                .foregroundStyle(.secondary)
                                        }
                                        Spacer()
                                        Text(String(format: "%.1fm", dive.maxDepth))
                                            .font(.caption)
                                            .foregroundStyle(.cyan)
                                    }
                                }
                            }
                        }
                    }
                }

                Section("Notes") {
                    if isEditing {
                        TextEditor(text: $notes)
                            .frame(minHeight: 80)
                    } else {
                        Text(notes.isEmpty ? "No notes" : notes)
                            .foregroundStyle(notes.isEmpty ? .secondary : .primary)
                    }
                }

                if existingBuddy != nil {
                    Section {
                        Button("Delete Buddy", role: .destructive) {
                            showingDeleteAlert = true
                        }
                    }
                }
            }
            .navigationTitle(existingBuddy == nil ? "New Buddy" : (isEditing ? "Edit Buddy" : (name.isEmpty ? "Buddy Details" : name)))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    if existingBuddy == nil || isEditing {
                        Button("Cancel") {
                            if existingBuddy == nil {
                                dismiss()
                            } else {
                                isEditing = false
                            }
                        }
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    if isEditing {
                        Button("Save") { saveBuddy() }
                            .bold()
                    } else {
                        Button("Edit") { isEditing = true }
                    }
                }
            }
            .alert("Delete Buddy", isPresented: $showingDeleteAlert) {
                Button("Delete", role: .destructive) {
                    if let buddy = existingBuddy,
                       let index = diveStore.buddies.firstIndex(where: { $0.id == buddy.id }) {
                        diveStore.deleteBuddy(at: IndexSet([index]))
                        dismiss()
                    }
                }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("This action cannot be undone.")
            }
        }
    }

    private var buddyAvatarHeader: some View {
        HStack {
            Spacer()
            VStack(spacing: 8) {
                ZStack {
                    Circle()
                        .fill(.cyan.opacity(0.2))
                        .frame(width: 80, height: 80)
                    let initials = name.split(separator: " ").prefix(2).compactMap { $0.first }.map { String($0) }.joined().uppercased()
                    Text(initials.isEmpty ? "?" : initials)
                        .font(.largeTitle.bold())
                        .foregroundStyle(.cyan)
                }
                if !name.isEmpty {
                    Text(name)
                        .font(.headline)
                }
            }
            Spacer()
        }
        .padding(.vertical, 8)
    }

    private func saveBuddy() {
        var buddy = existingBuddy ?? Buddy()
        buddy.name = name
        buddy.email = email
        buddy.phone = phone
        buddy.certificationLevel = certificationLevel
        buddy.certificationAgency = certificationAgency
        buddy.notes = notes

        if existingBuddy != nil {
            diveStore.updateBuddy(buddy)
        } else {
            diveStore.addBuddy(buddy)
        }
        isEditing = false
        dismiss()
    }
}

#Preview {
    BuddyDetailView(buddy: Buddy.sampleBuddies[0])
        .environmentObject(DiveStore())
}
