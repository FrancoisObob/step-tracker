//
//  StepPieChart.swift
//  Step Tracker
//
//  Created by Francois Lambert on 10/7/24.
//

import SwiftUI
import Charts

struct StepPieChart: View {

    var selectedStat: HealthMetricContext
    var chartData: [WeekdayChartData]

    var body: some View {
        VStack(alignment: .leading) {
            VStack(alignment: .leading) {
                Label("Averages", systemImage: "calendar")
                    .font(.title3.bold())
                    .foregroundStyle(selectedStat.tintColor)

                Text("Last 28 days")
                    .font(.caption)
                    .foregroundStyle(.secondary)

            }
            .padding(.bottom, 12)

            Chart {
                ForEach(chartData) { weekday in
                    SectorMark(
                        angle: .value("Average Steps", weekday.value),
                        innerRadius: .ratio(0.618),
                        angularInset: 1
                    )
                    .foregroundStyle(.pink.gradient)
                    .cornerRadius(5)
                }
            }
            .frame(height: 240)
        }
        .padding()
        .background(RoundedRectangle(cornerRadius: 12).fill(Color(.secondarySystemBackground)))
    }
}

#Preview {
    StepPieChart(selectedStat: .steps,
                 chartData: ChartMath.averageWeekdayCount(for: HealthMetric.mockData))
}
