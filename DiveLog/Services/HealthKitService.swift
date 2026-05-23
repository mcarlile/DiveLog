import Foundation
import HealthKit

class HealthKitService: ObservableObject {
    private let healthStore = HKHealthStore()

    @Published var isAuthorized = false
    @Published var authorizationStatus: String = "Unknown"

    private let underwaterDivingType = HKWorkoutActivityType.underwaterDiving

    var isHealthKitAvailable: Bool {
        HKHealthStore.isHealthDataAvailable()
    }

    func requestAuthorization() async {
        guard isHealthKitAvailable else {
            await MainActor.run { self.authorizationStatus = "HealthKit not available on this device" }
            return
        }

        let typesToRead: Set<HKObjectType> = [
            HKObjectType.workoutType(),
            HKObjectType.quantityType(forIdentifier: .heartRate)!,
            HKObjectType.quantityType(forIdentifier: .activeEnergyBurned)!,
        ]

        let typesToWrite: Set<HKSampleType> = [
            HKObjectType.workoutType(),
        ]

        do {
            try await healthStore.requestAuthorization(toShare: typesToWrite, read: typesToRead)
            await MainActor.run {
                self.isAuthorized = true
                self.authorizationStatus = "Authorized"
            }
        } catch {
            await MainActor.run {
                self.authorizationStatus = "Authorization failed: \(error.localizedDescription)"
            }
        }
    }

    func saveDiveWorkout(dive: Dive) async throws {
        guard isHealthKitAvailable && isAuthorized else { return }

        let startDate = dive.date
        let endDate = startDate.addingTimeInterval(dive.duration)

        let workoutBuilder = HKWorkoutBuilder(
            healthStore: healthStore,
            configuration: workoutConfiguration(),
            device: .local()
        )

        try await workoutBuilder.beginCollection(at: startDate)

        let distanceSamples = energySamples(for: dive, startDate: startDate, endDate: endDate)
        if !distanceSamples.isEmpty {
            try await workoutBuilder.addSamples(distanceSamples)
        }

        try await workoutBuilder.endCollection(at: endDate)
        try await workoutBuilder.finishWorkout()
    }

    func fetchDiveWorkouts() async throws -> [HKWorkout] {
        guard isHealthKitAvailable && isAuthorized else { return [] }

        let predicate = HKQuery.predicateForWorkouts(with: underwaterDivingType)
        let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: false)

        return try await withCheckedThrowingContinuation { continuation in
            let query = HKSampleQuery(
                sampleType: HKObjectType.workoutType(),
                predicate: predicate,
                limit: HKObjectQueryNoLimit,
                sortDescriptors: [sortDescriptor]
            ) { _, samples, error in
                if let error = error {
                    continuation.resume(throwing: error)
                    return
                }
                continuation.resume(returning: (samples as? [HKWorkout]) ?? [])
            }
            healthStore.execute(query)
        }
    }

    private func workoutConfiguration() -> HKWorkoutConfiguration {
        let config = HKWorkoutConfiguration()
        config.activityType = underwaterDivingType
        config.locationType = .outdoor
        return config
    }

    private func energySamples(for dive: Dive, startDate: Date, endDate: Date) -> [HKSample] {
        guard let energyType = HKObjectType.quantityType(forIdentifier: .activeEnergyBurned) else {
            return []
        }
        let estimatedCalories = dive.duration / 60.0 * 8.0  // ~8 kcal/min diving
        let quantity = HKQuantity(unit: .kilocalorie(), doubleValue: estimatedCalories)
        let sample = HKQuantitySample(
            type: energyType,
            quantity: quantity,
            start: startDate,
            end: endDate
        )
        return [sample]
    }
}
