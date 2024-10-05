//
//  HealthMetric.swift
//  Step Tracker
//
//  Created by Francois Lambert on 10/5/24.
//

import Foundation

struct HealthMetric: Identifiable {
    let id = UUID()
    let date: Date
    let value: Double
}
