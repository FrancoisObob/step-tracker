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

    static var mockData: [HealthMetric] {
        var array: [HealthMetric] = []

        for i in 0..<28 {
            let metric = HealthMetric(date: Calendar.current.date(byAdding: .day, value: -i, to: .now)!,
                                      value: .random(in: 4000...15000))
            array.append(metric)
        }

        return array
    }
}
