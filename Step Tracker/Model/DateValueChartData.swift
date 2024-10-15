//
//  DateValueChartData.swift
//  Step Tracker
//
//  Created by Francois Lambert on 10/7/24.
//

import Foundation

struct DateValueChartData: Identifiable {
    let id = UUID()
    let date: Date
    let value: Double
}

extension [DateValueChartData] {
    var avgStepCounts: Double {
        guard self.isEmpty == false else { return 0 }
        let totalSteps = self.map { $0.value }.reduce(0, +)
        return totalSteps / Double(self.count)
    }

    func selectedData(in date: Date?) -> DateValueChartData? {
        guard let date else { return nil }

        return self.first {
            Calendar.current.isDate($0.date, inSameDayAs: date)
        }
    }

    var minValue: Double {
        self.map { $0.value }.min() ?? 0
    }

    var average: Double {
        self.reduce(0) { $0 + $1.value } / Double(self.count)
    }
}
