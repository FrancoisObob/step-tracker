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
}
