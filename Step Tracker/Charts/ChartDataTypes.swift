//
//  ChartDataTypes.swift
//  Step Tracker
//
//  Created by Francois Lambert on 10/7/24.
//

import Foundation

struct WeekdayChartData: Identifiable {
    let id = UUID()
    let date: Date
    let value: Double
}
