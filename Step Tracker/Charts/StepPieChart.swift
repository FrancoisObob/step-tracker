//
//  StepPieChart.swift
//  Step Tracker
//
//  Created by Francois Lambert on 10/7/24.
//

import SwiftUI
import Charts

struct StepPieChart: View {

    @State private var selectedChartValue: Double? = 0

    var selectedStat: HealthMetricContext
    var chartData: [WeekdayChartData]

    var selectedWeekday: WeekdayChartData? {
        guard let selectedChartValue else { return nil }
        var total = 0.0
        return chartData.first {
            total += $0.value
            return selectedChartValue <= total
        }
    }

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
                        outerRadius: (selectedWeekday?.date.weekdayInt == weekday.date.weekdayInt) ? 140 : 110,
                        angularInset: 1
                    )
                    .foregroundStyle(.pink.gradient)
                    .cornerRadius(5)
                    .opacity((selectedWeekday?.date.weekdayInt == weekday.date.weekdayInt) ? 1 : 0.5)
                }
            }
            .chartAngleSelection(value: $selectedChartValue.animation(.easeInOut))
            .frame(height: 240)
            .chartBackground { proxy in
                GeometryReader { geometry in
                    if let plotFrame = proxy.plotFrame {
                        let frame = geometry.frame(in: .local)
                        if let selectedWeekday {
                            VStack {
                                Text(selectedWeekday.date.weekdayTitle)
                                    .font(.title3.bold())
                                    .animation(nil)

                                Text(selectedWeekday.value, format: .number.precision(.fractionLength(0)))
                                    .fontWeight(.medium)
                                    .foregroundStyle(.secondary)
                                    .contentTransition(.numericText())
                            }
                            .position(x: frame.midX, y: frame.midY)
                        }
                    }
                }
            }
        }
        .padding()
        .background(RoundedRectangle(cornerRadius: 12).fill(Color(.secondarySystemBackground)))
        .onChange(of: selectedChartValue) { oldValue, newValue in
            if newValue == nil {
                selectedChartValue = oldValue
            }
        }
    }
}

#Preview {
    StepPieChart(selectedStat: .steps,
                 chartData: ChartMath.averageWeekdayCount(for: HealthMetric.mockData))
}
