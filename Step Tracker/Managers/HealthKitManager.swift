//
//  HealthKitManager.swift
//  Step Tracker
//
//  Created by Francois Lambert on 10/3/24.
//

import Foundation
import HealthKit
import Observation

enum STError: LocalizedError {
    case authNotDetermined
    case sharingDenied(quantityType: String)
    case noData
    case unableToCompleteRequest

    var errorDescription: String? {
        switch self {
        case .authNotDetermined: return "Authorization not determined"
        case .sharingDenied: return "No Write Access"
        case .noData: return "No data available"
        case .unableToCompleteRequest: return "Unable to complete request"
        }
    }

    var failureReason: String {
        switch self {
        case .authNotDetermined:
            "You have not given access to your Health data. Please go to Settings › Health › Data Access & Devices."
        case .sharingDenied(let quantityType):
            "You have denied access to upload your \(quantityType) data. \n\nYou can change this in Settings › Health > Data Access & Devices."
        case .noData:
            "There is no data for this Health statistic."
        case .unableToCompleteRequest:
            "We are unable to complete your request at this time. \n\nPlease try again later or contact support."
        }
    }
}

@Observable class HealthKitManager {

    let store = HKHealthStore()

    let types: Set = [HKQuantityType(.stepCount), HKQuantityType(.bodyMass)]

    // Uncomment to use mock data for Preview
    //    var stepData: [HealthMetric] = MockData.steps
    //    var weightData: [HealthMetric] = MockData.weights

    var stepData: [HealthMetric] = []
    var weightData: [HealthMetric] = []

    func fetchWeights() async throws {
        guard
            store.authorizationStatus(for: HKQuantityType(.bodyMass))
                != .notDetermined
        else {
            throw STError.authNotDetermined
        }

        let calendar = Calendar.current
        let today = calendar.startOfDay(for: .now)
        let endDate = calendar.date(byAdding: .day, value: 1, to: today)!
        let startDate = calendar.date(byAdding: .day, value: -28, to: endDate)!

        let queryPredicate = HKQuery.predicateForSamples(
            withStart: startDate, end: endDate)
        let samplePredicate = HKSamplePredicate.quantitySample(
            type: .init(.bodyMass), predicate: queryPredicate)
        let weightsQuery = HKStatisticsCollectionQueryDescriptor(
            predicate: samplePredicate,
            options: .mostRecent,
            anchorDate: endDate,
            intervalComponents: DateComponents(day: 1)
        )

        do {
            let weights = try await weightsQuery.result(for: store)
            weightData = weights.statistics().map {
                .init(
                    date: $0.startDate,
                    value: $0.mostRecentQuantity()?.doubleValue(for: .pound())
                        ?? 0)
            }
        } catch HKError.errorNoData {
            throw STError.noData
        } catch {
            throw STError.unableToCompleteRequest
        }
    }

    func fetchStepCount() async throws {
        guard
            store.authorizationStatus(for: HKQuantityType(.stepCount))
                != .notDetermined
        else {
            throw STError.authNotDetermined
        }

        let calendar = Calendar.current
        let today = calendar.startOfDay(for: .now)
        let endDate = calendar.date(byAdding: .day, value: 1, to: today)!
        let startDate = calendar.date(byAdding: .day, value: -28, to: endDate)!

        let queryPredicate = HKQuery.predicateForSamples(
            withStart: startDate, end: endDate)
        let samplePredicate = HKSamplePredicate.quantitySample(
            type: .init(.stepCount), predicate: queryPredicate)
        let stepsQuery = HKStatisticsCollectionQueryDescriptor(
            predicate: samplePredicate,
            options: .cumulativeSum,
            anchorDate: endDate,
            intervalComponents: DateComponents(day: 1)
        )

        do {
            let stepsCounts = try await stepsQuery.result(for: store)
            stepData = stepsCounts.statistics().map {
                .init(
                    date: $0.startDate,
                    value: $0.sumQuantity()?.doubleValue(for: .count()) ?? 0)
            }
        } catch HKError.errorNoData {
            throw STError.noData
        } catch {
            throw STError.unableToCompleteRequest
        }
    }

    func addStepData(for date: Date, value: Double) async throws {
        let status = store.authorizationStatus(for: HKQuantityType(.stepCount))

        switch status {
        case .notDetermined:
            throw STError.authNotDetermined
        case .sharingDenied:
            throw STError.sharingDenied(quantityType: "step count")
        default:
            break
        }

        let stepQuantity = HKQuantity(unit: .count(), doubleValue: value)
        let stepSample = HKQuantitySample(
            type: .init(.stepCount),
            quantity: stepQuantity,
            start: date,
            end: date)

        do {
            try await store.save(stepSample)
        } catch {
            throw STError.unableToCompleteRequest
        }
    }

    func addWeightData(for date: Date, value: Double) async throws {
        let status = store.authorizationStatus(for: HKQuantityType(.stepCount))

        switch status {
        case .notDetermined:
            throw STError.authNotDetermined
        case .sharingDenied:
            throw STError.sharingDenied(quantityType: "weight")
        default:
            break
        }

        let weightQuantity = HKQuantity(unit: .pound(), doubleValue: value)
        let weightSample = HKQuantitySample(
            type: .init(.bodyMass),
            quantity: weightQuantity,
            start: date,
            end: date)

        do {
            try await store.save(weightSample)
        } catch {
            throw STError.unableToCompleteRequest
        }
    }

    func addSimulatorData() async {
        var mockSample: [HKQuantitySample] = []

        for i in 0..<28 {

            let stepQuantity = HKQuantity(
                unit: .count(), doubleValue: .random(in: 4000...20000))
            let weightQuantity = HKQuantity(
                unit: .pound(),
                doubleValue: .random(
                    in: 160 + Double(i / 3)...165 + Double(i / 3)))

            let startDate = Calendar.current.date(
                byAdding: .day, value: -i, to: .now)!
            let endDate = Calendar.current.date(
                byAdding: .day, value: 1, to: startDate)!

            let stepSample = HKQuantitySample(
                type: .init(.stepCount),
                quantity: stepQuantity,
                start: startDate,
                end: endDate)

            let weightSample = HKQuantitySample(
                type: .init(.bodyMass),
                quantity: weightQuantity,
                start: startDate,
                end: endDate)

            mockSample.append(stepSample)
            mockSample.append(weightSample)
        }

        try! await store.save(mockSample)
        print("✅ Simulator data added")
    }

}
