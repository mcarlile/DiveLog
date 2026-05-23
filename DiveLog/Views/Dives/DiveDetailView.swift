import SwiftUI

struct DiveDetailView: View {
    @EnvironmentObject var diveStore: DiveStore
    @Environment(\.dismiss) private var dismiss

    let existingDive: Dive?

    @State private var title: String
    @State private var location: String
    @State private var date: Date
    @State private var maxDepth: String
    @State private var duration: String
    @State private var waterTemperature: String
    @State private var visibility: String
    @State private var notes: String
    @State private var gasMix: String
    @State private var tankStart: String
    @State private var tankEnd: String

    @State private var isEditing: Bool
    @State private var showingDeleteAlert = false

    init(dive: Dive?) {
        self.existingDive = dive
        let d = dive ?? Dive()
        _title = State(initialValue: d.title)
        _location = State(initialValue: d.location)
        _date = State(initialValue: d.date)
        _maxDepth = State(initialValue: d.maxDepth > 0 ? String(format: "%.1f", d.maxDepth) : "")
        _duration = State(initialValue: d.duration > 0 ? String(Int(d.duration) / 60) : "")
        _waterTemperature = State(initialValue: d.waterTemperature.map { String(format: "%.1f", $0) } ?? "")
        _visibility = State(initialValue: d.visibility.map { String(format: "%.0f", $0) } ?? "")
        _notes = State(initialValue: d.notes)
        _gasMix = State(initialValue: d.gasMix ?? "")
        _tankStart = State(initialValue: d.tankPressureStart.map { String(format: "%.0f", $0) } ?? "")
        _tankEnd = State(initialValue: d.tankPressureEnd.map { String(format: "%.0f", $0) } ?? "")
        _isEditing = State(initialValue: dive == nil)
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Dive Info") {
                    if isEditing {
                        TextField("Title", text: $title)
                        TextField("Location", text: $location)
                        DatePicker("Date", selection: $date, displayedComponents: [.date, .hourAndMinute])
                    } else {
                        LabeledContent("Title", value: title.isEmpty ? "Untitled" : title)
                        LabeledContent("Location", value: location.isEmpty ? "—" : location)
                        LabeledContent("Date", value: (existingDive?.date ?? Date()).formatted(date: .long, time: .shortened))
                    }
                }

                Section("Measurements") {
                    if isEditing {
                        HStack {
                            Text("Max Depth")
                            Spacer()
                            TextField("0.0", text: $maxDepth)
                                .keyboardType(.decimalPad)
                                .multilineTextAlignment(.trailing)
                                .frame(width: 80)
                            Text("m").foregroundStyle(.secondary)
                        }
                        HStack {
                            Text("Duration")
                            Spacer()
                            TextField("0", text: $duration)
                                .keyboardType(.numberPad)
                                .multilineTextAlignment(.trailing)
                                .frame(width: 80)
                            Text("min").foregroundStyle(.secondary)
                        }
                        HStack {
                            Text("Water Temp")
                            Spacer()
                            TextField("—", text: $waterTemperature)
                                .keyboardType(.decimalPad)
                                .multilineTextAlignment(.trailing)
                                .frame(width: 80)
                            Text("°C").foregroundStyle(.secondary)
                        }
                        HStack {
                            Text("Visibility")
                            Spacer()
                            TextField("—", text: $visibility)
                                .keyboardType(.numberPad)
                                .multilineTextAlignment(.trailing)
                                .frame(width: 80)
                            Text("m").foregroundStyle(.secondary)
                        }
                    } else {
                        LabeledContent("Max Depth", value: existingDive.map { String(format: "%.1fm", $0.maxDepth) } ?? "—")
                        LabeledContent("Duration", value: existingDive?.formattedDuration ?? "—")
                        LabeledContent("Water Temp", value: existingDive?.waterTemperature.map { String(format: "%.1f°C", $0) } ?? "—")
                        LabeledContent("Visibility", value: existingDive?.visibility.map { String(format: "%.0fm", $0) } ?? "—")
                    }
                }

