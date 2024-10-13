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

    var chartData: [DateValueChartData]

    var minValue: Double {
        chartData.map { $0.value }.min() ?? 0
    }

    var selectedData: DateValueChartData? {
        chartData.selectedData(in: selectedDate)
    }

    var body: some View {
        VStack {
            let config = ChartContainerConfiguration(
                title: "Weight",
                symbol: "figure",
                subtitle: "Avg: 180 lbs",
                context: .weight,
                isNav: true
            )

            ChartContainer(config: config) {
                Chart {
                    if let selectedData {
                        ChartAnnotationView(
                            data: selectedData, context: .weight)
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
                                HealthMetricContext.weight.tintColor.opacity(
                                    0.5), .clear,
                            ])
                        )
                        .interpolationMethod(.catmullRom)

                        LineMark(
                            x: .value("Day", weight.date, unit: .day),
                            y: .value("Value", weight.value)
                        )
                        .foregroundStyle(HealthMetricContext.weight.tintColor)
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
                .overlay {
                    if chartData.isEmpty {
                        ChartEmptyView(
                            systemImageName: "chart.bar",
                            title: "No Data",
                            description:
                                "There is no weight data found in Health app.")
                    }
                }
            }
        }
        .sensoryFeedback(.selection, trigger: selectedDate?.weekdayInt)
    }
}

#Preview {
    WeightLineChart(chartData: MockData.weights.chartData)
}
