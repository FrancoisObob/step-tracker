//
//  HealthMetric.swift
//  Step Tracker
//
//  Created by Francois Lambert on 10/5/24.
//

import Foundation
import Algorithms

struct HealthMetric: Identifiable {
    let id = UUID()
    let date: Date
    let value: Double
}

extension [HealthMetric] {
    var chartData: [DateValueChartData] {
        map { .init(date: $0.date, value: $0.value) }
    }

    var averageWeekdayCountData: [DateValueChartData] {
        sorted(using: KeyPathComparator(\.date.weekdayInt))
            .chunked { $0.date.weekdayInt == $1.date.weekdayInt }
            .map { .init(date: $0.first!.date,
                         value: $0.reduce(0) { $0 + $1.value } / Double($0.count))
            }
    }

    var averageDailyWeightDiffsData: [DateValueChartData] {
        var diffValues: [(date: Date, value: Double)] = []

        guard self.count > 1 else { return [] }

        for i in 1..<self.count {
            let date = self[i].date
            let diff = self[i].value - self[i-1].value
            diffValues.append((date: date, value: diff))
        }

        return diffValues
            .sorted(using: KeyPathComparator(\.date.weekdayInt))
            .chunked { $0.date.weekdayInt == $1.date.weekdayInt }
            .map { .init(date: $0.first!.date,
                         value: $0.reduce(0) { $0 + $1.value } / Double($0.count))
            }
    }
}
