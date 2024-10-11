//
//  HealthKitManager.swift
//  Step Tracker
//
//  Created by Francois Lambert on 10/3/24.
//

import Foundation
import HealthKit
import Observation

@Observable class HealthKitManager {
    
    let store = HKHealthStore()
    
    let types: Set = [HKQuantityType(.stepCount), HKQuantityType(.bodyMass)]

    // Uncomment to use mock data for Preview
    var stepData: [HealthMetric] = MockData.steps
    var weightData: [HealthMetric] = MockData.weights

//    var stepData: [HealthMetric] = []
//    var weightData: [HealthMetric] = []

    func fetchWeights() async {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: .now)
        let endDate = calendar.date(byAdding: .day, value: 1, to: today)!
        let startDate = calendar.date(byAdding: .day, value: -28, to: endDate)!
        
        let queryPredicate = HKQuery.predicateForSamples(withStart: startDate, end: endDate)
        let samplePredicate = HKSamplePredicate.quantitySample(type: .init(.bodyMass), predicate: queryPredicate)
        let weightsQuery = HKStatisticsCollectionQueryDescriptor(
            predicate: samplePredicate,
            options: .mostRecent,
            anchorDate: endDate,
            intervalComponents: DateComponents(day: 1)
        )

        do {
            let weights = try await weightsQuery.result(for: store)
            weightData = weights.statistics().map {
                .init(date: $0.startDate,
                      value: $0.mostRecentQuantity()?.doubleValue(for: .pound()) ?? 0)
            }
        } catch {
            print("Error fetching weights: \(error)")
        }
    }
    
    func fetchStepCount() async {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: .now)
        let endDate = calendar.date(byAdding: .day, value: 1, to: today)!
        let startDate = calendar.date(byAdding: .day, value: -28, to: endDate)!
        
        let queryPredicate = HKQuery.predicateForSamples(withStart: startDate, end: endDate)
        let samplePredicate = HKSamplePredicate.quantitySample(type: .init(.stepCount), predicate: queryPredicate)
        let stepsQuery = HKStatisticsCollectionQueryDescriptor(
            predicate: samplePredicate,
            options: .cumulativeSum,
            anchorDate: endDate,
            intervalComponents: DateComponents(day: 1)
        )

        do {
            let stepsCounts = try await stepsQuery.result(for: store)
            stepData = stepsCounts.statistics().map {
                .init(date: $0.startDate,
                      value: $0.sumQuantity()?.doubleValue(for: .count()) ?? 0)
            }
        } catch {
            print("Error fetching step count: \(error)")
        }
    }

    func addStepData(for date: Date, value: Double) async {
        let stepQuantity = HKQuantity(unit: .count(), doubleValue: value)
        let stepSample = HKQuantitySample(type: .init(.stepCount),
                                          quantity: stepQuantity,
                                          start: date,
                                          end: date)
        try! await store.save(stepSample)
    }

    func addWeightData(for date: Date, value: Double) async {
        let weightQuantity = HKQuantity(unit: .pound(), doubleValue: value)
        let weightSample = HKQuantitySample(type: .init(.bodyMass),
                                            quantity: weightQuantity,
                                            start: date,
                                            end: date)
        try! await store.save(weightSample)
    }

    func addSimulatorData() async {
        var mockSample: [HKQuantitySample] = []

        for i in 0..<28 {

            let stepQuantity = HKQuantity(unit: .count(), doubleValue: .random(in: 4000...20000))
            let weightQuantity = HKQuantity(unit: .pound(), doubleValue: .random(in: 160 + Double(i/3)...165 + Double(i/3)))


            let startDate = Calendar.current.date(byAdding: .day, value: -i, to: .now)!
            let endDate = Calendar.current.date(byAdding: .day, value: 1, to: startDate)!

            let stepSample = HKQuantitySample(type: .init(.stepCount),
                                              quantity: stepQuantity,
                                              start: startDate,
                                              end: endDate)

            let weightSample = HKQuantitySample(type: .init(.bodyMass),
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
