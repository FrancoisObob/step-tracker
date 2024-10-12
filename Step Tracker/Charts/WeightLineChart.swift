//
//  WeightLineChart.swift
//  Step Tracker
//
//  Created by Francois Lambert on 10/11/24.
//

import Charts
import SwiftUI

struct WeightLineChart: View {
    @State var selectedDate: Date?

    var selectedStat: HealthMetricContext
    var chartData: [HealthMetric]

    var minValue: Double {
        chartData.map { $0.value }.min() ?? 0
    }

    var selectedHealthMetric: HealthMetric? {
        guard let selectedDate else { return nil }

        return chartData.first {
            Calendar.current.isDate($0.date, inSameDayAs: selectedDate)
        }
    }

    var body: some View {
        VStack {
            NavigationLink(value: selectedStat) {
                HStack {
                    VStack(alignment: .leading) {
                        Label("Weight", systemImage: "figure")
                            .font(.title3.bold())
                            .foregroundStyle(selectedStat.tintColor)

                        Text("Avg: 180 lbs")
                            .font(.caption)
                    }

                    Spacer()

                    Image(systemName: "chevron.right")
                }
            }
            .foregroundStyle(.secondary)
            .padding(.bottom, 12)

            if chartData.isEmpty {
                ChartEmptyView(
                    systemImageName: "chart.line.downtrend.xyaxis",
                    title: "No Data",
                    description:
                        "There is no weight data found in Health app.")
            } else {
                Chart {
                    if let selectedHealthMetric {
                        RuleMark(
                            x: .value(
                                "Selected Metric", selectedHealthMetric.date,
                                unit: .day)
                        )
                        .foregroundStyle(.secondary.opacity(0.3))
                        //                        .offset(y: -10)
                        .annotation(
                            position: .automatic,
                            spacing: 0,
                            overflowResolution: .init(
                                x: .fit(to: .chart),
                                y: .disabled)
                        ) { annotationView }
                    }

                    RuleMark(y: .value("Goal", 155))
                        .foregroundStyle(.mint)
                        .lineStyle(.init(lineWidth: 1, dash: [5]))

                    ForEach(chartData) { weight in
                        AreaMark(
                            x: .value("Day", weight.date, unit: .day),
                            yStart: .value("Value", weight.value),
                            yEnd: .value("Min Value", minValue)
                        )
                        .foregroundStyle(
                            Gradient(colors: [
                                selectedStat.tintColor.opacity(0.5), .clear,
                            ])
                        )
                        .interpolationMethod(.catmullRom)

                        LineMark(
                            x: .value("Day", weight.date, unit: .day),
                            y: .value("Value", weight.value)
                        )
                        .foregroundStyle(selectedStat.tintColor)
                        .interpolationMethod(.catmullRom)
                        .symbol(.circle)
                    }
                }
                .frame(height: 150)
                .chartXSelection(value: $selectedDate)
                .chartYScale(domain: .automatic(includesZero: false))
                .chartXAxis {
                    AxisMarks {
                        AxisValueLabel(
                            format: .dateTime.month(.defaultDigits).day())
                    }
                }
                .chartYAxis {
                    AxisMarks { value in
                        AxisGridLine()
                            .foregroundStyle(.secondary.opacity(0.3))
                        AxisValueLabel()
                    }
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12).fill(
                Color(.secondarySystemBackground))
        )
        .sensoryFeedback(.selection, trigger: selectedDate?.weekdayInt)
    }

    var annotationView: some View {
        VStack(alignment: .leading) {
            Text(
                selectedHealthMetric?.date ?? .now,
                format: .dateTime.weekday(.abbreviated).month(.abbreviated)
                    .day()
            )
            .font(.footnote.bold())
            .foregroundStyle(.secondary)

            Text(
                selectedHealthMetric?.value ?? 0,
                format: .number.precision(.fractionLength(1))
            )
            .fontWeight(.heavy)
            .foregroundStyle(selectedStat.tintColor)

        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 4)
                .fill(Color(.secondarySystemBackground))
                .shadow(color: .secondary.opacity(0.3), radius: 2, x: 2, y: 2)
        )

    }
}

#Preview {
    WeightLineChart(selectedStat: .weight, chartData: MockData.weights)
}
