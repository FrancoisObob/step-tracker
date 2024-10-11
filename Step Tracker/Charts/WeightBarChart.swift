//
//  WeightBarChart.swift
//  Step Tracker
//
//  Created by Francois Lambert on 10/11/24.
//

import SwiftUI
import Charts

struct WeightBarChart: View {
    @State var selectedDate: Date?

    var selectedStat: HealthMetricContext
    var chartData: [WeekdayChartData]

    var selectedWeekday: WeekdayChartData? {
        guard let selectedDate else { return nil }

        return chartData.first {
            Calendar.current.isDate($0.date, inSameDayAs: selectedDate)
        }
    }

    var body: some View {
        VStack(alignment: .leading) {
            VStack(alignment: .leading) {
                Label("Average Weight Change", systemImage: "figure")
                    .font(.title3.bold())
                    .foregroundStyle(selectedStat.tintColor)

                Text("Per Weekday (Last 28 days)")
                    .font(.caption)
                    .foregroundStyle(.secondary)

            }
            .padding(.bottom, 12)

            Chart {
                if let selectedWeekday {
                    RuleMark(x: .value("Selected Weekday", selectedWeekday.date, unit: .day))
                        .foregroundStyle(.secondary.opacity(0.3))
                        .offset(y: -10)
                        .annotation(position: .top,
                                    spacing: 0,
                                    overflowResolution: .init(x: .fit(to: .chart),
                                                              y: .disabled)) { annotationView }
                }

                ForEach(chartData) { weightDiff in
                    BarMark(
                        x: .value("Date", weightDiff.date, unit: .day),
                        y: .value("Weights", weightDiff.value)
                    )
                    .foregroundStyle(weightDiff.value >= 0 ? selectedStat.tintColor.gradient : Color.mint.gradient)
                    .opacity(selectedWeekday == nil || weightDiff.date == selectedWeekday?.date ? 1.0 : 0.3)
                }
            }
            .frame(height: 150)
            .chartXSelection(value: $selectedDate.animation(.easeInOut))
            .chartXAxis {
                AxisMarks(values: .stride(by: .day)) {
                    AxisValueLabel(format: .dateTime.weekday(), centered: true)
                }

            }
            .chartYAxis {
                AxisMarks { value in
                    AxisGridLine()
                        .foregroundStyle(.secondary.opacity(0.3))
                    AxisValueLabel((value.as(Double.self) ?? 0).formatted(.number.notation(.compactName)))
                }
            }
        }
        .padding()
        .background(RoundedRectangle(cornerRadius: 12).fill(Color(.secondarySystemBackground)))
    }

    var annotationView: some View {
        VStack(alignment: .leading) {
            Text(selectedWeekday?.date ?? .now, format: .dateTime.weekday(.abbreviated).month(.abbreviated).day())
                .font(.footnote.bold())
                .foregroundStyle(.secondary)

            Text(selectedWeekday?.value ?? 0, format: .number.precision(.fractionLength(2)))
                .fontWeight(.heavy)
                .foregroundStyle((selectedWeekday?.value ?? 0) >= 0 ? selectedStat.tintColor : .mint)

        }
        .padding()
        .background(RoundedRectangle(cornerRadius: 4)
            .fill(Color(.secondarySystemBackground))
            .shadow(color: .secondary.opacity(0.3), radius: 2, x: 2, y: 2)
        )
    }
}

#Preview {
    WeightBarChart(selectedStat: .weight,
                   chartData: ChartMath.averageDailyWeightDiffs(for: MockData.weights))
}