                if let dive = existingDive, !dive.depthProfile.isEmpty {
                    Section("Depth Profile") {
                        DepthProfileView(samples: dive.depthProfile)
                            .frame(height: 160)
                            .listRowInsets(EdgeInsets(top: 8, leading: 8, bottom: 8, trailing: 8))
                    }
                }

                Section("Gas") {
                    if isEditing {
                        HStack {
                            Text("Gas Mix")
                            Spacer()
                            TextField("Air", text: $gasMix)
                                .multilineTextAlignment(.trailing)
                        }
                        HStack {
                            Text("Tank Start")
                            Spacer()
                            TextField("—", text: $tankStart)
                                .keyboardType(.numberPad)
                                .multilineTextAlignment(.trailing)
                                .frame(width: 80)
                            Text("bar").foregroundStyle(.secondary)
                        }
                        HStack {
                            Text("Tank End")
                            Spacer()
                            TextField("—", text: $tankEnd)
                                .keyboardType(.numberPad)
                                .multilineTextAlignment(.trailing)
                                .frame(width: 80)
                            Text("bar").foregroundStyle(.secondary)
                        }
                    } else {
                        LabeledContent("Gas Mix", value: existingDive?.gasMix ?? "Air")
                        LabeledContent("Tank Start", value: existingDive?.tankPressureStart.map { String(format: "%.0f bar", $0) } ?? "—")
                        LabeledContent("Tank End", value: existingDive?.tankPressureEnd.map { String(format: "%.0f bar", $0) } ?? "—")
                    }
                }

                Section("Notes") {
                    if isEditing {
                        TextEditor(text: $notes)
                            .frame(minHeight: 100)
                    } else {
                        Text(notes.isEmpty ? "No notes" : notes)
                            .foregroundStyle(notes.isEmpty ? .secondary : .primary)
                    }
                }

                if let dive = existingDive {
                    let buddyList = diveStore.buddies(for: dive)
                    if !buddyList.isEmpty {
                        Section("Dive Buddies") {
                            ForEach(buddyList) { buddy in
                                BuddyTagView(buddy: buddy)
                            }
                        }
                    }
                }

                if existingDive != nil {
                    Section {
                        Button("Delete Dive", role: .destructive) {
                            showingDeleteAlert = true
                        }
                    }
                }
            }
            .navigationTitle(existingDive == nil ? "New Dive" : (isEditing ? "Edit Dive" : (existingDive?.title.isEmpty == false ? existingDive!.title : "Dive Details")))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    if existingDive == nil || isEditing {
                        Button("Cancel") {
                            if existingDive == nil {
                                dismiss()
                            } else {
                                isEditing = false
                            }
                        }
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    if isEditing {
                        Button("Save") { saveDive() }
                            .bold()
                    } else {
                        Button("Edit") { isEditing = true }
                    }
                }
            }
            .alert("Delete Dive", isPresented: $showingDeleteAlert) {
                Button("Delete", role: .destructive) {
                    if let dive = existingDive {
                        diveStore.deleteDive(dive)
                        dismiss()
                    }
                }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("This action cannot be undone.")
            }
        }
    }

    private func saveDive() {
        var dive = existingDive ?? Dive()
        dive.title = title
        dive.location = location
        dive.date = date
        dive.maxDepth = Double(maxDepth) ?? dive.maxDepth
        dive.duration = (Double(duration) ?? (dive.duration / 60)) * 60
        dive.waterTemperature = Double(waterTemperature)
        dive.visibility = Double(visibility)
        dive.notes = notes
        dive.gasMix = gasMix.isEmpty ? nil : gasMix
        dive.tankPressureStart = Double(tankStart)
        dive.tankPressureEnd = Double(tankEnd)

        if existingDive != nil {
            diveStore.updateDive(dive)
        } else {
            diveStore.addDive(dive)
        }
        isEditing = false
        dismiss()
    }
}

#Preview {
    DiveDetailView(dive: Dive.sampleDives[0])
        .environmentObject(DiveStore())
}
