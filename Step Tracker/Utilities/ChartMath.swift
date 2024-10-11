//
//  ChartMath.swift
//  Step Tracker
//
//  Created by Francois Lambert on 10/7/24.
//

import Foundation
import Algorithms

struct ChartMath {
    static func averageWeekdayCount(for metrics: [HealthMetric]) -> [WeekdayChartData] {
        return metrics
            .sorted { $0.date.weekdayInt < $1.date.weekdayInt }
            .chunked { $0.date.weekdayInt == $1.date.weekdayInt }
            .map { .init(date: $0.first!.date,
                         value: $0.reduce(0) { $0 + $1.value } / Double($0.count))
            }
    }

    static func averageDailyWeightDiffs(for weights: [HealthMetric]) -> [WeekdayChartData] {
        var diffValues: [(date: Date, value: Double)] = []

        guard weights.count > 1 else { return [] }

        for i in 1..<weights.count {
            let date = weights[i].date
            let diff = weights[i].value - weights[i-1].value
            diffValues.append((date: date, value: diff))
        }

        return diffValues
            .sorted { $0.date.weekdayInt < $1.date.weekdayInt }
            .chunked { $0.date.weekdayInt == $1.date.weekdayInt }
            .map { .init(date: $0.first!.date,
                         value: $0.reduce(0) { $0 + $1.value } / Double($0.count))
            }
    }
}
