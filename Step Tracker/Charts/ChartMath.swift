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
}
